# Galaxy MCP Gotchas

Common pitfalls and solutions when using Galaxy MCP.

## Retrieving API Key from macOS Keychain

```bash
# Find keychain entry names
security dump-keychain | grep -i galaxy -A 5 -B 5

# Retrieve the password (use svce and acct values from above)
security find-generic-password -s "usegalaxy.org" -a "galaxy-api" -w
```

## Finding Histories by URL

Galaxy URLs use slugs that differ from actual history names:
- URL: `usegalaxy.org/u/user/h/my-analysis-run` -> slug is `my-analysis-run`
- Actual name: `My Analysis Run` (title case, spaces)

The `get_histories(name=...)` filter is case-sensitive. To find a history from a URL:
1. Use `list_history_ids()` to get all histories
2. Match case-insensitively, treating hyphens as spaces

## Empty History Contents

**Problem**: `get_history_contents` returns empty but history has datasets.

**Solution**: Default only shows visible, non-deleted datasets:
```
get_history_contents(
    history_id="...",
    deleted=true,
    visible=false
)
```

## Dataset ID vs HID

- `hid` = human-readable number shown in UI (e.g., 13437)
- `id` = hex hash used in API calls (e.g., "f9cad7b01a472135...")

All MCP functions use `id` (the hex hash), not `hid`.

## Tool ID Formats

Galaxy tool IDs can have multiple formats:
- Simple: `Cut1`, `cat1`
- ToolShed: `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/hyphy_fel/2.5.84+galaxy0`

Always use the full ToolShed format in workflows for reproducibility.

## Workflow Input Mapping

When invoking workflows, inputs use step indices:
```python
invoke_workflow(
    workflow_id="...",
    inputs={
        "0": {"id": "DATASET_ID", "src": "hda"},  # Step 0
        "1": {"id": "DATASET_ID2", "src": "hda"}  # Step 1
    },
    history_id="..."
)
```

`src` values:
- `hda` = HistoryDatasetAssociation (standard dataset)
- `hdca` = HistoryDatasetCollectionAssociation (collection)
- `ldda` = LibraryDatasetDatasetAssociation

## Optional Parameter Inputs Must Be Explicit

**Problem**: Omitting an optional `parameter_input` step from the `inputs` dict causes downstream tools to receive an unresolved `ConnectedValue` placeholder, producing command lines with literal garbage like `'Xgalaxy.tools.parameters.workflow_utils.ConnectedValue object at 0x...X'` and tool failures with cryptic exit codes.

**Solution**: Always pass an explicit value for **every** `parameter_input` step in the workflow, even ones marked `optional: true`. Use `""` for empty text, `null` for empty data inputs:

```python
# WRONG - inputs 1 and 2 (optional adapter sequences) omitted
inputs = {
    "0": {"src": "hdca", "id": collection_id},
    "5": {"src": "hda", "id": gtf_id},
    "6": "stranded - reverse",
    # ...
}

# CORRECT - explicit empty strings for optional text params
inputs = {
    "0": {"src": "hdca", "id": collection_id},
    "1": "",                          # Forward adapter (optional)
    "2": "",                          # Reverse adapter (optional)
    "5": {"src": "hda", "id": gtf_id},
    "6": "stranded - reverse",
    # ...
}
```

**How to verify before invoking**: call `get_workflow_details(workflow_id)` and check the `inputs` dict — every numeric key (step index) of type `parameter_input` needs a corresponding entry in your `inputs`, regardless of `optional` status.

**How to diagnose after failure**: if a tool fails with no obvious stderr cause, fetch `get_job_details(dataset_id)` and inspect `command_line` for the string `ConnectedValue object at 0x`. That signature confirms the omitted-optional-input bug.

## Workflow API Double-Nests pick_value Parameters

**Problem**: A workflow with `pick_value` steps (conditional `pick_style` parameter)
fails when invoked via the API with:

> `Parameter 'pick_style': an invalid option (None) was selected`

even though the same workflow runs fine from the Galaxy UI. Galaxy double-nests
the parameter values on API invocation (`{parameter_value: {parameter_value: 3}}`
instead of `{parameter_value: 3}`), so every `pick_value` step gets a value shape
it doesn't expect.

**Solution**: This is a known Galaxy API / workflow-serialization issue with no
clean invoke-time workaround. Run the workflow from the **Galaxy UI** instead of
`invoke_workflow`. Construct the complete parameter set yourself and hand it to
the user to fill into the workflow "Run" form, or fill it in directly if you
have UI access. Confirmed on the IWC `Preprocessing-and-Clustering-of-single-cell-RNA-seq-data-with-Scanpy`
workflow, but the underlying serialization bug applies to any workflow using
`pick_value`.

## Boolean Parameters Mis-marshalled Through Workflow Wiring

**Problem**: A tool step exposed through a workflow as a user-facing boolean can
silently receive the wrong value even when the run form shows the expected
setting. Confirmed with STARsolo's `soloBarcodeReadLength` parameter as wired by
the IWC `fastq-to-matrix-10x` workflow: the workflow surfaces it as a boolean,
but the value doesn't marshal reliably to the underlying tool parameter,
producing `Solo: CB 17bp` in the log for 10x v3 data instead of the correct
`Solo: CB 16bp`.

**Solution**: If a workflow-wired boolean produces behavior inconsistent with
what's shown on the run form, invoke the underlying tool directly via the tool
API instead of through the workflow, and pass the parameter's raw string value
explicitly (e.g. `"0"` rather than relying on a checkbox). Directly-invoked tool
parameters aren't subject to the workflow's boolean-wiring layer.

## Datatype Mismatches Block Otherwise-Valid Inputs

**Problem**: A dataset produced by one tool (e.g. `tsv`) can be functionally
identical to what a downstream tool or workflow expects (e.g. `tabular`) but
still be rejected or simply not offered as a valid input, because Galaxy matches
inputs by declared datatype, not content.

**Solution**: Check the declared datatype of upstream outputs against the
downstream tool/workflow's expected input datatype before wiring them together.
If they differ but are format-compatible, change the dataset's datatype via
**Edit Attributes -> Datatype** (or the equivalent `update_dataset` MCP call)
before using it as input.

## Connection Issues

```python
# Check connection
get_server_info()

# If fails, reconnect
connect(url="https://usegalaxy.org", api_key="YOUR_KEY")
```

## URL Trailing Slash

Galaxy URLs should end with `/`:
- Correct: `https://usegalaxy.org/`
- May fail: `https://usegalaxy.org`

## Large Histories

Don't request all datasets at once. Use pagination:
```python
# First 100
get_history_contents(history_id="...", limit=100, offset=0)

# Next 100
get_history_contents(history_id="...", limit=100, offset=100)
```

## Order Options

- `hid-asc` - oldest first (default)
- `hid-dsc` - newest first (usually what you want)
- `create_time-dsc` - most recently created
- `update_time-dsc` - most recently modified
- `name-asc` - alphabetical
