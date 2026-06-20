# Name Tags for Tracking Workflow Runs

Use Galaxy **name tags** to label datasets, collections, and workflow runs so a history stays readable when an agent launches many tools or workflows over the same data.

## What name tags are

A tag that starts with `#` is a **name tag**. Its defining feature is **propagation**: every dataset derived from a tagged dataset automatically inherits the tag. If a tool has several tagged inputs, the output carries **all** of their name tags. Plain tags (no `#`) do **not** propagate.

In the UI you type `#run1`; internally and over the API the same tag is stored as `name:run1`. When setting tags programmatically, always use the `name:` prefix — the `#` form is UI-only.

Tag values cannot contain spaces or commas. Use short, distinct, kebab/underscore identifiers: `name:rnaseq-star-default`, `name:sampleA`, `name:GSM461181`.

## Why an agent should use them

When an agent runs multiple workflows (or the same workflow with different parameters) over a set of datasets, untagged outputs are indistinguishable in the history — dozens of `STAR on data N` entries with no provenance. Name tags make each run's outputs traceable by a colored pill that follows the data through every downstream step, with no per-dataset renaming.

## Setting name tags

**The Galaxy MCP server has no dataset/collection tagging tool.** It exposes only `update_history(history_id, tags=[...])`, which sets **history-level** tags (and replaces the existing list — it does not propagate). To set propagating name tags on datasets and collections, use the raw API or BioBlend.

### Raw API (canonical)

```bash
# Tag a dataset (HDA)
curl -s -X PUT "$GALAXY_URL/api/histories/$HISTORY_ID/contents/$DATASET_ID?key=$GALAXY_API_KEY" \
     -H 'Content-Type: application/json' \
     -d '{"tags": ["name:rnaseq-star-default"]}'

# Tag a collection (HDCA)
curl -s -X PUT "$GALAXY_URL/api/histories/$HISTORY_ID/contents/dataset_collections/$HDCA_ID?key=$GALAXY_API_KEY" \
     -H 'Content-Type: application/json' \
     -d '{"tags": ["name:run1"]}'
```

`tags` **replaces** the dataset's tag list. To add a tag, fetch the current tags first (`get_dataset_details`) and send the union.

### BioBlend

`update_dataset`/`update_dataset_collection` forward `**kwargs` to the same endpoint, so `tags` works even though it isn't in their documented signature:

```python
from bioblend.galaxy import GalaxyInstance

gi = GalaxyInstance(url=GALAXY_URL, key=GALAXY_API_KEY)
gi.histories.update_dataset(HISTORY_ID, DATASET_ID, tags=["name:rnaseq-star-default"])
gi.histories.update_dataset_collection(HISTORY_ID, HDCA_ID, tags=["name:run1"])
```

## Patterns for multiple runs

### Pattern A — tag inputs, let propagation do the work (preferred)

Best when distinct inputs map to distinct runs (e.g. one collection per sample). Tag each **input** once, **before** invoking; every output of every downstream step inherits the tag automatically.

```python
# Tag the input collection, then invoke
gi.histories.update_dataset_collection(history_id, collection_id, tags=["name:sampleA"])
invoke_workflow(workflow_id=..., inputs={"0": {"src": "hdca", "id": collection_id}, ...}, history_id=history_id)
# All workflow outputs now carry #sampleA
```

Propagation happens at job-creation time, so the input must be tagged **before** the workflow is invoked.

### Pattern B — tag each run's outputs (same input, several runs)

When the **same** input feeds multiple workflows or parameter sets, tagging the shared input gives every run the same tag. Instead, label each invocation's outputs with a run-specific tag after invoking:

```python
inv = invoke_workflow(workflow_id=..., inputs=..., history_id=history_id)   # e.g. STAR, default params
# enumerate this invocation's output datasets and tag them
for out in get_invocations(invocation_id=inv["id"])["outputs"].values():
    gi.histories.update_dataset(history_id, out["id"], tags=["name:star-default"])
```

Run the next workflow/param set and tag its outputs `name:star-strict`, etc. Each run is then a distinct color in the history.

### Combine with descriptive histories

For large fan-outs, pair name tags with one well-named history per run (`create_history(history_name="STAR default — sampleA")`). Tags trace lineage within a history; history names separate the runs.

## Verifying

Name tags appear as colored pills in the history UI. Programmatically, check the `tags` field:

```python
get_dataset_details(dataset_id)            # -> {"tags": ["name:sampleA"], ...}
get_history_contents(history_id)           # each item includes its tags
```

A correctly applied name tag is stored as `name:<value>` and shown as `#<value>` in the UI.

## See also

- `gotchas.md` — workflow invocation pitfalls
- Galaxy Training: [Name tags for following complex histories](https://training.galaxyproject.org/training-material/topics/galaxy-interface/tutorials/name-tags/tutorial.html)
