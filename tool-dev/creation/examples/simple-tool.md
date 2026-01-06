# Simple Tool Example

Complete example of a minimal Galaxy tool wrapper.

---

## Scenario

Wrapping a simple CLI tool that converts FASTA to tabular format.

**Tool**: `fasta_to_tab`  
**Function**: Converts FASTA sequences to tab-delimited format  
**Input**: FASTA file  
**Output**: Tabular file (ID, sequence)

---

## CLI Usage

```bash
fasta_to_tab input.fasta > output.tsv
```

---

## Complete Tool XML

**File**: `tools/fasta_to_tab/fasta_to_tab.xml`

```xml
<tool id="fasta_to_tab" name="FASTA to Tabular" version="1.0.0+galaxy0">
    <description>Convert FASTA to tabular format</description>
    
    <requirements>
        <requirement type="package" version="1.0.0">fasta_utilities</requirement>
    </requirements>
    
    <version_command>fasta_to_tab --version</version_command>
    
    <command detect_errors="exit_code"><![CDATA[
fasta_to_tab '$input' > '$output'
    ]]></command>
    
    <inputs>
        <param name="input" type="data" format="fasta" label="Input FASTA file"/>
    </inputs>
    
    <outputs>
        <data name="output" format="tabular" label="${tool.name} on ${on_string}"/>
    </outputs>
    
    <tests>
        <test>
            <param name="input" value="test_input.fasta"/>
            <output name="output" file="test_output.tsv"/>
        </test>
    </tests>
    
    <help><![CDATA[
**What it does**

Converts FASTA format sequences to a tab-delimited table with two columns:
- Column 1: Sequence ID
- Column 2: Sequence

**Input**

FASTA file with one or more sequences.

**Output**

Tabular file with sequence IDs and sequences.

**Example**

Input FASTA::

    >seq1
    ATCGATCG
    >seq2
    GCTAGCTA

Output tabular::

    seq1    ATCGATCG
    seq2    GCTAGCTA
    ]]></help>
    
    <citations>
        <citation type="bibtex">@misc{fasta_utilities,
            title = {FASTA Utilities},
            url = {https://example.com/fasta_utilities}
        }</citation>
    </citations>
</tool>
```

---

## Test Data

**File**: `tools/fasta_to_tab/test-data/test_input.fasta`

```
>seq1
ATCGATCGATCG
>seq2
GCTAGCTAGCTA
>seq3
TTAATTAATTAA
```

**File**: `tools/fasta_to_tab/test-data/test_output.tsv`

```
seq1	ATCGATCGATCG
seq2	GCTAGCTAGCTA
seq3	TTAATTAATTAA
```

---

## Testing

```bash
# Lint
planemo lint tools/fasta_to_tab/fasta_to_tab.xml

# Test
planemo test tools/fasta_to_tab/fasta_to_tab.xml

# Serve
planemo serve tools/fasta_to_tab/fasta_to_tab.xml
```

---

## Key Points

1. **Simple structure**: Single input, single output
2. **Standard formats**: FASTA → tabular
3. **Minimal command**: Just redirect output
4. **Basic test**: One test case with expected output
5. **Clear help**: Example showing input/output format

---

## Variations

### With Optional Parameter

```xml
<inputs>
    <param name="input" type="data" format="fasta" label="Input FASTA file"/>
    <param name="include_description" type="boolean" truevalue="--desc" falsevalue="" 
           label="Include sequence descriptions"/>
</inputs>

<command detect_errors="exit_code"><![CDATA[
fasta_to_tab 
    $include_description
    '$input' 
    > '$output'
]]></command>
```

### With Format Selection

```xml
<inputs>
    <param name="input" type="data" format="fasta" label="Input FASTA file"/>
    <param name="delimiter" type="select" label="Delimiter">
        <option value="tab" selected="true">Tab</option>
        <option value="comma">Comma</option>
        <option value="space">Space</option>
    </param>
</inputs>

<command detect_errors="exit_code"><![CDATA[
fasta_to_tab 
    --delimiter '$delimiter'
    '$input' 
    > '$output'
]]></command>
```

---

## Related

- **Main guide**: `../create-tool.md`
- **Multi-output example**: `multi-output-tool.md`
- **XML structure**: `../../shared/xml-structure.md`
