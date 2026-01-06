# Galaxy Tool Update Skill

Skill for updating Galaxy tool wrappers when underlying CLI tools release new versions.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main router and overview |
| `update-tool.md` | Main workflow - step-by-step update process |
| `research-upstream.md` | How to check for breaking changes |
| `common-bugs.md` | Frequent bug patterns and fixes |
| `commit-template.md` | Standard commit message formats |

### Shared References

These files are shared with `tool-creation/`:

| File | Purpose |
|------|---------|
| `../shared/xml-structure.md` | Galaxy XML anatomy reference |
| `../shared/help-sections.md` | RST documentation formatting |
| `../shared/testing.md` | Planemo test writing and debugging |

## Usage

Invoke when user asks to:
- Update a Galaxy tool to a new version
- Fix Galaxy tool bugs
- Improve Galaxy tool documentation
- Debug failing planemo tests

## Workflow Summary

1. **Research** - Check upstream for breaking changes
2. **Update version** - Modify `@TOOL_VERSION@` token
3. **Review code** - Check command section, outputs, filters
4. **Fix bugs** - Common issues: repeat access, wrong filters
5. **Update docs** - Expand help section if minimal
6. **Test** - Run `planemo test`, analyze failures
7. **Commit** - Use standard message format

## Key Patterns

### Repeat Element Access
```cheetah
#for item in $section.repeat_name:
    --flag '$item.param_name'
#end for
```

### Flexible Test Assertions
```xml
<has_n_lines min="100"/>
<output_collection min="5">
```

## Origin

Created from ncbi-datasets-cli 18.5.1 → 18.13.0 update session.
