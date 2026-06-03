---
name: galaxy-mcp-reference
description: Galaxy MCP server tools reference for histories, datasets, tools, and workflows
user_invocable: true
---

# Galaxy MCP Tools Reference

Complete reference for Galaxy MCP server functions.

## Connection

```
mcp__galaxy__connect(url, api_key)  # Connect to Galaxy instance
mcp__galaxy__get_server_info()       # Server version and config
mcp__galaxy__get_user()              # Current user details
```

## Histories

```
mcp__galaxy__list_history_ids()                    # Quick list: {id, name}
mcp__galaxy__get_histories(limit, offset, name)    # Paginated, filterable
mcp__galaxy__get_history_details(history_id)       # Metadata only, no datasets
mcp__galaxy__get_history_contents(history_id, limit, offset, order)  # Datasets
mcp__galaxy__create_history(history_name)          # Create new history
```

## Datasets

```
mcp__galaxy__get_dataset_details(dataset_id, include_preview, preview_lines)
mcp__galaxy__download_dataset(dataset_id, file_path)  # Omit file_path for memory
mcp__galaxy__upload_file(path, history_id)
mcp__galaxy__upload_file_from_url(url, history_id, file_type, dbkey)
mcp__galaxy__get_job_details(dataset_id)  # Job that created this dataset
```

## Tools

```
mcp__galaxy__search_tools_by_name(query)
mcp__galaxy__search_tools_by_keywords(keywords)  # keywords is a list
mcp__galaxy__get_tool_details(tool_id, io_details)
mcp__galaxy__get_tool_run_examples(tool_id)      # XML test cases
mcp__galaxy__get_tool_citations(tool_id)
mcp__galaxy__get_tool_panel()                    # Full toolbox hierarchy
mcp__galaxy__run_tool(history_id, tool_id, inputs)
```

## Workflows

```
mcp__galaxy__list_workflows(workflow_id, name, published)
mcp__galaxy__get_workflow_details(workflow_id, version)
mcp__galaxy__invoke_workflow(workflow_id, inputs, params, history_id)
mcp__galaxy__get_invocations(invocation_id, workflow_id, history_id)
mcp__galaxy__cancel_workflow_invocation(invocation_id)
```

## IWC (Intergalactic Workflow Commission)

```
mcp__galaxy__get_iwc_workflows()           # Full manifest
mcp__galaxy__search_iwc_workflows(query)   # Search by name/description/tags
mcp__galaxy__import_workflow_from_iwc(trs_id)
```

## Common Patterns

### Tool Discovery
```python
# Find candidate tools
search_tools_by_name(query="hyphy")

# Inspect I/O
get_tool_details(tool_id="toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/hyphy_fel/2.5.84+galaxy0", io_details=True)
```

### Workflow Testing Loop
```python
# 1. Create history
create_history(history_name="Test: My Workflow")

# 2. Upload or reuse datasets
upload_file(path="/path/to/data.txt", history_id="...")

# 3. Invoke workflow
invoke_workflow(workflow_id="...", inputs={"0": {"id": "DATASET_ID", "src": "hda"}}, history_id="...")

# 4. Inspect outputs
get_history_contents(history_id="...", order="create_time-dsc")

# 5. Fix and repeat
```

### History Contents with Pagination
```python
# Page 1 (newest first)
get_history_contents(history_id="...", limit=100, offset=0, order="hid-dsc")

# Page 2
get_history_contents(history_id="...", limit=100, offset=100, order="hid-dsc")
```

## Order Options for History Contents

- `hid-asc` - oldest first (default)
- `hid-dsc` - newest first
- `create_time-dsc` - most recently created
- `update_time-dsc` - most recently modified
- `name-asc` - alphabetical

## See Also

- `history-access.md` - Detailed history/dataset access patterns
- `name-tags.md` - Name tags (`#tag`) for tracking workflow runs in a history
- `gotchas.md` - Common pitfalls and solutions
