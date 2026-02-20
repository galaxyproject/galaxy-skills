# Process to Tool Conversion Guide

Detailed guide for converting a single Nextflow process to a Galaxy tool XML.

---

## Before You Start

**ALWAYS create a plan first**:

1. Identify the Nextflow process
2. Check if Galaxy tool already exists (tools-iuc, GenOuest, ToolShed)
3. If creating new tool, determine where it should live:
   - See `tool-sources.md` for conversion context
   - See `../../tool-dev/references/tool-placement.md` for generic tool placement guidance
4. Present plan to user
5. Wait for approval
6. Implement

**Example**:
```
Plan: Convert HYPHY_FEL process to Galaxy tool

Analysis:
- Process: HYPHY_FEL from modules/local/hyphy/fel/main.nf
- Existing tool: Yes, in tools-iuc (hyphy_fel.xml)
- Action: Use existing tool, no conversion needed

Recommendation: Reference existing tools-iuc tool in workflow.
```

---

## Anatomy of a Nextflow Process

```groovy
process EXAMPLE_PROCESS {
    tag "$meta.id"                    // Logging tag
    label 'process_medium'            // Resource hints
    
    conda "${moduleDir}/environment.yml"
    container 'biocontainers/tool:1.0.0--hash'
    
    input:
    tuple val(meta), path(input_file)
    path(reference)
    val(option)
    
    output:
    tuple val(meta), path("*.output"), emit: result
    path "versions.yml", emit: versions
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args = task.ext.args ?: ''
    """
    tool_command \\
        --input $input_file \\
        --reference $reference \\
        --option $option \\
        $args
    """
    
    stub:
    """
    touch output.txt
    """
}
```

---

## Anatomy of a Galaxy Tool XML

```xml
<tool id="example_tool" name="Example Tool" version="1.0.0+galaxy0">
    <description>Brief description</description>
    <requirements>
        <requirement type="package" version="1.0.0">tool</requirement>
    </requirements>
    <version_command>tool --version</version_command>
    <command detect_errors="exit_code"><![CDATA[
tool_command
    --input '$input_file'
    --reference '$reference'
    --option '$option'
    $args
    ]]></command>
    <inputs>
        <param name="input_file" type="data" format="fasta" label="Input file"/>
        <param name="reference" type="data" format="fasta" label="Reference"/>
        <param name="option" type="select" label="Option">
            <option value="A">Option A</option>
            <option value="B">Option B</option>
        </param>
    </inputs>
    <outputs>
        <data name="result" format="txt" label="${tool.name} on ${on_string}"/>
    </outputs>
    <tests>...</tests>
    <help><![CDATA[...]]></help>
    <citations>...</citations>
</tool>
```

---

## Step-by-Step Conversion

### 1. Extract Container → Requirements

**From Nextflow**:
```groovy
container 'biocontainers/hyphy:2.5.84--hbee74ec_0'
```

**To Galaxy**:
```xml
<requirements>
    <requirement type="package" version="2.5.84">hyphy</requirement>
</requirements>
```

**Pattern**: `biocontainers/<package>:<version>--<hash>` 

Extract:
- Package name: `hyphy`
- Version: `2.5.84` (part before `--`)

### 2. Convert Inputs

#### File Inputs

**Nextflow**:
```groovy
input:
tuple val(meta), path(alignment), path(tree)
```

**Galaxy**:
```xml
<inputs>
    <param name="alignment" type="data" format="fasta" label="Alignment"/>
    <param name="tree" type="data" format="nhx,newick" label="Tree"/>
</inputs>
```

Notes:
- `val(meta)` is usually dropped (Galaxy handles metadata internally)
- `path(x)` becomes `type="data"`
- Format must be specified (see datatype-mapping.md)

#### Value Inputs

**Nextflow**:
```groovy
input:
val(option)
```

**Galaxy** (for string/enum):
```xml
<param name="option" type="select" label="Option">
    <option value="Yes">Yes</option>
    <option value="No">No</option>
</param>
```

**Galaxy** (for boolean):
```xml
<param name="option" type="boolean" truevalue="--flag" falsevalue="" label="Enable option"/>
```

**Galaxy** (for number):
```xml
<param name="threshold" type="float" value="0.05" min="0" max="1" label="P-value threshold"/>
```

#### Optional Inputs

**Nextflow** (implicit optional via empty channel):
```groovy
path(optional_file)
```

**Galaxy**:
```xml
<param name="optional_file" type="data" format="txt" optional="true" label="Optional file"/>
```

In command section:
```xml
#if $optional_file:
    --optional '$optional_file'
#end if
```

### 3. Convert Outputs

**Nextflow**:
```groovy
output:
tuple val(meta), path("FEL/${meta}.FEL.json"), emit: fel_json
path "versions.yml", emit: versions
```

**Galaxy**:
```xml
<outputs>
    <data name="fel_json" format="json" label="${tool.name} on ${on_string}"/>
</outputs>
```

Notes:
- `emit: name` becomes `name="name"`
- Output path patterns become simpler (Galaxy manages filenames)
- `versions.yml` is typically not captured (Galaxy has its own version tracking)

#### Dynamic Output Names

If the output filename depends on input:

**Galaxy** (using `from_work_dir`):
```xml
<data name="output" format="json" from_work_dir="FEL/*.json"/>
```

