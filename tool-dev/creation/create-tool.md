# Creating a Galaxy Tool

Complete guide for creating a new Galaxy tool wrapper.

---

## Before You Start

### 1. Understand Your Tool

- Read the CLI tool's documentation
- Test the tool locally with example data
- Identify all inputs, outputs, and parameters
- Note version information

### 2. Decide Where to Create

See `tool-placement.md` for decision guidance:
- **tools-iuc** (preferred for community tools)
- **Other known repos** (genouest, bgruening, etc.)
- **Custom/local** (project-specific tools)

### 3. Gather Requirements

- Tool name and version
- Bioconda package name (if available)
- Input/output file formats
- Required parameters
- Optional parameters

---

## Tool Creation Workflow

### Step 1: Create Directory Structure

```bash
# For tools-iuc or similar repo
cd tools/
mkdir mytool
cd mytool

# Create files
touch mytool.xml
touch macros.xml
mkdir test-data
```

### Step 2: Create macros.xml

```xml
<macros>
    <token name="@TOOL_VERSION@">1.0.0</token>
    <token name="@VERSION_SUFFIX@">0</token>
    
    <xml name="requirements">
        <requirements>
            <requirement type="package" version="@TOOL_VERSION@">mytool</requirement>
        </requirements>
    </xml>
</macros>
```

**See**: `../shared/xml-structure.md` for complete XML reference

### Step 3: Create Tool XML Header

```xml
<tool id="mytool" name="MyTool" version="@TOOL_VERSION@+galaxy@VERSION_SUFFIX@">
    <description>Brief description of what the tool does</description>
    
    <macros>
        <import>macros.xml</import>
    </macros>
    
    <expand macro="requirements"/>
    
    <version_command>mytool --version</version_command>
```

### Step 4: Map CLI to Galaxy Parameters

**Example CLI**:
```bash
mytool --input file.txt --output result.txt --threads 4 --mode fast
```

**Galaxy inputs**:
```xml
<inputs>
    <param name="input" type="data" format="txt" label="Input file"/>
    
    <param name="threads" type="integer" value="4" min="1" max="32" 
           label="Number of threads"/>
    
    <param name="mode" type="select" label="Processing mode">
        <option value="fast">Fast</option>
        <option value="accurate" selected="true">Accurate</option>
    </param>
</inputs>
```

### Step 5: Define Outputs

```xml
<outputs>
    <data name="output" format="txt" label="${tool.name} on ${on_string}: Result"/>
</outputs>
```

### Step 6: Write Command Template

```xml
<command detect_errors="exit_code"><![CDATA[
mytool
    --input '$input'
    --output '$output'
    --threads \$GALAXY_SLOTS
    --mode '$mode'
]]></command>
```

**Key points**:
- Use single quotes around Galaxy variables: `'$input'`
- Use `\$GALAXY_SLOTS` for thread count
- Use `<![CDATA[...]]>` to avoid XML escaping issues

### Step 7: Add Tests

**See**: `../shared/testing.md` for complete testing guide

```xml
<tests>
    <test expect_num_outputs="1">
        <param name="input" value="test_input.txt"/>
        <param name="mode" value="fast"/>
        <output name="output">
            <assert_contents>
                <has_text text="expected output"/>
            </assert_contents>
        </output>
    </test>
</tests>
```

### Step 8: Write Help Section

**See**: `../shared/help-sections.md` for RST formatting guide

```xml
<help><![CDATA[
**What it does**

MyTool performs analysis on input files.

**Inputs**

- Input file: Text file containing data

**Outputs**

- Result file: Processed data

**Options**

- Mode: Choose between fast and accurate processing
- Threads: Number of parallel threads to use
]]></help>
```

### Step 9: Add Citations

```xml
<citations>
    <citation type="doi">10.1234/example.doi</citation>
</citations>
```

### Step 10: Validate and Test

```bash
# Lint (check XML structure)
planemo lint mytool.xml

# Test
planemo test mytool.xml

# Serve locally to test in Galaxy UI
planemo serve mytool.xml
```

---

## Complete Example

See `examples/simple-tool.md` for a complete working example.

---

## Common Patterns

### Conditional Parameters

```xml
<conditional name="advanced">
    <param name="show" type="select" label="Advanced options">
        <option value="no">No</option>
        <option value="yes">Yes</option>
    </param>
    <when value="yes">
        <param name="extra_param" type="integer" value="10" label="Extra parameter"/>
    </when>
</conditional>
```

### Repeat Elements

```xml
<repeat name="filters" title="Filter">
    <param name="filter_value" type="text" label="Filter value"/>
</repeat>
```

In command:
```xml
#for $filter in $filters:
    --filter '$filter.filter_value'
#end for
```

### Multiple Outputs

```xml
<outputs>
    <data name="output1" format="txt" label="Primary output"/>
    <data name="output2" format="txt" label="Secondary output"/>
    <collection name="results" type="list" label="Result collection">
        <discover_datasets pattern="__name__" directory="outputs"/>
    </collection>
</outputs>
```

---

## Troubleshooting

### Tool doesn't appear in Galaxy

- Check XML is valid: `planemo lint`
- Ensure tool is in tool_conf.xml (if not using planemo serve)
- Restart Galaxy

### Tests failing

- Check test data is in test-data/ directory
- Verify expected outputs match actual outputs
- Use `--update_test_data` to regenerate expected outputs (carefully!)

### Command errors

- Check quoting: use single quotes around variables
- Check Cheetah syntax: `#if`, `#for`, etc.
- Test command locally first

---

## Next Steps

After creating your tool:

1. **Test thoroughly** - Multiple test cases, edge cases
2. **Document well** - Clear help section, examples
3. **Submit PR** (if tools-iuc) - Follow IUC guidelines
4. **Maintain** - Update when upstream tool updates

---

## Related Documentation

- **XML structure**: `../shared/xml-structure.md`
- **Testing**: `../shared/testing.md`
- **Help formatting**: `../shared/help-sections.md`
- **Tool placement**: `tool-placement.md`
- **From Nextflow**: `from-nextflow.md`
