# Galaxy Tool Creation

Create new Galaxy tool wrappers for CLI tools.

---

## Quick Start

**New to tool creation?** Start here:

1. **Read**: `SKILL.md` - Overview and decision tree
2. **Choose your path**:
   - From CLI tool → `from-scratch.md`
   - From Nextflow → `from-nextflow.md` (pointer to conversion skill)
3. **Decide placement**: `tool-placement.md` (tools-iuc vs custom)
4. **Create tool**: `create-tool.md` (main guide)

---

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main router and overview |
| `create-tool.md` | Complete tool creation workflow |
| `from-scratch.md` | Creating tool from CLI documentation |
| `from-nextflow.md` | Pointer to conversion skill |
| `tool-placement.md` | Where to create tools (tools-iuc, custom, etc.) |
| `examples/` | Concrete examples |

---

## Shared References

Tool creation and tool updates share common references:

- **`../shared/xml-structure.md`** - Galaxy XML anatomy
- **`../shared/testing.md`** - Planemo testing guide  
- **`../shared/help-sections.md`** - RST help formatting

---

## Common Workflow

```bash
# 1. Create tool directory
mkdir -p tools/mytool

# 2. Create tool XML
# See create-tool.md for structure

# 3. Validate
planemo lint tools/mytool/mytool.xml

# 4. Add tests
# See ../shared/testing.md

# 5. Test
planemo test tools/mytool/mytool.xml
```

---

## When to Use tools-iuc

Create in tools-iuc when:
- Tool is widely used in the community
- Tool is well-maintained upstream
- Tool would benefit multiple users
- Tool is not project-specific

See `tool-placement.md` for complete decision guide.

---

## Related

- **Nextflow conversion**: `../../nf-to-galaxy/process-to-tool.md`
- **Tool updates**: `../updates/`
- **Testing on Galaxy**: `../../galaxy-integration/`
