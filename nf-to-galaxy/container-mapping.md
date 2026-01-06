# Container to Bioconda Mapping

Reference for mapping Nextflow container images to Galaxy requirements.

---

## Pattern

Nextflow container declarations follow this pattern:

```groovy
container 'biocontainers/<package>:<version>--<build_hash>'
```

Maps to Galaxy:

```xml
<requirement type="package" version="<version>"><package></requirement>
```

---

## Common Bioinformatics Tools

| Container Image | Bioconda Package | Version |
|-----------------|------------------|---------|
| `biocontainers/hyphy:2.5.84--hbee74ec_0` | `hyphy` | `2.5.84` |
| `biocontainers/iqtree:2.4.0--h503566f_0` | `iqtree` | `2.4.0` |
| `biocontainers/seqkit:2.3.1--h9ee0642_0` | `seqkit` | `2.3.1` |
| `biocontainers/mafft:7.520--h031d066_3` | `mafft` | `7.520` |
| `biocontainers/samtools:1.18--h50ea8bc_1` | `samtools` | `1.18` |
| `biocontainers/bcftools:1.18--h8b25389_0` | `bcftools` | `1.18` |
| `biocontainers/bwa:0.7.17--he4a0461_11` | `bwa` | `0.7.17` |
| `biocontainers/bowtie2:2.5.1--py310ha0a81b8_2` | `bowtie2` | `2.5.1` |
| `biocontainers/hisat2:2.2.1--h87f3376_5` | `hisat2` | `2.2.1` |
| `biocontainers/star:2.7.10b--h9ee0642_0` | `star` | `2.7.10b` |
| `biocontainers/fastp:0.23.4--hadf994f_2` | `fastp` | `0.23.4` |
| `biocontainers/fastqc:0.12.1--hdfd78af_0` | `fastqc` | `0.12.1` |
| `biocontainers/multiqc:1.19--pyhdfd78af_0` | `multiqc` | `1.19` |
| `biocontainers/biopython:1.81` | `biopython` | `1.81` |

---

## Extracting Package Info

### From Container String

```
biocontainers/hyphy:2.5.84--hbee74ec_0
            │      │       │
            │      │       └─ Build hash (ignore)
            │      └─ Version
            └─ Package name
```

### From environment.yml

Many nf-core modules include an `environment.yml`:

```yaml
channels:
  - conda-forge
  - bioconda
dependencies:
  - bioconda::hyphy=2.5.84
```

This directly gives you the bioconda package and version.

---

## Galaxy Requirements XML

### Single Package

```xml
<requirements>
    <requirement type="package" version="2.5.84">hyphy</requirement>
</requirements>
```

### Multiple Packages

```xml
<requirements>
    <requirement type="package" version="2.5.84">hyphy</requirement>
    <requirement type="package" version="1.81">biopython</requirement>
</requirements>
```

### Using Macros

For tools sharing requirements:

```xml
<!-- macros.xml -->
<xml name="requirements">
    <requirements>
        <requirement type="package" version="@TOOL_VERSION@">hyphy</requirement>
    </requirements>
</xml>

<!-- tool.xml -->
<expand macro="requirements"/>
```

---

## Version Handling

### Exact Version

```xml
<requirement type="package" version="2.5.84">hyphy</requirement>
```

### Version Token (Recommended)

```xml
<!-- macros.xml -->
<token name="@TOOL_VERSION@">2.5.84</token>
<token name="@VERSION_SUFFIX@">0</token>

<!-- tool.xml -->
<tool version="@TOOL_VERSION@+galaxy@VERSION_SUFFIX@">
```

---

## Checking Bioconda

### Search for Package

```bash
conda search -c bioconda hyphy
```

### Check Available Versions

Visit: https://bioconda.github.io/recipes/<package>/README.html

Or: https://anaconda.org/bioconda/<package>

---

## Docker vs Singularity

Nextflow often specifies both:

```groovy
container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/hyphy:2.5.84--hbee74ec_0' :
    'biocontainers/hyphy:2.5.84--hbee74ec_0' }"
```

Both map to the same bioconda package. Use the package name and version from either.

---

## Custom Containers

If a Nextflow process uses a custom container (not from biocontainers):

1. Check if the tool is available in bioconda
2. If not, check conda-forge
3. If not available, you may need to:
   - Create a bioconda recipe
   - Use a container requirement (less portable)
   - Bundle scripts directly in the tool

---

## CAPHEINE Container Mappings

| Module | Container | Bioconda Package |
|--------|-----------|------------------|
| HYPHY_* | `biocontainers/hyphy:2.5.84--hbee74ec_0` | `hyphy=2.5.84` |
| IQTREE | `biocontainers/iqtree:2.4.0--h503566f_0` | `iqtree=2.4.0` |
| SEQKIT_* | `biocontainers/seqkit:*` | `seqkit` |
| MULTIQC | `biocontainers/multiqc:*` | `multiqc` |

Custom tools (CAWLIGN, REMOVETERMINALSTOPCODON, DRHIP) would need their own requirements defined based on their dependencies (likely `biopython`, `pandas`, etc.).