Or with explicit naming in command:
```xml
<command><![CDATA[
hyphy fel ... --output output.json
]]></command>
<outputs>
    <data name="output" format="json"/>
</outputs>
```

### 4. Convert Script to Command

**Nextflow**:
```groovy
script:
def args = task.ext.args ?: ''
"""
mkdir -p FEL

hyphy fel \\
    --alignment $alignment \\
    --tree $tree \\
    --srv Yes \\
    --output FEL/${meta}.FEL.json \\
    ${args}
"""
```

**Galaxy**:
```xml
<command detect_errors="exit_code"><![CDATA[
mkdir -p FEL &&

hyphy fel
    --alignment '$alignment'
    --tree '$tree'
    --srv Yes
    --output '$output'
]]></command>
```

Key transformations:
| Nextflow | Galaxy |
|----------|--------|
| `$variable` | `'$variable'` (quoted) |
| `${meta}` | Usually dropped or replaced with `$input.element_identifier` |
| `\\` continuation | Just newline (in CDATA) |
| `${args}` from config | Explicit params or advanced section |

### 5. Handle task.ext.args

Nextflow often uses `task.ext.args` for additional arguments configured externally.

**Galaxy approach**: Create an "Advanced" section with common options:

```xml
<inputs>
    <!-- Main inputs -->
    <param name="alignment" type="data" format="fasta" label="Alignment"/>
    
    <section name="advanced" title="Advanced Options" expanded="false">
        <param name="extra_args" type="text" value="" label="Additional arguments"
               help="Extra command-line arguments"/>
    </section>
</inputs>
<command><![CDATA[
hyphy fel
    --alignment '$alignment'
    $advanced.extra_args
]]></command>
```

Or expose specific options as params.

---

## Real Example: HYPHY_FEL

### Nextflow Process

```groovy
process HYPHY_FEL {
    tag "$meta"
    label 'process_medium'
    
    conda "${moduleDir}/environment.yml"
    container 'biocontainers/hyphy:2.5.84--hbee74ec_0'
    
    input:
    tuple val(meta), path(alignment), path(tree)
    
    output:
    tuple val(meta), path("FEL/${meta}.FEL.json"), emit: fel_json
    path "versions.yml", emit: versions
    
    script:
    def args = task.ext.args ?: ''
    """
    mkdir -p FEL
    
    hyphy fel \\
        --alignment $alignment \\
        --tree $tree \\
        --srv Yes \\
        --output FEL/${meta}.FEL.json \\
        ${args}
    """
}
```

### Galaxy Tool (Simplified)

```xml
<tool id="hyphy_fel" name="HyPhy-FEL" version="@TOOL_VERSION@+galaxy@VERSION_SUFFIX@">
    <description>Fixed Effects Likelihood for detecting selection</description>
    <macros>
        <import>macros.xml</import>
    </macros>
    <expand macro="requirements"/>
    <expand macro="version_command"/>
    <command detect_errors="exit_code"><![CDATA[
@SYMLINK_FILES@
hyphy fel
    --alignment '$alignment'
    --tree '$tree'
    --srv '$srv'
    --output '$output'
    ]]></command>
    <inputs>
        <expand macro="inputs"/>
        <param argument="--srv" type="select" label="Synonymous rate variation">
            <option value="Yes" selected="true">Yes</option>
            <option value="No">No</option>
        </param>
    </inputs>
    <outputs>
        <data name="output" format="hyphy_results.json"/>
    </outputs>
    <tests>
        <test>
            <param name="alignment" value="test.fasta"/>
            <param name="tree" value="test.nwk"/>
            <output name="output">
                <assert_contents>
                    <has_text text="FEL"/>
                </assert_contents>
            </output>
        </test>
    </tests>
    <help><![CDATA[
**FEL (Fixed Effects Likelihood)**

Estimates site-specific synonymous and non-synonymous substitution rates.

**Inputs**
- Alignment: Codon-aware FASTA alignment
- Tree: Phylogenetic tree in Newick format

**Outputs**
- JSON file with FEL results
    ]]></help>
    <expand macro="citations"/>
</tool>
```

---

## Checklist

- [ ] Container → `<requirements>` with correct package and version
- [ ] All `path()` inputs → `<param type="data">` with correct format
- [ ] All `val()` inputs → appropriate `<param>` type
- [ ] Output paths → `<data>` elements with correct format
- [ ] Script → `<command>` with proper quoting
- [ ] Variables wrapped in single quotes
- [ ] Conditionals converted to Cheetah `#if`/`#end if`
- [ ] Test case with expected outputs
- [ ] Help section with RST formatting
- [ ] Citations added

---

## Common Mistakes

### 1. Missing quotes around variables

❌ Wrong:
```xml
--input $input_file
```

✅ Correct:
```xml
--input '$input_file'
```

### 2. Using double quotes

❌ Wrong:
```xml
--input "$input_file"
```

✅ Correct:
```xml
--input '$input_file'
```

### 3. Forgetting CDATA wrapper

❌ Wrong:
```xml
<command>
hyphy fel < $input
</command>
```

✅ Correct:
```xml
<command detect_errors="exit_code"><![CDATA[
hyphy fel < '$input'
]]></command>
```

### 4. Wrong datatype format

Check Galaxy datatypes registry for correct format names:
- `fasta` not `fa`
- `nhx` or `newick` for trees
- `json` for JSON files
