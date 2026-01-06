# Galaxy Tool Update Skill

**Purpose**: Update existing Galaxy tool wrappers when underlying CLI tools release new versions.

---

## When to Use This Skill

Use this skill when you need to:
- Update a Galaxy tool to a new version
- Fix bugs in existing Galaxy tools
- Improve tool documentation
- Debug failing planemo tests

**Not for**: Creating new tools (see `../creation/`)

---

## Prerequisites

- Existing Galaxy tool XML
- Knowledge of new upstream version
- Planemo installed (`pip install planemo`)

---

## Quick Workflow

1. **Research upstream** - Check for breaking changes (see `research-upstream.md`)
2. **Update version** - Modify `@TOOL_VERSION@` token
3. **Review code** - Check command section, outputs, filters
4. **Fix bugs** - Common issues (see `common-bugs.md`)
5. **Update docs** - Expand help section if minimal (see `../shared/help-sections.md`)
6. **Test** - Run `planemo test`, analyze failures (see `../shared/testing.md`)
7. **Commit** - Use standard message format (see `commit-template.md`)

---

## Key Files

- **`update-tool.md`** - Main workflow, step-by-step process
- **`research-upstream.md`** - How to check for breaking changes
- **`common-bugs.md`** - Frequent bug patterns and fixes
- **`commit-template.md`** - Standard commit message formats

---

## Shared References

These are shared with `tool-creation/`:

- **`../shared/xml-structure.md`** - Galaxy XML anatomy
- **`../shared/testing.md`** - Planemo testing guide
- **`../shared/help-sections.md`** - RST help formatting

---

## Common Patterns

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

---

## Related Skills

- **`../creation/`** - Creating new tools
- **`../../nf-to-galaxy/`** - Converting Nextflow to Galaxy
- **`../../galaxy-integration/`** - Testing tools on Galaxy instances

---

## Origin

Created from ncbi-datasets-cli 18.5.1 → 18.13.0 update session.
