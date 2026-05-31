from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import urllib.request
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

from .core import default_search_roots, normalize_html_text, resolve_path, utc_iso


OFFICIAL_MANUAL_URLS = (
    "https://www.x-ways.net/winhex/manual.pdf",
    "https://www.x-ways.com/winhex/manual.pdf",
)
OFFICIAL_DOC_PAGES = {
    "scripting": "https://www.x-ways.net/winhex/scripting.html",
    "administration": "https://www.x-ways.net/winhex/setup.html",
    "x_tensions_api": "https://www.x-ways.net/forensics/x-tensions/api.html",
}
MANUAL_FILENAMES = {"manual.pdf"}
INDEX_VERSION = 1


@dataclass(frozen=True)
class ManualCandidate:
    path: str
    size: int
    modified_utc: str
    sha256: str


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def default_manual_cache_dir(cache_dir: str | os.PathLike[str] | None = None) -> Path:
    if cache_dir:
        return resolve_path(cache_dir)
    configured = os.getenv("XWAYS_MCP_MANUAL_CACHE")
    if configured:
        return resolve_path(configured)
    return resolve_path(Path.cwd() / "tooling" / "cache" / "xways-manual")


def sha256_file(path: Path, chunk_size: int = 1024 * 1024) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        while True:
            chunk = handle.read(chunk_size)
            if not chunk:
                break
            hasher.update(chunk)
    return hasher.hexdigest()


def discover_manual_candidates(
    search_roots: Iterable[str | os.PathLike[str]] | None = None,
    max_depth: int = 3,
    limit: int = 25,
) -> list[dict]:
    roots = [resolve_path(root) for root in search_roots] if search_roots else default_search_roots()
    candidates: list[ManualCandidate] = []
    seen: set[Path] = set()

    for root in roots:
        if not root.exists():
            continue
        stack: list[tuple[Path, int]] = [(root, 0)]
        while stack:
            current, depth = stack.pop()
            if current in seen:
                continue
            seen.add(current)
            try:
                if current.is_file():
                    paths = [current]
                else:
                    paths = list(current.iterdir())
            except OSError:
                continue
            for path in paths:
                try:
                    if path.is_dir() and depth < max_depth:
                        stack.append((path, depth + 1))
                        continue
                    if path.is_file() and path.name.lower() in MANUAL_FILENAMES:
                        stat = path.stat()
                        candidates.append(
                            ManualCandidate(
                                path=str(path),
                                size=stat.st_size,
                                modified_utc=utc_iso(stat.st_mtime),
                                sha256=sha256_file(path),
                            )
                        )
                        if len(candidates) >= limit:
                            return [asdict(item) for item in candidates]
                except OSError:
                    continue
    candidates.sort(key=lambda item: item.modified_utc, reverse=True)
    return [asdict(item) for item in candidates]


def fetch_manual_metadata(timeout: int = 20) -> dict:
    attempts: list[dict] = []
    for url in OFFICIAL_MANUAL_URLS:
        try:
            request = urllib.request.Request(url, method="HEAD", headers={"User-Agent": "xways-mcp/0.1"})
            with urllib.request.urlopen(request, timeout=timeout) as response:
                attempts.append(
                    {
                        "url": url,
                        "ok": True,
                        "status": response.status,
                        "content_length": response.headers.get("Content-Length"),
                        "last_modified": response.headers.get("Last-Modified"),
                        "etag": response.headers.get("ETag"),
                    }
                )
        except Exception as exc:
            attempts.append({"url": url, "ok": False, "error": str(exc)})
    return {"best": next((item for item in attempts if item.get("ok")), None), "attempts": attempts}


def _download(url: str, target: Path, timeout: int) -> dict:
    request = urllib.request.Request(url, headers={"User-Agent": "xways-mcp/0.1"})
    with urllib.request.urlopen(request, timeout=timeout) as response:
        data = response.read()
        target.write_bytes(data)
        return {
            "url": url,
            "status": response.status,
            "content_length": response.headers.get("Content-Length"),
            "last_modified": response.headers.get("Last-Modified"),
            "etag": response.headers.get("ETag"),
            "size": len(data),
        }


def _extract_pdf_entries(path: Path) -> list[dict]:
    try:
        from pypdf import PdfReader
    except ImportError as exc:
        raise RuntimeError("Install pypdf to extract manual text: python -m pip install pypdf") from exc

    reader = PdfReader(str(path))
    entries = []
    for index, page in enumerate(reader.pages, start=1):
        text = page.extract_text() or ""
        if text.strip():
            entries.append({"source": "manual", "page": index, "text": text})
    return entries


def _extract_text_entries(path: Path) -> list[dict]:
    text = path.read_text(encoding="utf-8", errors="replace")
    return [{"source": "manual", "page": None, "text": text}]


