---
name: parsec
description: >
  Shell scripting with parsec, the Galaxy CLI. Write bash scripts, one-liners,
  and jq pipelines that drive Galaxy servers — workflows, datasets, histories,
  tools. Use for automation, CI, cron, batch ops, or when no MCP runtime is
  available. Do not use for interactive MCP sessions, JupyterLite notebooks,
  BioBlend Python scripts, or Nextflow pipelines.
user_invocable: true
---

# Parsec — Galaxy CLI Skill

`parsec` is a BioBlend-backed CLI for driving Galaxy servers from the shell.
It emits JSON and composes naturally with `jq`.

## When to use parsec vs siblings

| Need | Use |
|------|-----|
| Interactive exploration, one-off query | Galaxy MCP (`../mcp-reference/SKILL.md`) |
| Bulk tool validation across many tools | `galaxy_tool_checker.py` (`../scripts/`) |
| Scripted workflow/dataset ops, CI, jq pipelines | **parsec** (this skill) |
| JupyterLite notebooks interacting with Galaxy | `jupyterlite-galaxy` (`../jupyterlite/SKILL.md`) |

## Quick start

```bash
# Configure a Galaxy instance (creates ~/.parsec.yml)
parsec init --url https://usegalaxy.org --api_key <KEY>

# Override instance per command
parsec -g myserver histories get_histories | jq '.[].name'
```

Invocation pattern: `parsec [-g INSTANCE] <group> <command> [ARGS] [OPTIONS]`

All commands output JSON. Pipe through `jq` to filter:
```bash
parsec workflows get_workflows | jq '.[] | {id, name}'
parsec histories get_histories | jq '.[] | select(.name == "My History") | .id'
```

Full command index: `references/commands.md` (read it when you need to discover a command or verify a group/subcommand name).

## Agent safety protocol

Before any write/destructive action:
1. **Inspect first** — run `get_*` / `show_*` / `list_*` to enumerate targets
2. **Summarize IDs** — echo back to the user what will be affected
3. **Confirm** — ask the user before running `delete_*`, `purge_*`, or admin commands

```bash
# 1. Inspect
parsec histories get_histories | jq '.[] | {id, name}'
# 2. (report to user: "Found history 'Old Run' with id abc123")
# 3. (wait for confirmation)
parsec histories delete_history abc123
```

## Pitfalls

### Invocation command groups — pick the right one

Two groups share a `get_invocations` subcommand; they are not equivalent:

| Command | When to use |
|---------|-------------|
| `parsec workflows get_invocations <WORKFLOW_ID>` | You have a workflow ID and want its invocations. Positional arg required. |
| `parsec invocations get_invocations [--workflow_id ...]` | You want all invocations across the instance, optionally filtered. |

When the user gives you a workflow ID and asks for its invocations, always use `workflows get_invocations`.

### Tool input JSON format

Simple dataset inputs use **nested JSON**, not pipe-separated keys:

```bash
# Correct
parsec tools run_tool $HID <TOOL_ID> '{"input": {"src": "hda", "id": "'$DID'"}}'

# Wrong — pipe format is only for inputs inside conditionals/repeats
parsec tools run_tool $HID <TOOL_ID> '{"input|src": "hda", "input|id": "'$DID'"}'
```

Use `parsec tools show_tool <TOOL_ID> --io_details` to inspect the exact input names before constructing the JSON.

## Common patterns

### Discover and run a tool

```bash
# Find tool by name
parsec tools get_tools --name "trimmomatic" | jq '.[] | {id, name}'

# Inspect tool inputs
parsec tools show_tool <TOOL_ID> --io_details | jq '.inputs[] | {name, type}'

# Create a history, upload, run
HID=$(parsec histories create_history --name "My Run" | jq -r '.id')
parsec tools upload_file --history_id $HID mydata.fastq
DID=$(parsec histories show_history $HID --contents | jq -r '.[0].id')
JID=$(parsec tools run_tool $HID <TOOL_ID> '{"input": {"src": "hda", "id": "'$DID'"}}' | jq -r '.jobs[0].id')
parsec jobs wait_for_job $JID
```

### Invoke a workflow

```bash
WID=$(parsec workflows get_workflows | jq -r '.[] | select(.name=="My WF") | .id')
parsec workflows show_workflow $WID | jq '.inputs'

HID=$(parsec histories create_history --name "WF Output" | jq -r '.id')
parsec tools upload_file --history_id $HID input.fastq
DID=$(parsec histories show_history $HID --contents | jq -r '.[0].id')

INVID=$(parsec workflows invoke_workflow $WID \
  --history_id $HID \
  --inputs '{"0": {"id": "'$DID'", "src": "hda"}}' | jq -r '.id')

parsec invocations wait_for_invocation $INVID
parsec invocations get_invocation_summary $INVID | jq '.states'
```

### Dataset upload and download

```bash
parsec tools upload_file --history_id $HID myfile.txt | jq '.outputs[0].id'
parsec tools put_url --history_id $HID "https://example.com/data.gz"
parsec datasets download_dataset $DID --file_path ./output.txt
parsec datasets show_dataset $DID | jq '{name, state, file_size, file_ext}'
```

## Error handling

| Error | Cause | Fix |
|-------|-------|-----|
| `401 Unauthorized` | API key invalid or expired | Re-run `parsec init` with a fresh key from Galaxy UI → User → Manage API Key |
| `403 Forbidden` | Insufficient permissions | Contact admin; check your role on the target history/library |
| `404 Not Found` | Wrong ID | Verify with `get_*` / `show_*` first |
| `Connection refused` / `Failed to connect` | Wrong URL or server down | Check URL in `~/.parsec.yml`; confirm server is reachable |
| `Problem loading command utils` | Missing submodule | Run `pip install -e .` in parsec repo root |
| `Empty result []` | Wrong instance or filter | Check `-g INSTANCE` and filter params |
| `NoneType has no attribute` | Piped ID was null (empty result) | Guard with `jq 'select(. != null)'` before passing IDs downstream |

## ID encoding

Galaxy uses encoded (opaque) IDs everywhere — never construct them manually.
Always retrieve IDs from `get_*` / `show_*` output and pass them to subsequent commands.
