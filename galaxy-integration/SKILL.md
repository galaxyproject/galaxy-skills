---
name: galaxy-integration
description: Router for Galaxy MCP, JupyterLite notebooks, BioBlend automation, and parsec CLI scripting
user_invocable: true
---

# Galaxy Integration Skill

Use Galaxy MCP and BioBlend-based scripts to interact with a Galaxy instance for tool discovery, workflow validation, and workflow testing.

## Sub-Skills

Route to the appropriate sub-skill based on task:

| Task | Sub-Skill | Location |
|------|-----------|----------|
| Write JupyterLite notebook | `jupyterlite-galaxy` | `jupyterlite/SKILL.md` |
| MCP tools reference | `galaxy-mcp-reference` | `mcp-reference/SKILL.md` |
| History/dataset access | - | `mcp-reference/history-access.md` |
| Common gotchas | - | `mcp-reference/gotchas.md` |
| BioBlend batch scripts | - | `scripts/galaxy_tool_checker.py` |
| Tool checking examples | - | `examples/tool-checking.md` |
| Workflow testing examples | - | `examples/workflow-testing.md` |
| Shell scripting / jq pipelines / CLI automation | `parsec` | `parsec/SKILL.md` |

## When to Use

- **Query tools** installed on a Galaxy instance
- **Inspect tool I/O** and parameters
- **Create histories**, upload data, run tools/workflows
- **Debug workflow/tool issues** with fast, interactive feedback
- **Write JupyterLite notebooks** that interact with Galaxy datasets

## Prerequisites

### Galaxy URL

The base URL of the Galaxy server:
- `https://usegalaxy.org/`
- `https://usegalaxy.eu/`
- `http://localhost:8080/`

### Galaxy API Key

In Galaxy UI: **User -> Preferences -> Manage API Key**

### Repository `.env` (recommended)

```bash
cp .env.example .env
nano .env
```

Set:
```bash
GALAXY_URL=https://usegalaxy.org/
GALAXY_API_KEY=your_actual_api_key_here
```

## When to Use MCP vs Scripts

**Galaxy MCP** when:
- Interactive exploration (find a tool, inspect exact tool IDs)
- Debugging a workflow with fast iteration

**parsec CLI** (`parsec/SKILL.md`) when:
- Shell scripting, reproducible commands, jq pipelines
- No MCP runtime available
- User wants a command they can save, share, or run in CI

**BioBlend script** (`scripts/galaxy_tool_checker.py`) when:
- Bulk tool validation across many tools
- Repeatable validation/testing as part of CI-like flow

## Core MCP Workflow

1. **Confirm MCP connectivity**
   - If not connected, see `README.md` for configuration

2. **Tool discovery**
   ```
   search_tools_by_name(query=...)
   get_tool_details(tool_id=..., io_details=True)
   ```

3. **Workflow testing loop**
   ```
   create_history(history_name=...)
   invoke_workflow(workflow_id=..., inputs=..., history_id=...)
   get_history_contents(history_id=...)
   # Fix and repeat
   ```

## Output Expectations

When reporting MCP results:
- Provide **full Galaxy tool ID** (ToolShed-style)
- Include tool version
- Note whether tool is installed vs only available in repository

## References

- Upstream Galaxy MCP: https://github.com/galaxyproject/galaxy-mcp
- Repository guide: `README.md`
- Detailed MCP docs: `galaxy-integration.md`
