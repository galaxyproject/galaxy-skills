# Creating a Tool from Scratch

Guide for creating a Galaxy tool when you have a CLI tool but no existing wrapper.

---

## Starting Point

You have:
- A CLI tool (installed via conda/bioconda or available as binary)
- Tool documentation (man page, --help output, or online docs)
- Example usage and test data

You need:
- Galaxy tool XML wrapper

---

## Step-by-Step Process

### 1. Understand the Tool

```bash
# Get help
mytool --help
mytool -h
man mytool

# Test locally
mytool --input example.txt --output result.txt

# Check version
mytool --version
```

**Document**:
- All input types (files, parameters)
- All output types
- Required vs optional parameters
- Default values
- Version information

### 2. Check Bioconda

```bash
# Search for package
conda search mytool

# Or check online
# https://anaconda.org/bioconda/mytool
```

If not in bioconda, you may need to:
- Create a bioconda recipe first
- Use a container instead
- Install via other means (not recommended)

### 3. Map CLI to Galaxy

**Example CLI**:
```bash
mytool \
    --input data.fasta \
    --reference ref.fasta \
    --output results.txt \
    --threads 4 \
    --quality-threshold 30 \
    --verbose
```

**Map to Galaxy**:

| CLI Flag | Galaxy Element | Type | Notes |
|----------|---------------|------|-------|
| `--input` | `<param name="input">` | `data` | Required input file |
| `--reference` | `<param name="reference">` | `data` | Required reference |
| `--output` | `<data name="output">` | output | Result file |
| `--threads` | `\$GALAXY_SLOTS` | automatic | Use Galaxy's thread allocation |
| `--quality-threshold` | `<param name="quality">` | `integer` | Optional parameter |
| `--verbose` | `<param name="verbose">` | `boolean` | Optional flag |

### 4. Determine File Formats

Map file extensions to Galaxy datatypes:

| File Extension | Galaxy Datatype |
|----------------|-----------------|
| `.fasta`, `.fa` | `fasta` |
| `.fastq`, `.fq` | `fastqsanger` |
| `.bam` | `bam` |
| `.vcf` | `vcf` |
| `.txt`, `.tsv` | `tabular` |
| `.json` | `json` |

**See**: `../../nf-to-galaxy/datatype-mapping.md` for complete list

### 5. Create Tool Structure

Follow the main guide: `create-tool.md`

**Minimal working example**:

```xml
<tool id="mytool" name="MyTool" version="1.0.0+galaxy0">
    <description>Process sequences</description>
    
    <requirements>
        <requirement type="package" version="1.0.0">mytool</requirement>
    </requirements>
    
    <command detect_errors="exit_code"><![CDATA[
mytool
    --input '$input'
    --reference '$reference'
    --output '$output'
    --threads \$GALAXY_SLOTS
    #if $quality:
        --quality-threshold $quality
    #end if
    $verbose
    ]]></command>
    
    <inputs>
        <param name="input" type="data" format="fasta" label="Input sequences"/>
        <param name="reference" type="data" format="fasta" label="Reference"/>
        <param name="quality" type="integer" optional="true" min="0" max="100" 
               label="Quality threshold"/>
        <param name="verbose" type="boolean" truevalue="--verbose" falsevalue="" 
               label="Verbose output"/>
    </inputs>
    
    <outputs>
        <data name="output" format="tabular" label="${tool.name} on ${on_string}"/>
    </outputs>
    
    <tests>
        <test>
            <param name="input" value="test_input.fasta"/>
            <param name="reference" value="test_ref.fasta"/>
            <output name="output" file="expected_output.txt"/>
        </test>
    </tests>
    
    <help><![CDATA[
**What it does**

MyTool processes sequences against a reference.

**Inputs**

- Input sequences (FASTA)
- Reference sequences (FASTA)

**Outputs**

- Results table (tabular)
    ]]></help>
    
    <citations>
        <citation type="doi">10.1234/mytool.doi</citation>
    </citations>
</tool>
```

### 6. Handle Complex Cases

#### Multiple Input Files

```xml
<inputs>
    <param name="input1" type="data" format="fasta" label="First input"/>
    <param name="input2" type="data" format="fasta" label="Second input"/>
</inputs>
```

#### Optional Outputs

```xml
<outputs>
    <data name="output" format="txt" label="Main output"/>
    <data name="log" format="txt" label="Log file">
        <filter>advanced['create_log']</filter>
    </data>
</outputs>
```

#### Collections

```xml
<inputs>
    <param name="input_collection" type="data_collection" collection_type="list" 
           format="fasta" label="Input collection"/>
</inputs>

<outputs>
    <collection name="output_collection" type="list" label="Results">
        <discover_datasets pattern="__name__" directory="outputs" format="txt"/>
    </collection>
</outputs>
```

### 7. Test Thoroughly

```bash
# Lint
planemo lint mytool.xml

# Test
planemo test mytool.xml

# Serve and test manually
planemo serve mytool.xml
```

**Create multiple test cases**:
- Basic functionality
- Optional parameters
- Edge cases (empty files, large files)
- Different input formats

---

## Common Pitfalls

### 1. Incorrect Quoting

**Wrong**:
```xml
--input $input
```

**Right**:
```xml
--input '$input'
```

### 2. Missing CDATA

**Wrong**:
```xml
<command>
mytool --input '$input' > '$output'
</command>
```

**Right**:
```xml
<command><![CDATA[
mytool --input '$input' > '$output'
]]></command>
```

### 3. Hardcoded Threads

**Wrong**:
```xml
--threads 4
```

**Right**:
```xml
--threads \$GALAXY_SLOTS
```

### 4. Missing Test Data

- Always include test data in `test-data/` directory
- Keep test files small (< 1MB)
- Use realistic but minimal examples

---

## Next Steps

1. **Validate**: `planemo lint mytool.xml`
2. **Test**: `planemo test mytool.xml`
3. **Document**: Add comprehensive help section
4. **Submit**: Create PR to tools-iuc (if appropriate)

---

## Related

- **Main guide**: `create-tool.md`
- **XML structure**: `../shared/xml-structure.md`
- **Testing**: `../shared/testing.md`
- **Tool placement**: `tool-placement.md`
