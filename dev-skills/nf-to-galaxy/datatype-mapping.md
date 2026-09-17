# Nextflow to Galaxy Datatype Mapping

Reference for mapping Nextflow file patterns to Galaxy datatypes.

---

## Common Mappings

### Sequence Files

| Nextflow Pattern | Galaxy Datatype | Notes |
|------------------|-----------------|-------|
| `path('*.fasta')` | `fasta` | Standard FASTA |
| `path('*.fa')` | `fasta` | Alias |
| `path('*.fna')` | `fasta` | Nucleotide FASTA |
| `path('*.faa')` | `fasta` | Amino acid FASTA |
| `path('*.fastq')` | `fastqsanger` | FASTQ (Sanger encoding) |
| `path('*.fastq.gz')` | `fastqsanger.gz` | Compressed FASTQ |
| `path('*.fq')` | `fastqsanger` | Alias |
| `path('*.fq.gz')` | `fastqsanger.gz` | Alias |

### Alignment Files

| Nextflow Pattern | Galaxy Datatype | Notes |
|------------------|-----------------|-------|
| `path('*.bam')` | `bam` | Binary alignment |
| `path('*.sam')` | `sam` | Text alignment |
| `path('*.cram')` | `cram` | Compressed alignment |
| `path('*.aln')` | `fasta` | Often FASTA alignment |
| `path('*.phy')` | `phylip` | PHYLIP format |
| `path('*.nex')` | `nexus` | NEXUS format |

### Tree Files

| Nextflow Pattern | Galaxy Datatype | Notes |
|------------------|-----------------|-------|
| `path('*.treefile')` | `nhx` | IQ-TREE output (Newick) |
| `path('*.nwk')` | `newick` | Newick format |
| `path('*.newick')` | `newick` | Newick format |
| `path('*.tree')` | `nhx` | Generic tree |
| `path('*.contree')` | `nhx` | Consensus tree |

### Annotation Files

| Nextflow Pattern | Galaxy Datatype | Notes |
|------------------|-----------------|-------|
| `path('*.gff')` | `gff` | GFF2 format |
| `path('*.gff3')` | `gff3` | GFF3 format |
| `path('*.gtf')` | `gtf` | GTF format |
| `path('*.bed')` | `bed` | BED format |
| `path('*.vcf')` | `vcf` | VCF format |
| `path('*.vcf.gz')` | `vcf_bgzip` | Compressed VCF |

### Tabular Files

| Nextflow Pattern | Galaxy Datatype | Notes |
|------------------|-----------------|-------|
| `path('*.csv')` | `csv` | Comma-separated |
| `path('*.tsv')` | `tabular` | Tab-separated |
| `path('*.txt')` | `txt` | Plain text |
| `path('*.tab')` | `tabular` | Tab-separated |

### JSON/YAML

| Nextflow Pattern | Galaxy Datatype | Notes |
|------------------|-----------------|-------|
| `path('*.json')` | `json` | JSON format |
| `path('*.yml')` | `yaml` | YAML format |
| `path('*.yaml')` | `yaml` | YAML format |

### HyPhy-Specific

| Nextflow Pattern | Galaxy Datatype | Notes |
|------------------|-----------------|-------|
| `path('*.FEL.json')` | `hyphy_results.json` | FEL results |
| `path('*.MEME.json')` | `hyphy_results.json` | MEME results |
| `path('*.BUSTED.json')` | `hyphy_results.json` | BUSTED results |
| `path('*.RELAX.json')` | `hyphy_results.json` | RELAX results |

### Report Files

| Nextflow Pattern | Galaxy Datatype | Notes |
|------------------|-----------------|-------|
| `path('*.html')` | `html` | HTML report |
| `path('*.pdf')` | `pdf` | PDF document |
| `path('*.png')` | `png` | PNG image |
| `path('*.svg')` | `svg` | SVG image |

---

## Galaxy Format Strings in XML

Use these format strings in `<param>` and `<data>` elements:

```xml
<!-- Input param -->
<param name="input" type="data" format="fasta" label="Input FASTA"/>

<!-- Multiple formats accepted -->
<param name="input" type="data" format="fasta,fastq" label="Sequences"/>

<!-- Output data -->
<data name="output" format="json" label="Results"/>
```

---

## Format Auto-Detection

Galaxy can sometimes auto-detect formats. For outputs with variable format:

```xml
<data name="output" format="auto" label="Output">
    <discover_datasets pattern="(?P&lt;designation&gt;.+)\.(?P&lt;ext&gt;.+)" directory="output_dir"/>
</data>
```

---

## Compressed Files

Galaxy handles compressed files with compound datatypes:

| Compression | Suffix | Example |
|-------------|--------|---------|
| gzip | `.gz` | `fastqsanger.gz`, `vcf_bgzip` |
| bzip2 | `.bz2` | `fasta.bz2` |

---

## Collections

For Nextflow channels that produce multiple files (like scatter operations):

**Nextflow**:
```groovy
output:
path("*.fasta")  // Multiple files
```

**Galaxy**:
```xml
<collection name="fastas" type="list" label="FASTA files">
    <discover_datasets pattern="(?P&lt;designation&gt;.+)\.fasta" format="fasta"/>
</collection>
```

---

## Checking Available Datatypes

To see what datatypes your Galaxy instance supports:

```bash
# In Galaxy source
grep -r "class.*Datatype" lib/galaxy/datatypes/
```

Or via API / Admin UI → Datatypes registry.

---

## Custom Datatypes

If a Nextflow process produces a file type not in Galaxy:

1. Check if a similar type exists (often `txt` or `json` works)
2. Use generic type with metadata
3. Consider adding custom datatype to Galaxy (advanced)

For HyPhy JSON results, tools-iuc defines `hyphy_results.json` which includes Vision viewer support.