def _fetch_doc_page_entries(timeout: int) -> tuple[list[dict], list[dict]]:
    entries: list[dict] = []
    attempts: list[dict] = []
    for key, url in OFFICIAL_DOC_PAGES.items():
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "xways-mcp/0.1"})
            with urllib.request.urlopen(request, timeout=timeout) as response:
                html = response.read().decode("utf-8", errors="replace")
            text = normalize_html_text(html)
            entries.append({"source": key, "page": None, "url": url, "text": text})
            attempts.append({"key": key, "url": url, "ok": True})
        except Exception as exc:
            attempts.append({"key": key, "url": url, "ok": False, "error": str(exc)})
    return entries, attempts


def normalize_manual_text(text: str) -> str:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def chunk_text(text: str, *, source: str, page: int | None, url: str | None = None, chunk_chars: int = 1600) -> list[dict]:
    normalized = normalize_manual_text(text)
    paragraphs = [part.strip() for part in re.split(r"\n\s*\n", normalized) if part.strip()]
    chunks: list[dict] = []
    current: list[str] = []
    current_len = 0

    def flush() -> None:
        nonlocal current, current_len
        if not current:
            return
        chunk = "\n\n".join(current).strip()
        if chunk:
            chunks.append({"source": source, "page": page, "url": url, "text": chunk})
        current = []
        current_len = 0

    for paragraph in paragraphs:
        if len(paragraph) > chunk_chars:
            flush()
            for start in range(0, len(paragraph), chunk_chars):
                chunks.append({"source": source, "page": page, "url": url, "text": paragraph[start : start + chunk_chars]})
            continue
        if current and current_len + len(paragraph) + 2 > chunk_chars:
            flush()
        current.append(paragraph)
        current_len += len(paragraph) + 2
    flush()
    return chunks


def build_manual_index(entries: list[dict], metadata: dict) -> dict:
    chunks: list[dict] = []
    for entry in entries:
        chunks.extend(
            chunk_text(
                entry.get("text", ""),
                source=entry.get("source", "manual"),
                page=entry.get("page"),
                url=entry.get("url"),
            )
        )
    for index, chunk in enumerate(chunks):
        chunk["id"] = f"chunk-{index:05d}"
    return {
        "index_version": INDEX_VERSION,
        "created_utc": utc_now(),
        "metadata": metadata,
        "chunks": chunks,
    }


