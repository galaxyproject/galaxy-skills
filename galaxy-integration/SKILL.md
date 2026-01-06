# Galaxy Integration Skill

Use Galaxy MCP and BioBlend-based scripts to interact with a Galaxy instance for tool discovery, workflow validation, and workflow testing.

---

## Purpose

This skill provides the **canonical guidance** for configuring and using **Galaxy MCP** in this repository.

Use it when you need:
- Query what tools are installed on a Galaxy instance
- Inspect tool I/O and parameters
- Create histories, upload data, and run tools/workflows
- Debug workflow/tool issues with fast, interactive feedback

---

## Prerequisites

### Galaxy URL

The base URL of the Galaxy server you are targeting, for example:
- `https://usegalaxy.org/`
- `https://usegalaxy.eu/`
- `http://localhost:8080/`

### Galaxy API Key

In your Galaxy UI:
- **User → Preferences → Manage API Key**

Treat API keys like passwords.

### Repository `.env` (recommended)

This repository keeps `.env.example` at the **skills repo root**.

From the skills repo root:

```bash
cp .env.example .env
nano .env
```

Set:

```bash
GALAXY_URL=https://usegalaxy.org/
GALAXY_API_KEY=your_actual_api_key_here
```

The root `.env` is gitignored; do not commit it.

---

## When to Use MCP vs Scripts

Use **Galaxy MCP** when:
- You want interactive exploration (find a tool, inspect exact tool IDs)
- You are debugging a workflow and need fast iteration (create history → invoke workflow → inspect failures)

Prefer a **script** (BioBlend / `galaxy_tool_checker.py`) when:
- You need batch checks across many tools
- You want repeatable validation/testing as part of a CI-like flow

---

## Core MCP Workflow (Recommended Pattern)

1. **Confirm MCP connectivity**
   - If MCP is not connected/configured, instruct the user to configure MCP using `galaxy-integration/README.md`.

2. **Tool discovery**
   - Find candidate tools: `search_tools_by_name(query=...)`
   - Inspect I/O: `get_tool_details(tool_id=..., io_details=True)`

3. **Workflow testing loop**
   - Create history: `create_history(history_name=...)`
   - Upload or reuse datasets
   - Invoke workflow: `invoke_workflow(workflow_id=..., inputs=..., history_id=...)`
   - Inspect outputs: `get_history_contents(history_id=...)`
   - Fix the workflow/tool mapping and repeat

---

## Common MCP Operations

Use whichever MCP function names are available in the environment.

- **Tool search**: `search_tools_by_name(query=...)`
- **Tool details**: `get_tool_details(tool_id=..., io_details=True)`
- **Create history**: `create_history(history_name=...)`
- **Upload data**: `upload_file(...)`
- **Invoke workflow**: `invoke_workflow(workflow_id=..., inputs=..., history_id=...)`
- **Inspect history**: `get_history_contents(history_id=...)`
- **Inspect dataset**: `get_dataset_details(dataset_id=...)`

---

## Output Expectations

When reporting results from MCP interactions:
- Provide the **full Galaxy tool ID** (ToolShed-style) whenever available
- Include tool version
- Note whether a tool is installed vs only available in a repository

---

## References

- Upstream Galaxy MCP project: https://github.com/galaxyproject/galaxy-mcp
- Repository skill guide: `galaxy-integration/README.md`
