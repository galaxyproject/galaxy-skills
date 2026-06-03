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

## Parameter Inputs Must Be Explicit Scalars

Pass `parameter_input` step values as **scalars directly** in the `inputs` map. Two distinct failure modes bite API/MCP users here — one from omitting the value, one from wrapping it.

### Failure mode 1: omitting the step

**Problem**: Omitting an optional `parameter_input` step from the `inputs` dict causes downstream tools to receive an unresolved `ConnectedValue` placeholder, producing command lines with literal garbage like `'Xgalaxy.tools.parameters.workflow_utils.ConnectedValue object at 0x...X'` and tool failures with cryptic exit codes.

### Failure mode 2: wrapping the value

**Problem**: Wrapping a `parameter_input` value in an object such as `{"parameter_value": ""}` is **not** unwrapped — the wrapper object gets stringified and passed to the downstream tool verbatim. With IWC `rnaseq-pe`, wrapping the fastp adapter inputs makes fastp receive an invalid adapter sequence and fail:

```
ERROR: the adapter <adapter_sequence> can only have bases in {A, T, C, G},
but the given sequence is: XXparameter_valueX: XXX
```

**Solution**: Always pass an explicit **scalar** value for **every** `parameter_input` step, even ones marked `optional: true`. Use `""` for empty text, `null` for empty data inputs. Do **not** omit them, and do **not** wrap them in `{"parameter_value": ...}`:

```python
# WRONG - inputs 1 and 2 (optional adapter sequences) omitted
inputs = {
    "0": {"src": "hdca", "id": collection_id},
    "5": {"src": "hda", "id": gtf_id},
    "6": "stranded - reverse",
    # ...
}

# ALSO WRONG - wrapped in {"parameter_value": ...}; the wrapper is stringified
inputs = {
    "0": {"src": "hdca", "id": collection_id},
    "1": {"parameter_value": ""},     # becomes literal garbage downstream
    "2": {"parameter_value": ""},
    # ...
}

# CORRECT - explicit scalar empty strings for optional text params
inputs = {
    "0": {"src": "hdca", "id": collection_id},
    "1": "",                          # Forward adapter (optional)
    "2": "",                          # Reverse adapter (optional)
    "5": {"src": "hda", "id": gtf_id},
    "6": "stranded - reverse",
    # ...
}
```

Data inputs (`hda`/`hdca`/`ldda`) use the `{"src": ..., "id": ...}` form; `parameter_input` steps take a bare scalar. A full IWC `rnaseq-pe` invocation with `inputs_by="step_index"`:

```json
{
  "inputs": {
    "0": { "src": "hdca", "id": "<list_paired_collection_id>" },
    "1": "",
    "2": "",
    "3": true,
    "4": "GCA_002759435.3",
    "5": { "src": "hda", "id": "<gtf_dataset_id>" },
    "6": "stranded - reverse",
    "7": true,
    "8": false,
    "10": false
  },
  "inputs_by": "step_index"
}
```

**How to verify before invoking**: call `get_workflow_details(workflow_id)` and check the `inputs` dict — every numeric key (step index) of type `parameter_input` needs a corresponding scalar entry in your `inputs`, regardless of `optional` status.

**How to diagnose after failure**: if a tool fails with no obvious stderr cause, fetch `get_job_details(dataset_id)` and inspect `command_line`. The string `ConnectedValue object at 0x` confirms an omitted input; a stringified wrapper like `parameter_value` in the value (e.g. fastp's `the given sequence is: XXparameter_valueX`) confirms a wrapped input.

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
