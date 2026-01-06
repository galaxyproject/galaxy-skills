# Multi-Output Tool Example

Example of a tool with multiple outputs and conditional outputs.

---

## Scenario

Wrapping a sequence analysis tool that produces multiple output files.

**Tool**: `seq_analyzer`  
**Function**: Analyzes sequences and produces statistics, filtered sequences, and optional log  
**Inputs**: FASTA file, quality threshold  
**Outputs**: Statistics (tabular), filtered sequences (FASTA), optional log (txt)

---

## CLI Usage

```bash
seq_analyzer \
    --input sequences.fasta \
    --quality 30 \
    --stats stats.tsv \
    --filtered filtered.fasta \
    --log analysis.log
```

---

## Complete Tool XML

```xml
<tool id="seq_analyzer" name="Sequence Analyzer" version="2.1.0+galaxy0">
    <description>Analyze and filter sequences</description>
    
    <requirements>
        <requirement type="package" version="2.1.0">seq_analyzer</requirement>
    </requirements>
    
    <command detect_errors="exit_code"><![CDATA[
seq_analyzer
    --input '$input'
    --quality $quality
    --stats '$stats'
    --filtered '$filtered'
    #if $advanced.create_log:
        --log '$log'
    #end if
    ]]></command>
    
    <inputs>
        <param name="input" type="data" format="fasta" label="Input sequences"/>
        
        <param name="quality" type="integer" value="30" min="0" max="100"
               label="Quality threshold"/>
        
        <section name="advanced" title="Advanced Options" expanded="false">
            <param name="create_log" type="boolean" truevalue="true" falsevalue="false"
                   label="Create detailed log file"/>
        </section>
    </inputs>
    
    <outputs>
        <data name="stats" format="tabular" label="${tool.name} on ${on_string}: Statistics"/>
        
        <data name="filtered" format="fasta" label="${tool.name} on ${on_string}: Filtered sequences"/>
        
        <data name="log" format="txt" label="${tool.name} on ${on_string}: Log">
            <filter>advanced['create_log']</filter>
        </data>
    </outputs>
    
    <tests>
        <test expect_num_outputs="2">
            <param name="input" value="test_input.fasta"/>
            <param name="quality" value="30"/>
            <output name="stats">
                <assert_contents>
                    <has_n_columns n="3"/>
                    <has_line_matching expression="^ID\tLength\tQuality$"/>
                </assert_contents>
            </output>
            <output name="filtered" file="test_filtered.fasta"/>
        </test>
        
        <test expect_num_outputs="3">
            <param name="input" value="test_input.fasta"/>
            <param name="quality" value="20"/>
            <param name="create_log" value="true"/>
            <output name="stats" file="test_stats_q20.tsv"/>
            <output name="filtered" file="test_filtered_q20.fasta"/>
            <output name="log">
                <assert_contents>
                    <has_text text="Analysis complete"/>
                </assert_contents>
            </output>
        </test>
    </tests>
    
    <help><![CDATA[
**What it does**

Analyzes sequence quality and filters sequences based on quality threshold.

**Inputs**

- Input sequences (FASTA)
- Quality threshold (0-100)

**Outputs**

1. **Statistics** (tabular): Quality metrics for each sequence
   
   - Column 1: Sequence ID
   - Column 2: Sequence length
   - Column 3: Quality score

2. **Filtered sequences** (FASTA): Sequences passing quality threshold

3. **Log** (optional, text): Detailed analysis log

**Example**

Input::

    >seq1
    ATCGATCG
    >seq2
    GCTAGCTA
    >seq3
    NNNNNNNN

Statistics output::

    ID      Length  Quality
    seq1    8       95
    seq2    8       92
    seq3    8       10

Filtered output (quality > 30)::

    >seq1
    ATCGATCG
    >seq2
    GCTAGCTA
    ]]></help>
    
    <citations>
        <citation type="doi">10.1234/seq_analyzer</citation>
    </citations>
</tool>
```

---

## Key Features

### 1. Multiple Outputs

```xml
<outputs>
    <data name="stats" format="tabular" label="..."/>
    <data name="filtered" format="fasta" label="..."/>
    <data name="log" format="txt" label="...">
        <filter>...</filter>
    </data>
</outputs>
```

### 2. Conditional Output

```xml
<data name="log" format="txt" label="...">
    <filter>advanced['create_log']</filter>
</data>
```

Only created if `advanced.create_log` is true.

### 3. Section for Advanced Options

```xml
<section name="advanced" title="Advanced Options" expanded="false">
    <param name="create_log" type="boolean" .../>
</section>
```

Keeps UI clean by hiding advanced options.

### 4. Multiple Test Cases

```xml
<test expect_num_outputs="2">
    <!-- Test without log -->
</test>

<test expect_num_outputs="3">
    <!-- Test with log -->
</test>
```

Test both scenarios: with and without optional output.

### 5. Flexible Assertions

```xml
<assert_contents>
    <has_n_columns n="3"/>
    <has_line_matching expression="^ID\tLength\tQuality$"/>
</assert_contents>
```

Test structure without exact content matching.

---

## Output Collections Example

For tools that produce multiple related files:

```xml
<outputs>
    <collection name="results" type="list" label="Analysis results">
        <discover_datasets pattern="__name__" directory="outputs" format="txt"/>
    </collection>
</outputs>
```

In command:
```xml
<command><![CDATA[
mkdir outputs &&
seq_analyzer --input '$input' --outdir outputs
]]></command>
```

---

## Related

- **Simple example**: `simple-tool.md`
- **Main guide**: `../create-tool.md`
- **Testing**: `../../shared/testing.md`
