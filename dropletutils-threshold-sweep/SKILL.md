---
name: dropletutils-threshold-sweep
description: Run a small grid of DropletUtils emptyDrops jobs with varying `lower` parameter values, then verify and compare results to select an appropriate cell-calling threshold. Use when the default lower=100 over-retains barcodes or when the expected cell count is unknown.
user_invocable: true
---

# DropletUtils emptyDrops Threshold Sweep

Run multiple DropletUtils `emptyDrops` jobs across a range of `lower` UMI
thresholds to find a value that recovers a biologically plausible number of cells.

## When to Use

Use this skill when:
- DropletUtils with `lower=100` (the default) retains far more barcodes than
  expected (e.g. 50,000+ barcodes when the paper reports ~5,000 cells)
- The sample is from a non-human organism where typical UMI-count priors may
  not apply
- The knee plot shows an unusual shape and you need to probe the threshold space
- You want to confirm that the selected threshold is robust (not at a cliff edge)

**Do not proceed to Scanpy clustering** after a single DropletUtils run without
first verifying the retained barcode count is plausible.

## Your Input

```
$ARGUMENTS
```

Typical arguments: history ID, STARsolo output dataset IDs (genes, barcodes,
matrix), expected cell count range (from paper / SRA metadata), organism.

---

## Common Pitfalls (READ FIRST)

### 1. Always Verify Before Proceeding

A DropletUtils job that completes with `ok` status is NOT necessarily a good
cell call. Always check:
- Retained barcode count equals the matrix column count
- Retained barcode count is in a plausible range for the sample

### 2. The Default lower=100 Is Often Wrong

For samples from non-standard organisms or with unusual UMI distributions,
`lower=100` lets through ambient RNA barcodes at scale. A retained count of
10x or 100x the expected cell number is a clear sign the threshold is too low.

### 3. Watch for Cliff Edges

Some samples have an abrupt threshold cliff: a small change in `lower` can
change retained barcodes by 10-fold (e.g. 3,000 at lower=500 vs 900 at
lower=650). If you land at a cliff, test additional values near the transition
to understand the shape before committing.

### 4. Datatype Mismatch Downstream

DropletUtils outputs genes/barcodes as `tsv` datatype. The IWC Scanpy clustering
workflow requires genes input as `tabular`. Change the datatype via Edit
Attributes before feeding into Scanpy.

---

## Step-by-Step

### 1. Determine the target cell count range

Before sweeping, establish a prior from the paper or SRA metadata:
- Check the original paper's methods for reported post-QC cell counts
- Check SRA metadata for the number of spots

This gives you a target range (e.g. "expect 2,000–5,000 cells").

### 2. Pick initial sweep values

| Scenario | Suggested initial values |
|---|---|
| Default lower=100 over-retains (~10× expected) | 500, 750, 1000 |
| Default over-retains (~2×) | 200, 400, 600 |
| Unknown (start broad) | 200, 500, 1000, 1500 |

Run all values in parallel (separate tool calls); they are independent.

### 3. Submit each DropletUtils job

For each `lower` value:

```python
tool_id = "toolshed.g2.bx.psu.edu/repos/iuc/dropletutils/dropletutils/1.10.0+galaxy2"

inputs = {
    "tenx_format|use": "directory",
    "tenx_format|input": {"src": "hda", "id": MATRIX_HID},
    "tenx_format|input_genes": {"src": "hda", "id": GENES_HID},
    "tenx_format|input_barcodes": {"src": "hda", "id": BARCODES_HID},
    "operation|use": "filter",
    "operation|method|use": "emptydrops",
    "operation|method|lower": LOWER_VALUE,       # vary this
    "operation|method|fdr_thresh": 0.01,
    "operation|outformat": "directory",
    "seed": 100,
}
```

### 4. Verify each result

For each completed run, check:

1. **Status**: all output datasets reach `ok`
2. **Barcode count**: download barcodes file, count lines → must equal matrix
   column count
3. **Matrix dimensions**: parse Matrix Market header → rows=genes, cols=barcodes
4. **Plausibility**: retained barcode count is in expected cell range
5. **UMI distribution**: check the DropletUtils table for `is.Cell` and
   `is.CellAndLimited` counts; look at median UMI for retained barcodes

Verification template:

```python
# After download:
barcodes = open("barcodes.tsv").read().strip().split("\n")
n_barcodes = len(barcodes)

mmx_header = open("matrix.mtx").readline().replace("%%MatrixMarket","")
# Second non-comment line: "genes barcodes nnz"
dims = [l for l in open("matrix.mtx") if not l.startswith("%")][0].split()
n_cols = int(dims[1])

assert n_barcodes == n_cols, f"Mismatch: {n_barcodes} barcodes vs {n_cols} columns"
print(f"lower={lower}: {n_barcodes} barcodes retained, matrix {dims[0]}×{dims[1]}, nnz={dims[2]}")
```

### 5. Choose a threshold

Select the `lower` value where:
- Retained barcodes are within the expected cell count range
- The run is NOT at a cliff edge (neighbouring values should give smoothly
  changing counts, not a 10-fold jump)
- Median retained UMI is reasonable (typically 1,000–5,000 for well-recovered cells)

If two values both look plausible, prefer the stricter one (higher `lower`) to
reduce ambient RNA contamination in downstream clustering.

### 6. Run additional sweeps if needed

If no tested value gives plausible counts, run a targeted second sweep:
- If all values over-retain: move `lower` higher
- If all values under-retain: move `lower` lower
- If there's a cliff: add 2–3 values bracketing the cliff to understand the
  transition

---

## Expected Outputs

For each `lower` value, DropletUtils `filter` in directory mode produces:
- `barcodes_out`: filtered barcodes list (`tsv`)
- `genes_out`: genes list (`tsv`) — **change to `tabular` before Scanpy**
- `matrix_out`: filtered count matrix (`mtx`)
- `table`: per-barcode statistics including `is.Cell`, `is.CellAndLimited` (`tsv`)
- `plot`: barcode rank plot (`png`)
