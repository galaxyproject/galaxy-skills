# Galaxy Tool XML Structure

## Overview
Galaxy tools are defined in XML files with specific sections.

## File Organization
```
tools/{tool_name}/
├── macros.xml           # Shared tokens and XML fragments
├── {tool}.xml           # Main tool definition
└── test-data/           # Test input/output files
```

## Macros File (macros.xml)

### Version Token
```xml
<macros>
    <token name="@TOOL_VERSION@">1.2.3</token>
    <token name="@VERSION_SUFFIX@">0</token>
</macros>
```

### Reusable XML Blocks
```xml
<xml name="requirements">
    <requirements>
        <requirement type="package" version="@TOOL_VERSION@">tool-name</requirement>
    </requirements>
</xml>
```

### Using Macros
```xml
<expand macro="requirements"/>
```

## Main Tool File

### Tool Header
```xml
<tool id="tool_id" name="Tool Name" version="@TOOL_VERSION@+galaxy@VERSION_SUFFIX@">
    <description>brief description</description>
    <macros>
        <import>macros.xml</import>
    </macros>
```

### Command Section
Cheetah template for CLI invocation:
```xml
<command><![CDATA[
tool_name
    --input '$input_file'
    #if $optional_param:
        --optional '$optional_param'
    #end if
    #for item in $repeat_section:
        --repeated '$item.value'
    #end for
    > '$output'
]]></command>
```

### Inputs Section
```xml
<inputs>
    <!-- Simple param -->
    <param name="input" type="data" format="fasta" label="Input file"/>

    <!-- Select -->
    <param name="mode" type="select" label="Mode">
        <option value="fast">Fast</option>
        <option value="accurate" selected="true">Accurate</option>
    </param>

    <!-- Conditional -->
    <conditional name="cond">
        <param name="selector" type="select">
            <option value="yes">Yes</option>
            <option value="no">No</option>
        </param>
        <when value="yes">
            <param name="extra" type="text"/>
        </when>
        <when value="no"/>
    </conditional>

    <!-- Repeat -->
    <repeat name="filters" title="Add filter">
        <param name="filter_value" type="text"/>
    </repeat>

    <!-- Section -->
    <section name="advanced" title="Advanced Options">
        <param name="threads" type="integer" value="4"/>
    </section>
</inputs>
```

### Outputs Section
```xml
<outputs>
    <!-- Simple output -->
    <data name="output" format="tabular" label="Results"/>

    <!-- Conditional output -->
    <data name="optional_out" format="txt">
        <filter>condition['param'] == 'value'</filter>
    </data>

    <!-- Collection -->
    <collection name="results" type="list" label="Results">
        <discover_datasets pattern="(?P&lt;identifier_0&gt;.*)\.txt" ext="txt"/>
    </collection>
</outputs>
```

### Tests Section
```xml
<tests>
    <test expect_num_outputs="2">
        <param name="input" value="test_input.fasta"/>
        <output name="output">
            <assert_contents>
                <has_text text="expected"/>
                <has_n_lines min="10"/>
            </assert_contents>
        </output>
    </test>
</tests>
```

### Help Section
```xml
<help><![CDATA[
.. class:: infomark

**What it does**

Description here.

**Links**

- Documentation: https://example.com
]]></help>
```

## Common Cheetah Patterns

### Variable Access
```cheetah
$simple_param
$section.param
$conditional.param
```

### Loop Over Repeat
```cheetah
#for item in $section.repeat_name:
    --flag '$item.param_inside_repeat'
#end for
```

### Conditionals
```cheetah
#if $param:
    --flag '$param'
#end if

#if str($param) != '':
    --flag '$param'
#end if

#if $param == 'value':
    --specific-flag
#end if
```

### Multiple Values
```cheetah
#if $multi_select:
    --values #echo ",".join($multi_select)
#end if
```
