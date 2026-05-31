from __future__ import annotations

import hashlib
import html
import json
import os
import platform
import re
import subprocess
import sys
import urllib.request
import zipfile
from collections import Counter, deque
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable


XWAYS_EXECUTABLE_NAMES = {
    "xwforensics.exe",
    "xwforensics64.exe",
    "winhex.exe",
    "winhex64.exe",
    "xwimager.exe",
    "xwimager64.exe",
}
XWFIM_EXECUTABLE_NAMES = {"xwfim.exe"}
ARCHIVE_NAMES = {"xways.zip", "viewer.zip", "xw_viewer.zip"}
ZIP_EOCD = b"PK\x05\x06"
ZIP64_EOCD = b"PK\x06\x06"


@dataclass(frozen=True)
class ExecutableInfo:
    path: str
    name: str
    kind: str
    size: int
    modified_utc: str
    version: str | None = None


@dataclass(frozen=True)
class ZipCheck:
    path: str
    exists: bool
    valid: bool
    size: int = 0
    entries: int = 0
    first_entries: tuple[str, ...] = ()
    eocd_present: bool = False
    truncated: bool = False
    bad_entry: str | None = None
    error: str | None = None


def json_text(value: object) -> str:
    return json.dumps(value, indent=2, sort_keys=True, default=str)


def utc_iso(ts: float) -> str:
    return datetime.fromtimestamp(ts, tz=timezone.utc).isoformat()


def resolve_path(path: str | os.PathLike[str]) -> Path:
    return Path(path).expanduser().resolve()


def split_path_env(value: str | None) -> list[Path]:
    if not value:
        return []
    parts = [part.strip().strip('"') for part in value.split(os.pathsep)]
    return [resolve_path(part) for part in parts if part]


def default_search_roots() -> list[Path]:
    roots: list[Path] = []

    def add(path: str | Path | None) -> None:
        if not path:
            return
        try:
            resolved = resolve_path(path)
        except OSError:
            return
        if resolved.exists() and resolved not in roots:
            roots.append(resolved)

    add(os.getenv("XWAYS_HOME"))
    for root in split_path_env(os.getenv("XWAYS_MCP_SEARCH_ROOTS")):
        add(root)

    add(Path.cwd())
    home = Path.home()
    for candidate in (
        home / "Desktop",
        home / "Documents",
        Path("C:/xwf"),
        Path("C:/xways"),
        Path("C:/WinHex"),
    ):
        add(candidate)

    return roots


def get_environment() -> dict:
    return {
        "package": "xways-mcp",
        "python": sys.version.split()[0],
        "platform": platform.platform(),
        "cwd": str(Path.cwd()),
        "allow_execute": os.getenv("XWAYS_MCP_ALLOW_EXECUTE", "0") == "1",
        "xways_home": os.getenv("XWAYS_HOME") or None,
        "search_roots": [str(p) for p in default_search_roots()],
    }


def _bounded_walk(root: Path, max_depth: int) -> Iterable[Path]:
    queue: deque[tuple[Path, int]] = deque([(root, 0)])
    while queue:
        current, depth = queue.popleft()
        try:
            with os.scandir(current) as entries:
                for entry in entries:
                    try:
                        path = Path(entry.path)
                        if entry.is_file(follow_symlinks=False):
                            yield path
                        elif entry.is_dir(follow_symlinks=False) and depth < max_depth:
                            queue.append((path, depth + 1))
                    except OSError:
                        continue
        except OSError:
            continue


