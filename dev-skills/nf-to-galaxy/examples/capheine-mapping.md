# CAPHEINE Pipeline → Galaxy Mapping

Real-world example of mapping the CAPHEINE Nextflow pipeline to Galaxy tools.

---

## Pipeline Overview

CAPHEINE performs comparative analysis of pathogen and host evolution.

**Main workflow stages**:
1. Preprocessing (alignment, deduplication, tree building)
2. HyPhy selection analyses
3. Result aggregation (DRHIP)
4. Reporting (MultiQC)

---

## Tool Availability

| NF Module | Galaxy Tool | Status | Source | Tool ID |
|-----------|-------------|--------|--------|---------|
| `REMOVETERMINALSTOPCODON` | `remove_terminal_stop_codons` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/remove_terminal_stop_codons/...` |
| `SEQKIT_SPLIT` | `seqkit_split2` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/seqkit_split2/...` |
| `CAWLIGN` | `cawlign` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/cawlign/...` |
| `REMOVEAMBIGSEQS` | `hyphy_strike_ambigs` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_strike_ambigs/...` |
| `HYPHY_CLN` | `hyphy_cln` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_cln/...` |
| `IQTREE` | `iqtree` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/iqtree/...` |
| `HYPHY_LABELTREE_*` | `hyphy_annotate` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_annotate/...` |
| `HYPHY_FEL` | `hyphy_fel` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/...` |
| `HYPHY_MEME` | `hyphy_meme` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_meme/...` |
| `HYPHY_PRIME` | `hyphy_prime` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_prime/...` |
| `HYPHY_BUSTED` | `hyphy_busted` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_busted/...` |
| `HYPHY_CONTRASTFEL` | `hyphy_cfel` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_cfel/...` |
| `HYPHY_RELAX` | `hyphy_relax` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_relax/...` |
| `DRHIP` | `drhip` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/drhip/...` |
| `MULTIQC` | `multiqc` | ✅ Exists | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/multiqc/...` |

**Coverage**: 15/15 tools exist (100%), 0 custom tools needed ✅

**Tool Source Strategy**:
✅ ALL tools exist in tools-iuc - no custom tool creation required
✅ Conversion is purely workflow assembly using existing tools

---

## Preprocessing Subworkflow

### PROCESS_VIRAL_NONRECOMBINANT

```
Input: reference_genes.fasta, unaligned_sequences.fasta
       [optional: foreground_list, foreground_regexp]

┌─────────────────────────────────────┐
│  REMOVETERMINALSTOPCODON            │  🔲 Custom
│  Remove stop codons from reference  │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  SEQKIT_SPLIT                       │  ✅ seqkit_split2
│  Split reference into genes         │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  CAWLIGN                            │  🔲 Custom
│  Codon-aware alignment              │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  REMOVEAMBIGSEQS                    │  ✅ hyphy_strike_ambigs
│  Remove sequences with ambigs       │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  HYPHY_CLN                          │  ✅ hyphy_cln
│  Deduplicate sequences              │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  IQTREE                             │  ✅ iqtree
│  Build phylogenetic tree            │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  HYPHY_LABELTREE_*                  │  ✅ hyphy_annotate
│  Label foreground/background        │
│  (if foreground provided)           │
└─────────────────┬───────────────────┘
                  │
                  ▼
Output: deduplicated alignment, labeled tree
```

---

## HyPhy Analyses Subworkflow

### HYPHY_ANALYSES

All run in parallel on the same alignment + tree:

```
Input: alignment, tree
         │
         ├───► HYPHY_FEL ────────► fel.json        ✅ hyphy_fel
         │
         ├───► HYPHY_MEME ───────► meme.json       ✅ hyphy_meme
         │
         ├───► HYPHY_PRIME ──────► prime.json      ✅ hyphy_prime
         │
         ├───► HYPHY_BUSTED ─────► busted.json     ✅ hyphy_busted
         │
         │  (if foreground provided)
         ├───► HYPHY_CONTRASTFEL ► cfel.json       ✅ hyphy_cfel
         │
         └───► HYPHY_RELAX ──────► relax.json      ✅ hyphy_relax
