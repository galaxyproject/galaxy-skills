#!/usr/bin/env python3
"""Regenerate the AUTO-GENERATED command index in parsec/SKILL.md.

Walks the parsec Click command tree programmatically (no --help parsing).
Idempotent: replaces only the region between the AUTO-GENERATED markers;
all hand-written content is preserved.

Prerequisites:
    pip install galaxy-parsec   (or: uv pip install galaxy-parsec)

Run:
    python generate_command_index.py
"""
import re
import sys
from pathlib import Path

import click

SKILL_PATH = Path(__file__).parent / "SKILL.md"
MARKER_START = "<!-- AUTO-GENERATED:START -->"
MARKER_END = "<!-- AUTO-GENERATED:END -->"

# Groups whose commands are always admin-only regardless of name prefix
ADMIN_GROUPS = {"quotas", "groups", "roles"}
# Commands in these groups that are user-accessible (read-only)
ADMIN_GROUP_READ_EXCEPTIONS = {
    "users": {"get_current_user", "get_user_apikey"},
}

READ_PREFIXES = ("get_", "show_", "list_", "search_", "download_", "export_",
                 "wait_for_", "wait_on_")
WRITE_PREFIXES = ("create_", "update_", "upload_", "import_", "run_", "put_",
                  "invoke_", "rerun_", "resume_", "paste_", "add_",
                  "publish_", "copy_", "extract_", "refactor_", "set_",
                  "report_", "open_", "undelete_")
DESTRUCTIVE_PREFIXES = ("delete_", "purge_", "cancel_", "remove_", "uninstall_")


def classify(group: str, command: str) -> str:
    name = command.lower()
    if group in ADMIN_GROUPS:
        return "A"
    if group == "users":
        if name in ADMIN_GROUP_READ_EXCEPTIONS.get("users", set()):
            return "R"
        return "A"
    if group == "jobs" and name == "update_job_lock":
        return "A"
    for p in DESTRUCTIVE_PREFIXES:
        if name.startswith(p):
            return "D"
    for p in READ_PREFIXES:
        if name.startswith(p):
            return "R"
    for p in WRITE_PREFIXES:
        if name.startswith(p):
            return "W"
    return "W"


def short_help(cmd: click.Command) -> str:
    if not cmd.help:
        return ""
    return cmd.help.strip().split("\n")[0].rstrip(".")[:80]


def build_table() -> str:
    from parsec.cli import parsec as root_cmd

    ctx = click.Context(root_cmd)
    rows = []
    for group_name in root_cmd.list_commands(ctx):
        group_cmd = root_cmd.get_command(ctx, group_name)
        if group_cmd is None:
            continue
        if not hasattr(group_cmd, "list_commands"):
            tag = classify(group_name, group_name)
            rows.append((group_name, group_name, tag, short_help(group_cmd)))
            continue
        subctx = click.Context(group_cmd)
        for sub_name in group_cmd.list_commands(subctx):
            sub_cmd = group_cmd.get_command(subctx, sub_name)
            if sub_cmd is None:
                continue
            tag = classify(group_name, sub_name)
            rows.append((group_name, sub_name, tag, short_help(sub_cmd)))

    header = "| Group | Command | Tag | Description |\n|-------|---------|-----|-------------|"
    lines = [header]
    for group, command, tag, desc in rows:
        lines.append(f"| {group} | {command} | {tag} | {desc} |")
    return "\n".join(lines)


def regenerate(skill_path: Path) -> None:
    text = skill_path.read_text()
    if MARKER_START not in text or MARKER_END not in text:
        print(f"ERROR: markers not found in {skill_path}", file=sys.stderr)
        sys.exit(1)

    table = build_table()
    new_block = f"{MARKER_START}\n{table}\n{MARKER_END}"
    updated = re.sub(
        re.escape(MARKER_START) + r".*?" + re.escape(MARKER_END),
        new_block,
        text,
        flags=re.DOTALL,
    )
    skill_path.write_text(updated)
    print(f"Updated {skill_path}")


if __name__ == "__main__":
    regenerate(SKILL_PATH)
