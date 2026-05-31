from __future__ import annotations

import argparse
import asyncio
import os
import sys
from pathlib import Path

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client


async def run_smoke(search_root: str, include_public_release: bool) -> None:
    env = os.environ.copy()
    env.setdefault("PYTHONIOENCODING", "utf-8")
    params = StdioServerParameters(
        command=sys.executable,
        args=["-m", "xways_mcp", "--transport", "stdio"],
        env=env,
    )

    async with stdio_client(params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            tools = await session.list_tools()
            print(f"tools: {len(tools.tools)}")
            print(", ".join(tool.name for tool in tools.tools))

            calls = [
                ("environment", {}),
                ("discover_installations", {"search_roots": search_root, "max_depth": 3}),
                ("inspect_xwfim_cache", {"path": search_root}),
            ]
            if include_public_release:
                calls.insert(1, ("public_xways_release", {"timeout": 20}))

            for name, arguments in calls:
                print(f"\n## {name}")
                result = await session.call_tool(name, arguments)
                for content in result.content:
                    print(content.text)


def main() -> None:
    parser = argparse.ArgumentParser(description="Run an MCP stdio smoke test against xways-mcp.")
    parser.add_argument(
        "--search-root",
        default=os.getenv("XWAYS_HOME") or ".",
        help="X-Ways or XWFIM folder to inspect.",
    )
    parser.add_argument(
        "--public-release",
        action="store_true",
        help="Also fetch public X-Ways release information from x-ways.net.",
    )
    args = parser.parse_args()

    search_root = str(Path(args.search_root).expanduser())
    asyncio.run(run_smoke(search_root, include_public_release=args.public_release))


if __name__ == "__main__":
    main()
