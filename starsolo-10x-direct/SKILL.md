---
name: starsolo-10x-direct
description: Run STARsolo alignment for 10x Genomics scRNA-seq data directly as a tool, bypassing the IWC fastq-to-matrix workflow. Use when the IWC workflow fails or when you need precise control over soloBarcodeReadLength and chemistry parameters.
user_invocable: true
---

# STARsolo 10x Direct Alignment

Run STARsolo for 10x Genomics single-cell RNA-seq data directly via the Galaxy
tool API, bypassing the IWC `fastq-to-matrix-10x` workflow.

## When to Use

Use this skill when:
- The IWC `fastq-to-matrix-10x-scrna-seq-fastq-to-matrix-10x-v3` workflow fails
  with barcode detection errors (17 bp barcodes detected instead of 28 bp)
- You need `soloBarcodeReadLength = 0` (do not match barcode size to read size),
  which is required for all standard 10x v2/v3 libraries
- You need explicit control over STARsolo chemistry parameters

**Do NOT use the IWC workflow** if you observe log messages like
`Solo: CB 17bp` — this is the signature of the boolean-wiring bug in the
workflow. Use this skill instead.

## Your Input

```
$ARGUMENTS
```

Typical arguments: history ID, genome reference (indexed or FASTA+GTF URLs),
paired FASTQ collection, chemistry (v2 or v3), barcode whitelist file.

---

## Common Pitfalls (READ FIRST)

### 1. soloBarcodeReadLength Must Be 0 for Standard Libraries

The `soloBarcodeReadLength` parameter tells STARsolo whether to check that the
barcode occupies the full read length. For all standard 10x v2/v3 libraries the
barcode is shorter than the read, so this **must be set to `0` (disabled)**.

```python
# CORRECT — barcode is NOT full read length (standard 10x v2/v3)
inputs["sc|soloBarcodeReadLength"] = "0"     # falsevalue in the XML

# WRONG — causes STARsolo to detect only 17 bp barcodes for v3
inputs["sc|soloBarcodeReadLength"] = "1"
# or
inputs["sc|soloBarcodeReadLength"] = "true"   # string "true" is also wrong
```

The IWC workflow bug: the workflow wires this as a user-facing boolean parameter
input but the boolean is not reliably marshalled; when running directly via the
Galaxy tool API, pass `"0"` explicitly.

### 2. Chemistry Parameters for v3

For 10x Chromium v3 chemistry, the parameters are:
- `sc|params|chemistry`: `"Cv3"`
- CB length: 16 bp, UMI length: 12 bp (set automatically by `Cv3` preset)

For v2: `"Cv2"` (CB 16 bp, UMI 10 bp).

### 3. Input Collection Format

STARsolo expects a **paired** dataset collection (`list:paired`), not two
separate FASTQ files. The collection must have R1 (barcode+UMI read) as the
forward element and R2 (cDNA read) as the reverse element.

```python
inputs = {
    "sc|input_types|use": "list_paired",
    "sc|input_types|input_collection": {"src": "hdca", "id": collection_id},
}
```

### 4. Solo Type

For 10x data: `sc|solo_type` = `"CB_UMI_Simple"`.

---

## Step-by-Step

### 1. Verify inputs are ready

- Confirm the paired FASTQ collection exists and has state `ok`
- Confirm the indexed genome is available (e.g. `mm10`, `hg38`, `dm6`) or that
  FASTA + GTF URLs are known

### 2. Set STARsolo parameters

```python
tool_id = "toolshed.g2.bx.psu.edu/repos/iuc/rna_starsolo/rna_starsolo/2.7.11b+galaxy0"

inputs = {
    # Reference — indexed genome
    "refGenomeSource|geneSource": "indexed",
    "refGenomeSource|GTFconditional|GTFselect": "without-gtf-with-gtf",
    "refGenomeSource|GTFconditional|genomeDir": GENOME_BUILD,
    "refGenomeSource|GTFconditional|sjdbGTFfile": {"src": "hda", "id": GTF_HID},

    # 10x chemistry
    "sc|solo_type": "CB_UMI_Simple",
    "sc|input_types|use": "list_paired",
    "sc|input_types|input_collection": {"values": [{"src": "hdca", "id": COLLECTION_ID}]},
    "sc|soloCBwhitelist": {"src": "hda", "id": WHITELIST_HID},
    "sc|params|chemistry": "Cv3",                  # or "Cv2"
    "sc|soloBarcodeReadLength": "0",               # CRITICAL — disable for standard libraries
    "sc|soloCBmatchWLtype": "1MM_multi",
    "sc|umidedup|soloUMIdedup": "1MM_CR",
}
```

### 3. Run and verify

After the job completes, confirm:
- Log output (`output_log`) contains `Solo: CB 16bp` (not 17bp)
- Genes, barcodes, matrix outputs all reach state `ok`
- Matrix has realistic dimensions (genes × barcodes, where barcodes is in the
  expected range for your sample)

---

## Output Datatypes Note

STARsolo outputs:
- `output_genes`: `tsv` datatype
- `output_barcodes`: `tsv` datatype
- `output_matrix`: `mtx` datatype

The downstream Scanpy clustering workflow expects the genes file as `tabular`,
not `tsv`. After STARsolo completes, you may need to **change the datatype** of
the genes output from `tsv` to `tabular` before it can be selected as a Scanpy
workflow input. Do this via Edit Attributes → Datatype in the Galaxy UI.