def windows_file_version(path: Path) -> str | None:
    if sys.platform != "win32":
        return None
    try:
        import ctypes
        from ctypes import wintypes

        class VS_FIXEDFILEINFO(ctypes.Structure):
            _fields_ = [
                ("dwSignature", wintypes.DWORD),
                ("dwStrucVersion", wintypes.DWORD),
                ("dwFileVersionMS", wintypes.DWORD),
                ("dwFileVersionLS", wintypes.DWORD),
                ("dwProductVersionMS", wintypes.DWORD),
                ("dwProductVersionLS", wintypes.DWORD),
                ("dwFileFlagsMask", wintypes.DWORD),
                ("dwFileFlags", wintypes.DWORD),
                ("dwFileOS", wintypes.DWORD),
                ("dwFileType", wintypes.DWORD),
                ("dwFileSubtype", wintypes.DWORD),
                ("dwFileDateMS", wintypes.DWORD),
                ("dwFileDateLS", wintypes.DWORD),
            ]

        version = ctypes.WinDLL("version", use_last_error=True)
        size = version.GetFileVersionInfoSizeW(str(path), None)
        if not size:
            return None
        buffer = ctypes.create_string_buffer(size)
        if not version.GetFileVersionInfoW(str(path), 0, size, buffer):
            return None
        lp = ctypes.c_void_p()
        length = wintypes.UINT()
        if not version.VerQueryValueW(buffer, "\\", ctypes.byref(lp), ctypes.byref(length)):
            return None
        info = ctypes.cast(lp, ctypes.POINTER(VS_FIXEDFILEINFO)).contents
        if info.dwSignature != 0xFEEF04BD:
            return None
        parts = (
            info.dwFileVersionMS >> 16,
            info.dwFileVersionMS & 0xFFFF,
            info.dwFileVersionLS >> 16,
            info.dwFileVersionLS & 0xFFFF,
        )
        return ".".join(str(part) for part in parts)
    except Exception:
        return None


def classify_executable(name: str) -> str:
    lowered = name.lower()
    if lowered in XWFIM_EXECUTABLE_NAMES:
        return "xwfim"
    if "imager" in lowered:
        return "xways_imager"
    if "winhex" in lowered:
        return "winhex"
    return "xways_forensics"


def discover_executables(
    search_roots: Iterable[str | os.PathLike[str]] | None = None,
    max_depth: int = 4,
    limit: int = 100,
) -> list[dict]:
    roots = [resolve_path(p) for p in search_roots] if search_roots else default_search_roots()
    names = XWAYS_EXECUTABLE_NAMES | XWFIM_EXECUTABLE_NAMES
    found: list[ExecutableInfo] = []
    seen: set[Path] = set()
    for root in roots:
        if not root.exists():
            continue
        candidates = [root] if root.is_file() else _bounded_walk(root, max_depth=max_depth)
        for path in candidates:
            if path in seen or path.name.lower() not in names:
                continue
            try:
                stat = path.stat()
            except OSError:
                continue
            seen.add(path)
            found.append(
                ExecutableInfo(
                    path=str(path),
                    name=path.name,
                    kind=classify_executable(path.name),
                    size=stat.st_size,
                    modified_utc=utc_iso(stat.st_mtime),
                    version=windows_file_version(path),
                )
            )
            if len(found) >= limit:
                return [asdict(item) for item in found]
    return [asdict(item) for item in found]


def _zip_tail_has_eocd(path: Path) -> bool:
    try:
        size = path.stat().st_size
        with path.open("rb") as f:
            f.seek(max(0, size - 65557))
            tail = f.read()
        return ZIP_EOCD in tail or ZIP64_EOCD in tail
    except OSError:
        return False


def validate_zip(path: str | os.PathLike[str]) -> dict:
    target = resolve_path(path)
    if not target.exists():
        return asdict(ZipCheck(path=str(target), exists=False, valid=False, error="file not found"))

    size = target.stat().st_size
    eocd_present = _zip_tail_has_eocd(target)
    try:
        with zipfile.ZipFile(target) as archive:
            names = tuple(archive.namelist())
            bad = archive.testzip()
            return asdict(
                ZipCheck(
                    path=str(target),
                    exists=True,
                    valid=bad is None,
                    size=size,
                    entries=len(names),
                    first_entries=names[:10],
                    eocd_present=eocd_present,
                    truncated=not eocd_present,
                    bad_entry=bad,
                    error=None if bad is None else f"CRC or decode failed for {bad}",
                )
            )
    except zipfile.BadZipFile as exc:
        return asdict(
            ZipCheck(
                path=str(target),
                exists=True,
                valid=False,
                size=size,
                eocd_present=eocd_present,
                truncated=not eocd_present,
                error=str(exc),
            )
        )


def summarize_zip_checks(archives: list[dict]) -> dict:
    invalid = [item for item in archives if not item.get("valid")]
    truncated = [item for item in invalid if item.get("truncated")]
    missing_eocd = [item for item in invalid if not item.get("eocd_present")]
    if not archives:
        status = "empty"
        recommendation = "No ZIP files were found in the XWFIM Temp directory."
    elif truncated:
        status = "problem"
        names = ", ".join(Path(item["path"]).name for item in truncated)
        recommendation = (
            f"Delete the truncated archive(s) ({names}) and re-run XWFIM. "
            "If the same file truncates again, update XWFIM and verify the download URL/credentials."
        )
    elif invalid:
        status = "problem"
        names = ", ".join(Path(item["path"]).name for item in invalid)
        recommendation = f"Archive validation failed for {names}; delete and re-download before installing."
    else:
        status = "ok"
        recommendation = "All ZIP archives in the XWFIM Temp directory validated successfully."

    return {
        "status": status,
        "archives_found": len(archives),
        "valid_archives": len(archives) - len(invalid),
        "invalid_archives": len(invalid),
        "truncated_archives": len(truncated),
        "missing_eocd_archives": len(missing_eocd),
        "recommendation": recommendation,
    }


