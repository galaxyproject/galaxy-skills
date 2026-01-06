# Skill Plan: Galaxy Tool Updates

## Purpose
Automate and standardize the process of updating Galaxy tool wrappers when underlying CLI tools release new versions.

## Skill Components

### 1. `update-tool.md` - Main Skill File
Entry point that orchestrates the update workflow.

**Triggers**: User asks to update a Galaxy tool to a new version

**Workflow**:
1. Identify tool files (XML, macros, test-data)
2. Check upstream for version changes and breaking changes
3. Update version tokens
4. Identify and fix bugs
5. Improve documentation if needed
6. Run tests and fix failures
7. Commit and push

---

### 2. `research-upstream.md` - Upstream Research
How to check for breaking changes in CLI tools.

**Content**:
- Check GitHub releases/changelog
- Compare `--help` output between versions
- Search for migration guides
- Check conda-forge for latest version
- Identify renamed/removed/added flags

**Key URLs**:
- conda-forge: `https://anaconda.org/conda-forge/{package}`
- GitHub releases: `https://github.com/{org}/{repo}/releases`

---

### 3. `xml-structure.md` - Galaxy XML Anatomy
Reference for Galaxy tool XML structure.

**Sections**:
- `<macros>` - Version tokens, reusable components
- `<requirements>` - Conda dependencies
- `<command>` - Cheetah template for CLI invocation
- `<inputs>` - Parameters, conditionals, sections, repeats
- `<outputs>` - Output files and collections
- `<tests>` - Test cases
- `<help>` - RST-formatted documentation

**Common Patterns**:
```xml
<!-- Version in macros.xml -->
<token name="@TOOL_VERSION@">X.Y.Z</token>

<!-- Repeat element access -->
#for item in $section.repeat_name:
    --flag '$item.param_name'
#end for

<!-- Conditional output filter -->
<filter>condition['param'] and "value" in condition['param']</filter>
```

---

### 4. `help-sections.md` - Writing Help Documentation
Best practices for Galaxy tool help sections.

**Format**: reStructuredText (RST) in CDATA blocks

**Template**:
```xml
<help><![CDATA[
.. class:: infomark

**What it does**

Brief description of the tool.

**Options**

=============  ==========================
Option         Description
=============  ==========================
Option 1       What it does
Option 2       What it does
=============  ==========================

**Outputs**

- **Output 1**: Description
- **Output 2**: Description

**Examples**

Example usage::

    Input: value
    Output: result

**Links**

- Documentation: URL
- Source: URL

.. _tool: URL
]]></help>
```

**Guidelines**:
- Use `.. class:: infomark` for info box
- Tables for structured options
- `::` for code blocks
- Escape underscores in URLs: `\_`
- Link references at bottom

---

### 5. `testing.md` - Test Best Practices
How to write and fix Galaxy tool tests.

**Running Tests**:
```bash
planemo test tools/tool_name/
```

**Test Structure**:
```xml
<test expect_num_outputs="N">
    <param name="input" value="test.txt"/>
    <output name="output">
        <assert_contents>
            <has_text text="expected"/>
            <has_n_lines min="10"/>  <!-- Use min for variable data -->
        </assert_contents>
    </output>
</test>
```

**Common Issues**:
- Exact counts fail when upstream data changes → use `min=`
- Collection counts: use `min="N"` not `count="N"`
- Test numbering is 0-indexed

**Analyzing Failures**:
```bash
# Extract failures from JSON
python3 << 'EOF'
import json
with open('tool_test_output.json') as f:
    data = json.load(f)
for t in data.get('tests', []):
    if t.get('data', {}).get('status') != 'success':
        print(f"{t.get('id')}: {t.get('data', {}).get('output_problems')}")
EOF
```

---

### 6. `common-bugs.md` - Common Bug Patterns
Bugs frequently found in Galaxy tools.

| Pattern | Bug | Fix |
|---------|-----|-----|
| Repeat access | `$repeat_name` | `$item.param_name` in loop |
| Wrong filter | Filter checks wrong value | Match filter to output |
| Typos | "amnio" vs "amino" | Spell check |
| Cheetah vars | `$filters.var` in loop | `$loop_var` |

---

### 7. `commit-template.md` - Commit Message Format
Standard commit message for tool updates.

```
Update {tool} to {version}, fix bugs, improve help

- Update version X.Y.Z → A.B.C
- Fix {bug description}
- Expand help sections
- Add/update tests

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

---

## File Structure
```
skills/tool-updates/
├── PLAN.md              # This file
├── update-tool.md       # Main skill entry point
├── research-upstream.md # Version research procedures
├── xml-structure.md     # Galaxy XML reference
├── help-sections.md     # Help documentation guide
├── testing.md           # Test writing and debugging
├── common-bugs.md       # Bug pattern catalog
└── commit-template.md   # Commit message format
```

---

## Example Invocations

```
"Update ncbi-datasets tools to latest version"
"Check if there are breaking changes in samtools 1.20"
"Fix the help section for this Galaxy tool"
"The planemo tests are failing, help me fix them"
```

---

## Dependencies
- `planemo` - Galaxy tool testing
- `conda` - Package version checking
- Web access - Upstream documentation

---

## Next Steps
1. Review this plan
2. Create individual skill files
3. Test with real tool updates