```

---

## Specific Module Mappings

### HYPHY_FEL

**Nextflow** (`modules/local/hyphy/fel/main.nf`):
```groovy
process HYPHY_FEL {
    container 'biocontainers/hyphy:2.5.84--hbee74ec_0'
    
    input:
    tuple val(meta), path(alignment), path(tree)
    
    output:
    tuple val(meta), path("FEL/${meta}.FEL.json"), emit: fel_json
    
    script:
    """
    hyphy fel \\
        --alignment $alignment \\
        --tree $tree \\
        --srv Yes \\
        --output FEL/${meta}.FEL.json
    """
}
```

**Galaxy** (`tools/hyphy/hyphy_fel.xml`):
- Tool exists in tools-iuc
- Key params: alignment, tree, srv (synonymous rate variation)
- Output: JSON with site-by-site results

**Mapping notes**:
- `--srv Yes` is exposed as a select param in Galaxy
- Galaxy version has many more options exposed
- Output format is same JSON structure

### IQTREE

**Nextflow** (`modules/nf-core/iqtree/main.nf`):
```groovy
process IQTREE {
    container 'biocontainers/iqtree:2.4.0--h503566f_0'
    
    input:
    tuple val(meta), path(alignment), path(tree)
    // ... many optional inputs
    
    output:
    tuple val(meta), path("*.treefile"), emit: phylogeny
    // ... many optional outputs
    
    script:
    """
    iqtree -s ${alignment} -pre $prefix -nt AUTO ...
    """
}
```

**Galaxy** (`tools/iqtree/iqtree.xml`):
- Comprehensive tool with most IQ-TREE options
- CAPHEINE uses simple invocation, Galaxy tool can do same
- Key outputs: treefile, log

### HYPHY_LABELTREE

**Nextflow** (`modules/local/hyphy/labeltree/main.nf`):
- Labels tree branches as "Foreground" or "Reference"
- Uses regexp or list to identify foreground

**Galaxy** (`tools/hyphy/hyphy_annotate.xml`):
- Same functionality
- Params: tree, regexp/list, label name, internal/leaf options

---

## Custom Tools Needed

### 1. REMOVETERMINALSTOPCODON

Simple tool to remove terminal stop codons from FASTA.

**Input**: FASTA file
**Output**: Cleaned FASTA file
**Implementation**: Python script

```python
# Core logic from CAPHEINE bin/remove_terminal_stop_codon.py
from Bio import SeqIO
stop_codons = ['TAA', 'TAG', 'TGA']
for record in SeqIO.parse(input_fasta, "fasta"):
    seq = str(record.seq)
    if seq[-3:].upper() in stop_codons:
        seq = seq[:-3]
    # write cleaned sequence
```

### 2. CAWLIGN

Codon-aware aligner for viral sequences.

**Inputs**: Reference gene FASTA, unaligned sequences FASTA
**Output**: Aligned FASTA
**Implementation**: Calls `bealign` or similar

### 3. DRHIP

Aggregates HyPhy results into summary CSVs.

**Inputs**: Multiple HyPhy JSON files (FEL, MEME, PRIME, BUSTED, etc.)
**Outputs**: Summary CSV, sites CSV, comparison CSVs
**Implementation**: Python script parsing HyPhy JSON

---

## Galaxy Workflow Structure

The Galaxy workflow would be structured as:

```
Inputs:
  - reference_genes (fasta)
  - unaligned_seqs (fasta)
  - foreground_list (optional, txt)
  - foreground_regexp (optional, text)

Step 1: remove_terminal_stop_codon (reference_genes)
Step 2: seqkit_split2 (step1.output)
Step 3: cawlign (step2.outputs, unaligned_seqs)  # runs on each gene
Step 4: hyphy_strike_ambigs (step3.output)
Step 5: hyphy_cln (step4.output)
Step 6: iqtree (step5.output)
Step 7: hyphy_annotate (step6.tree, foreground)  # if foreground provided

# Parallel analyses on each gene's (alignment, tree)
Step 8a: hyphy_fel (step5.alignment, step7.tree)
Step 8b: hyphy_meme (step5.alignment, step7.tree)
Step 8c: hyphy_prime (step5.alignment, step7.tree)
Step 8d: hyphy_busted (step5.alignment, step7.tree)
Step 8e: hyphy_cfel (step5.alignment, step7.tree)  # if foreground
Step 8f: hyphy_relax (step5.alignment, step7.tree)  # if foreground

Step 9: drhip (step8*.outputs)  # aggregate results

Outputs:
  - summary.csv
  - sites.csv
  - per-gene JSON results
```

---

## Key Differences from Nextflow

1. **Parallelization**: Galaxy handles multiple genes via dataset collections
2. **Conditionals**: Limited in Galaxy workflows; may need workflow variants
3. **Meta propagation**: Galaxy uses dataset names/identifiers instead of `meta`
4. **Resource allocation**: Handled by Galaxy admin, not in tool XML

---

## Testing Strategy

1. **Unit tests**: Each tool tested with planemo
2. **Integration test**: Run workflow on CAPHEINE test data
3. **Comparison**: Compare Galaxy outputs to Nextflow outputs
4. **MCP validation**: Use galaxy-mcp to run tools and validate outputs programmatically