def inspect_xwfim_cache(path: str | os.PathLike[str] | None = None) -> dict:
    base = resolve_path(path) if path else None
    if base is None:
        candidates = [Path(item["path"]).parent for item in discover_executables() if item["kind"] == "xwfim"]
        base = candidates[0] if candidates else Path.cwd()
    temp = base if base.name.lower() == "temp" else base / "Temp"
    archives: list[dict] = []
    if temp.exists():
        for archive in sorted(temp.glob("*.zip")):
            check = validate_zip(archive)
            check["known_xways_archive"] = archive.name.lower() in ARCHIVE_NAMES
            archives.append(check)
    return {
        "base": str(base),
        "temp": str(temp),
        "temp_exists": temp.exists(),
        "summary": summarize_zip_checks(archives),
        "archives": archives,
    }


def hash_file(
    path: str | os.PathLike[str],
    algorithms: Iterable[str] = ("sha256",),
    chunk_size: int = 1024 * 1024,
) -> dict:
    target = resolve_path(path)
    hashers = {}
    for name in algorithms:
        normalized = name.lower().replace("-", "")
        try:
            hashers[normalized] = hashlib.new(normalized)
        except ValueError as exc:
            raise ValueError(f"unsupported hash algorithm: {name}") from exc
    size = 0
    with target.open("rb") as f:
        while True:
            chunk = f.read(chunk_size)
            if not chunk:
                break
            size += len(chunk)
            for hasher in hashers.values():
                hasher.update(chunk)
    return {
        "path": str(target),
        "size": size,
        "hashes": {name: hasher.hexdigest() for name, hasher in hashers.items()},
    }


def sanitize_case_name(case_name: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9._ -]+", "_", case_name).strip(" .")
    if not cleaned or not re.search(r"[A-Za-z0-9]", cleaned):
        raise ValueError("case_name must contain at least one safe character")
    return cleaned


def create_case_workspace(base_dir: str | os.PathLike[str] | None, case_name: str) -> dict:
    base = resolve_path(base_dir or os.getenv("XWAYS_MCP_CASE_ROOT") or Path.cwd() / "case-workspaces")
    safe_name = sanitize_case_name(case_name)
    root = base / safe_name
    folders = {
        "root": root,
        "case": root / "case",
        "evidence": root / "evidence",
        "exports": root / "exports",
        "reports": root / "reports",
        "logs": root / "logs",
        "scripts": root / "scripts",
        "scratch": root / "scratch",
    }
    for folder in folders.values():
        folder.mkdir(parents=True, exist_ok=True)
    manifest = {
        "case_name": case_name,
        "safe_name": safe_name,
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "folders": {key: str(value) for key, value in folders.items()},
    }
    manifest_path = root / "workspace.json"
    manifest_path.write_text(json_text(manifest) + "\n", encoding="utf-8")
    manifest["manifest"] = str(manifest_path)
    return manifest


def triage_inventory(
    root: str | os.PathLike[str],
    max_files: int = 5000,
    hash_small_files: bool = False,
    max_hash_size: int = 64 * 1024 * 1024,
) -> dict:
    base = resolve_path(root)
    extension_counts: Counter[str] = Counter()
    total_size = 0
    files: list[dict] = []
    largest: list[dict] = []
    errors: list[str] = []
    visited = 0

    for current, dirs, names in os.walk(base):
        dirs[:] = [d for d in dirs if not d.startswith("$Recycle.Bin")]
        for name in names:
            path = Path(current) / name
            try:
                stat = path.stat()
            except OSError as exc:
                errors.append(f"{path}: {exc}")
                continue
            visited += 1
            ext = path.suffix.lower() or "<none>"
            extension_counts[ext] += 1
            total_size += stat.st_size
            item = {
                "path": str(path),
                "size": stat.st_size,
                "modified_utc": utc_iso(stat.st_mtime),
                "extension": ext,
            }
            if hash_small_files and stat.st_size <= max_hash_size:
                item["sha256"] = hash_file(path, ("sha256",))["hashes"]["sha256"]
            if len(files) < max_files:
                files.append(item)
            largest.append(item)
            largest = sorted(largest, key=lambda value: value["size"], reverse=True)[:25]

    return {
        "root": str(base),
        "visited_files": visited,
        "listed_files": len(files),
        "total_size": total_size,
        "extension_counts": dict(extension_counts.most_common()),
        "largest_files": largest,
        "files": files,
        "errors": errors[:100],
        "truncated": visited > len(files),
    }