def cache_xways_manual(
    source: str = "",
    cache_dir: str = "",
    refresh: bool = False,
    download_latest: bool = False,
    fetch_official_docs: bool = False,
    timeout: int = 30,
) -> dict:
    cache = default_manual_cache_dir(cache_dir or None)
    cache.mkdir(parents=True, exist_ok=True)
    pdf_path = cache / "xways-manual.pdf"
    text_path = cache / "xways-manual.txt"
    index_path = cache / "xways-manual.index.json"
    meta_path = cache / "xways-manual.meta.json"

    selected_source = source.strip()
    source_info: dict
    source_path: Path | None = None
    downloaded = None

    if download_latest:
        selected_source = OFFICIAL_MANUAL_URLS[0]

    if not selected_source:
        candidates = discover_manual_candidates()
        if not candidates:
            return {
                "ok": False,
                "reason": "No local manual.pdf was found. Pass source=<path> or download_latest=true.",
                "cache_dir": str(cache),
            }
        selected_source = candidates[0]["path"]

    if re.match(r"^https?://", selected_source, flags=re.I):
        if refresh or not pdf_path.exists():
            downloaded = _download(selected_source, pdf_path, timeout=timeout)
        source_path = pdf_path
        source_info = {"kind": "url", "url": selected_source, "downloaded": downloaded}
    else:
        source_path = resolve_path(selected_source)
        if not source_path.exists():
            return {"ok": False, "reason": "manual source not found", "source": str(source_path), "cache_dir": str(cache)}
        if source_path.suffix.lower() == ".pdf":
            if refresh or not pdf_path.exists() or sha256_file(source_path) != sha256_file(pdf_path):
                shutil.copy2(source_path, pdf_path)
            source_path = pdf_path
        source_info = {"kind": "file", "path": selected_source}

    entries = _extract_pdf_entries(source_path) if source_path.suffix.lower() == ".pdf" else _extract_text_entries(source_path)
    doc_entries: list[dict] = []
    doc_attempts: list[dict] = []
    if fetch_official_docs:
        doc_entries, doc_attempts = _fetch_doc_page_entries(timeout=timeout)
        entries.extend(doc_entries)

    text = "\n\n".join(
        f"[{entry.get('source', 'manual')} page {entry.get('page') or 'n/a'}]\n{normalize_manual_text(entry.get('text', ''))}"
        for entry in entries
        if entry.get("text", "").strip()
    )
    text_path.write_text(text + "\n", encoding="utf-8")

    stat = source_path.stat()
    metadata = {
        "source": source_info,
        "pdf_path": str(pdf_path) if pdf_path.exists() else None,
        "text_path": str(text_path),
        "source_size": stat.st_size,
        "source_modified_utc": utc_iso(stat.st_mtime),
        "source_sha256": sha256_file(source_path),
        "official_doc_pages": doc_attempts,
    }
    index = build_manual_index(entries, metadata)
    index_path.write_text(json.dumps(index, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    meta_path.write_text(json.dumps(metadata, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    return {
        "ok": True,
        "cache_dir": str(cache),
        "pdf_path": str(pdf_path) if pdf_path.exists() else None,
        "text_path": str(text_path),
        "index_path": str(index_path),
        "chunks": len(index["chunks"]),
        "manual_pages": len([entry for entry in entries if entry.get("source") == "manual"]),
        "official_doc_pages_cached": len(doc_entries),
        "metadata": metadata,
    }


def manual_cache_status(
    search_roots: str = "",
    cache_dir: str = "",
    check_online: bool = False,
    timeout: int = 20,
) -> dict:
    roots = [item.strip() for item in search_roots.split(os.pathsep) if item.strip()] if search_roots else None
    cache = default_manual_cache_dir(cache_dir or None)
    index_path = cache / "xways-manual.index.json"
    text_path = cache / "xways-manual.txt"
    meta_path = cache / "xways-manual.meta.json"
    status = {
        "cache_dir": str(cache),
        "cached": {
            "index_exists": index_path.exists(),
            "text_exists": text_path.exists(),
            "metadata_exists": meta_path.exists(),
            "index_path": str(index_path),
            "text_path": str(text_path),
            "metadata_path": str(meta_path),
        },
        "local_candidates": discover_manual_candidates(roots),
    }
    if index_path.exists():
        try:
            index = json.loads(index_path.read_text(encoding="utf-8"))
            status["cached"]["created_utc"] = index.get("created_utc")
            status["cached"]["chunks"] = len(index.get("chunks", []))
            status["cached"]["metadata"] = index.get("metadata", {})
        except json.JSONDecodeError as exc:
            status["cached"]["error"] = str(exc)
    if check_online:
        status["online"] = fetch_manual_metadata(timeout=timeout)
    return status


def _terms(query: str) -> list[str]:
    return [term.lower() for term in re.findall(r"[A-Za-z0-9_:/.-]{2,}", query)]


def _snippet(text: str, query_terms: list[str], max_chars: int) -> str:
    lowered = text.lower()
    positions = [lowered.find(term) for term in query_terms if lowered.find(term) >= 0]
    start = max(0, min(positions) - max_chars // 4) if positions else 0
    snippet = text[start : start + max_chars].strip()
    if start > 0:
        snippet = "..." + snippet
    if start + max_chars < len(text):
        snippet += "..."
    return snippet


def search_manual_index(query: str, cache_dir: str = "", limit: int = 8, max_chars: int = 900) -> dict:
    cache = default_manual_cache_dir(cache_dir or None)
    index_path = cache / "xways-manual.index.json"
    if not index_path.exists():
        return {
            "ok": False,
            "reason": "Manual index not found. Run cache_xways_manual first.",
            "index_path": str(index_path),
        }
    index = json.loads(index_path.read_text(encoding="utf-8"))
    terms = _terms(query)
    if not terms:
        return {"ok": False, "reason": "query must contain at least one searchable term", "index_path": str(index_path)}

    scored = []
    phrase = query.lower().strip()
    for chunk in index.get("chunks", []):
        text = chunk.get("text", "")
        lowered = text.lower()
        score = 0
        if phrase and phrase in lowered:
            score += 50
        for term in terms:
            score += lowered.count(term)
        if score:
            scored.append((score, chunk))
    scored.sort(key=lambda item: item[0], reverse=True)
    results = []
    for score, chunk in scored[: max(1, limit)]:
        results.append(
            {
                "id": chunk.get("id"),
                "score": score,
                "source": chunk.get("source"),
                "page": chunk.get("page"),
                "url": chunk.get("url"),
                "snippet": _snippet(chunk.get("text", ""), terms, max_chars),
            }
        )
    return {
        "ok": True,
        "query": query,
        "index_path": str(index_path),
        "metadata": index.get("metadata", {}),
        "results": results,
    }


def headless_reference(topic: str = "", cache_dir: str = "", limit: int = 8) -> dict:
    query = topic.strip() or "command line parameters scripting automated processing XTParam Open CreateBackup"
    return search_manual_index(query=query, cache_dir=cache_dir, limit=limit, max_chars=1100)
