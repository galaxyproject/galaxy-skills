# Galaxy Tool Update Skill

## When to Use
User asks to update a Galaxy tool wrapper to a new version of the underlying CLI tool.

## Workflow

### 1. Identify Tool Files
```bash
# Find tool XML files
ls tools/{tool_name}/*.xml
```

Key files:
- `macros.xml` - Version token, shared components
- `{tool}.xml` - Main tool definition
- `test-data/` - Test input/output files

### 2. Research Upstream Changes
Before updating, check for breaking changes:

```bash
# Check conda-forge for latest version
# Visit: https://anaconda.org/conda-forge/{package}

# Check GitHub releases
# Visit: https://github.com/{org}/{repo}/releases

# Compare --help between versions if possible
```

Look for:
- Renamed flags
- Removed flags
- New required flags
- Changed default values
- Output format changes

### 3. Update Version
In `macros.xml`:
```xml
<token name="@TOOL_VERSION@">NEW_VERSION</token>
```

### 4. Review Command Section
Check `<command>` block for:
- Deprecated flags
- Incorrect variable access (especially in loops)
- Missing new required flags

Common bug - repeat element access:
```cheetah
# WRONG
#for item in $section.repeat:
    --flag '$section.item'
#end for

# CORRECT
#for item in $section.repeat:
    --flag '$item.param_name'
#end for
```

### 5. Review Outputs
Check `<outputs>` for:
- Correct filter conditions
- Matching filter values to include options

### 6. Update Help Section
If help is minimal, expand using RST format. See `../shared/help-sections.md`.

### 7. Run Tests
```bash
planemo test tools/{tool_name}/
```

### 8. Fix Test Failures
Analyze `tool_test_output.json`:
```python
import json
with open('tool_test_output.json') as f:
    data = json.load(f)
for t in data.get('tests', []):
    if t.get('data', {}).get('status') != 'success':
        print(f"{t.get('id')}: {t.get('data', {}).get('output_problems')}")
```

Common fixes:
- Use `min=` instead of exact counts for variable upstream data
- Update expected values if output format changed

### 9. Commit and Push
```bash
git add tools/{tool_name}/
git commit -m "Update {tool} to {version}

- Update version X.Y.Z → A.B.C
- Fix {bugs if any}
- Improve help section

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"

git push origin {branch}
```

## Checklist
- [ ] Check upstream for breaking changes
- [ ] Update version token
- [ ] Review command section for bugs
- [ ] Review output filters
- [ ] Update help section if needed
- [ ] Run planemo tests
- [ ] Fix any test failures
- [ ] Commit with descriptive message
- [ ] Push to remote