def build_xways_command(
    executable: str | os.PathLike[str],
    case_path: str | os.PathLike[str] | None = None,
    evidence_path: str | os.PathLike[str] | None = None,
    script_path: str | os.PathLike[str] | None = None,
    extra_args: Iterable[str] | None = None,
    xt_params: dict[str, str] | None = None,
) -> list[str]:
    args = [str(resolve_path(executable))]
    for value in (case_path, evidence_path, script_path):
        if value:
            args.append(str(resolve_path(value)))
    if xt_params:
        for key, value in xt_params.items():
            if not re.fullmatch(r"[A-Za-z0-9_.-]+", str(key)):
                raise ValueError(f"unsafe XTParam key: {key}")
            args.append(f"XTParam:{key}:{value}")
    if extra_args:
        args.extend(str(arg) for arg in extra_args if str(arg).strip())
    return args


def launch_xways(args: list[str], confirm: bool = False, wait: bool = False) -> dict:
    allow_execute = os.getenv("XWAYS_MCP_ALLOW_EXECUTE", "0") == "1"
    if not allow_execute or not confirm:
        return {
            "launched": False,
            "dry_run": True,
            "reason": "Set XWAYS_MCP_ALLOW_EXECUTE=1 and pass confirm=true to launch.",
            "command": args,
        }
    proc = subprocess.Popen(args, cwd=str(Path(args[0]).parent))
    result = {"launched": True, "pid": proc.pid, "command": args}
    if wait:
        result["exit_code"] = proc.wait()
    return result


def normalize_html_text(text: str) -> str:
    decoded = html.unescape(text)
    decoded = re.sub(r"<script\b.*?</script>", " ", decoded, flags=re.I | re.S)
    decoded = re.sub(r"<style\b.*?</style>", " ", decoded, flags=re.I | re.S)
    decoded = re.sub(r"<[^>]+>", " ", decoded)
    decoded = decoded.replace("\u2011", "-").replace("\xa0", " ")
    return re.sub(r"\s+", " ", decoded).strip()


def parse_xways_release_page(url: str, text: str) -> dict:
    normalized = normalize_html_text(text)
    version: str | None = None
    release_date: str | None = None

    mailing = re.search(
        r"availability of version\s+([0-9]+(?:\.[0-9]+)+).*?"
        r"official release date\s+([A-Za-z]+ [0-9]{1,2}, [0-9]{4})",
        normalized,
        flags=re.I,
    )
    if mailing:
        version = mailing.group(1)
        release_date = mailing.group(2)

    if version is None:
        index = re.search(
            r"X-Ways Forensics\s+([0-9]+(?:\.[0-9]+)+)(?:\s+NEW\b)?",
            normalized,
            flags=re.I,
        )
        if index:
            version = index.group(1)

    if release_date is None:
        date = re.search(
            r"official release date\s+([A-Za-z]+ [0-9]{1,2}, [0-9]{4})",
            normalized,
            flags=re.I,
        )
        if date:
            release_date = date.group(1)

    return {
        "source": url,
        "version": version,
        "release_date": release_date,
        "ok": True,
    }


def fetch_public_release(timeout: int = 20) -> dict:
    sources = [
        "https://www.x-ways.net/winhex/mailings/",
        "https://www.x-ways.com/forensics/index-m.html",
        "https://www.x-ways.net/forensics/index-m.html",
    ]
    attempts: list[dict] = []
    for url in sources:
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "xways-mcp/0.1"})
            with urllib.request.urlopen(request, timeout=timeout) as response:
                text = response.read().decode("utf-8", errors="replace")
            attempts.append(parse_xways_release_page(url, text))
        except Exception as exc:
            attempts.append({"source": url, "ok": False, "error": str(exc)})
    best = next((item for item in attempts if item.get("version")), None)
    return {"best": best, "attempts": attempts}
