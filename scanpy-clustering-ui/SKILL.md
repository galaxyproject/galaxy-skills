---
name: scanpy-clustering-ui
description: Run the IWC Scanpy clustering workflow for scRNA-seq data. Documents required UI-only invocation (API invocation is broken), correct parameter choices, and the genes datatype fix needed before the workflow can run.
user_invocable: true
---

# Scanpy Clustering Workflow (IWC)

Run the IWC `Preprocessing-and-Clustering-of-single-cell-RNA-seq-data-with-Scanpy`
workflow on a filtered count matrix to produce UMAP, Louvain clusters, and
ranked marker genes.

## When to Use

Use this skill after cell calling (DropletUtils or equivalent) has produced a
filtered barcodes/genes/matrix triplet and you want to:
- QC filter cells by gene count and mitochondrial fraction
- Normalize, find HVGs, run PCA + UMAP
- Cluster cells with Louvain
- Identify per-cluster marker genes

## Your Input

```
$ARGUMENTS
```

Typical arguments: history ID, genes HID, barcodes HID, matrix HID, organism
(for choosing the mitochondrial gene prefix), QC thresholds from the paper.

---

## CRITICAL: API Invocation Is Broken — Use the UI

**Do NOT invoke this workflow via the Galaxy API.** The workflow contains many
`pick_value` steps that use a conditional `pick_style` parameter. When the
workflow is invoked through the API, Galaxy double-nests the parameter values
(`{parameter_value: {parameter_value: 3}}` instead of `{parameter_value: 3}`),
causing every `pick_value` step to fail with:

> `Parameter 'pick_style': an invalid option (None) was selected`

This is a known Galaxy API / workflow-serialization issue. The workflow runs
correctly when launched from the **Galaxy UI**.

**Workaround:** Construct the complete parameter set (see below) and ask the
user to run the workflow from the Galaxy UI with those settings, or use the
Galaxy workflow "Run" form directly.

---

## Common Pitfalls (READ FIRST)

### 1. Genes File Must Be tabular, Not tsv

The workflow's Genes input requires datatype `tabular`. DropletUtils outputs
genes as `tsv`. These are the same format but Galaxy treats them as different
datatypes, so the dataset cannot be selected for the workflow input without
changing its type first.

**Fix before running the workflow:**
- In the Galaxy history, click the genes dataset's pencil icon (Edit Attributes)
- Change Datatype from `tsv` to `tabular`
- Save

### 2. Cell Ranger v2 Input Format

DropletUtils outputs a 2-column genes file (gene_id, gene_name). This matches
the Cell Ranger v2/earlier format. The Scanpy workflow's first step (which reads
the matrix) has a boolean parameter:

> **"Input is from Cell Ranger v2 or earlier versions?"**

This **must be set to Yes** when using DropletUtils output. Setting it to No
causes the import to fail because it expects a 3-column genes file.

### 3. Mitochondrial Gene Prefix Is Organism-Specific

The workflow uses a string prefix to identify mitochondrial genes for QC.
Common values:

| Organism | Prefix | Notes |
|---|---|---|
| Human | `MT-` | Standard |
| Mouse | `mt-` | Lowercase |
| *Ae. aegypti* | `ND` | No shared MT- prefix; `ND` catches 7/13 mito genes without false positives |
| *Drosophila* | `mt:` | Check annotation |

For non-model organisms, verify the gene prefix by inspecting the var names in
the matrix before running the workflow.

### 4. Louvain Resolution Affects Cluster Number

Start at a low resolution (0.1) to get broad populations matching expected cell
types. If all cells collapse into 1–2 clusters, increase resolution (0.2–0.5).
If you get far more clusters than expected cell types, decrease it.

---

## Recommended Parameter Values

These are the parameters to set in the Galaxy UI workflow run form:

| Parameter | Recommended value | Notes |
|---|---|---|
| Barcodes file | filtered barcodes output | Change type to `tabular` if needed |
| Genes file | filtered genes output | **Must change type to `tabular`** |
| Matrix file | filtered matrix output | `mtx` type, no change needed |
| Input is from Cell Ranger v2 or earlier? | **Yes** | Required for DropletUtils output |
| Minimum cells expressing a gene | 3 | Standard filter |
| Minimum genes per cell | 100–200 | Match paper's QC threshold |
| Maximum genes per cell | 2500 | Match paper's QC threshold |
| Mitochondrial gene prefix | organism-specific (see table above) | |
| Number of neighbours | 15 | Standard for scRNA-seq |
| Number of PCs | 10–20 | 15 is a safe default; match paper if stated |
| Louvain resolution | 0.1 (start low) | Increase if too few clusters |
| Manually annotate cell types? | No | Do post-hoc annotation after inspecting markers |

---

## After the Workflow Completes

The workflow produces many intermediate datasets. Key outputs:
- **Final AnnData** (`h5ad`): fully processed object with UMAP and Louvain labels
- **UMAP plot** (`png`): coloured by Louvain cluster number
- **Ranked genes** (`tabular`): top marker genes per cluster (Wilcoxon test)
- **Number of cells per cluster** (`tabular`): cluster size summary

**Verification steps:**
1. Check final AnnData `General Info` — confirm cell count matches your filtered
   barcode count (within ~5% for QC attrition)
2. Check cells-per-cluster — a single cluster containing >80% of cells at
   resolution 0.1 suggests either too-strict QC (too few cells), too-permissive
   cell calling (background barcodes dominating), or inappropriate resolution
3. Inspect the UMAP — distinct separated islands are a good sign; one large
   undifferentiated blob suggests re-visiting cell calling or QC parameters
