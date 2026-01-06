# Writing Galaxy Tool Help Sections

## Format
Help sections use reStructuredText (RST) inside CDATA blocks.

## Template
```xml
<help><![CDATA[
.. class:: infomark

**What it does**

Brief description of what the tool does and when to use it.

**Inputs**

Describe required inputs and their formats.

**Options**

====================  ===============================================
Option                Description
====================  ===============================================
Option 1              What this option does
Option 2              What this option does
Another option        Longer description that explains the option
====================  ===============================================

**Outputs**

- **Output 1**: Description of this output
- **Output 2**: Description of this output

**Example**

Example workflow or usage::

    Step 1: Do this
    Step 2: Do that
    Result: Expected outcome

**Tips**

- Helpful tip 1
- Helpful tip 2

**Links**

- Documentation: https://example.com/docs
- Source code: https://github.com/org/repo

.. _tool_name: https://example.com
]]></help>
```

## RST Formatting Reference

### Headers
```rst
**Bold Header**

Section
-------

Subsection
~~~~~~~~~~
```

### Tables
```rst
=======  ===========
Column1  Column2
=======  ===========
Value1   Description
Value2   Description
=======  ===========
```

### Lists
```rst
- Bullet item
- Another item

1. Numbered item
2. Another item

- **Bold label**: Description
- **Another label**: Description
```

### Code Blocks
```rst
Inline ``code`` in text.

Code block::

    This is code
    Indented under ::
```

### Links
```rst
External link: https://example.com

Named link: `Link Text`_

.. _Link Text: https://example.com
```

### Info Box
```rst
.. class:: infomark

**Note**

This appears in an info box.
```

### Escaping
```rst
Underscore in URL: https://example.com/path\_with\_underscores
Backslash: \\
Asterisk: \*
```

## Best Practices

1. **Start with infomark** - Makes the "What it does" section stand out

2. **Use tables for options** - Much clearer than prose

3. **Include examples** - Users learn from examples

4. **Link to upstream docs** - Don't duplicate, reference

5. **Keep it scannable** - Headers, bullets, tables over paragraphs

6. **Escape special characters** - Especially `_` in URLs

## Examples from Good Tools

### HTSeq-count style
- Overview with external link
- Detailed mode explanations
- Output description
- Full options reference

### Query Tabular style
- Extensive examples with tables
- Step-by-step workflows
- Sample input/output data

## Common Issues

| Issue | Solution |
|-------|----------|
| Table not rendering | Ensure column widths match with `=` |
| Link broken | Use `\_` to escape underscores |
| Code not formatted | Ensure `::` and indentation |
| Info box not showing | Check `.. class:: infomark` syntax |
