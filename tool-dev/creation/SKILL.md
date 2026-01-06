# Galaxy Tool Creation Skill

**Purpose**: Guide for creating new Galaxy tool wrappers from scratch or from existing CLI tools.

---

## When to Use This Skill

Use this skill when you need to:
- Create a new Galaxy tool wrapper for a CLI tool
- Wrap a tool that doesn't have a Galaxy wrapper yet
- Create a tool from Nextflow process (see also: `../../nf-to-galaxy`)
- Build a custom tool for a specific workflow

**Not for**: Updating existing tools (see `../updates/`)

---

## Prerequisites

- Understanding of the CLI tool you're wrapping
- Access to tool documentation
- Basic XML knowledge
- Planemo installed (`pip install planemo`)

---

## Quick Decision Tree

```
What's your starting point?

├─ Converting arcane Nextflow process?
│  └─ See: ../../nf-to-galaxy/nf-process-to-galaxy-tool/SKILL.md
│
├─ Have CLI tool to wrap?
│  └─ Use: from-scratch.md
│
└─ Need to understand tool placement?
   └─ Use: tool-placement.md
```

---

## Core Workflow

1. **Understand the tool** - Read CLI docs, test locally
2. **Decide placement** - tools-iuc vs custom (see `tool-placement.md`)
3. **Create XML structure** - Use templates (see `../shared/xml-structure.md`)
4. **Map inputs/outputs** - CLI flags → Galaxy params
5. **Write command template** - Cheetah templating
6. **Add tests** - Required for validation (see `../shared/testing.md`)
7. **Write help** - RST format (see `../shared/help-sections.md`)
8. **Validate** - `planemo lint` and `planemo test`

---

## tools-iuc / IUC Targeting Guidance

If you decide the tool should be contributed to **tools-iuc**:

1. **Have a local tools-iuc clone available**
   - Follow the established directory structure and macros patterns.
   - Run `planemo` lint/tests locally before opening a PR.

2. **Prefer Bioconda for dependencies**
   - Use `<requirements>` with a Bioconda package whenever possible.
   - If no suitable Bioconda package exists, coordinate with the user about whether to add one.
     - In that case, having a local clone of `bioconda/bioconda-recipes` may be helpful for preparing a recipe PR.

3. **Scope the wrapper UI intentionally**
   - Prefer exposing the commonly used options needed for typical workflows.
   - Avoid mirroring every upstream flag; keep the Galaxy form usable.
   - Add advanced options only when they are widely used or necessary for correctness.

---

## Key Files

- **`create-tool.md`** - Main guide for creating tools
- **`from-scratch.md`** - Creating tool from CLI documentation
- **`from-nextflow.md`** - Pointer to conversion skill
- **`tool-placement.md`** - Where to create your tool (tools-iuc vs custom)
- **`examples/`** - Concrete examples

---

## Shared References

These are shared with `tool-updates/`:

- **`../shared/xml-structure.md`** - Galaxy XML anatomy
- **`../shared/testing.md`** - Planemo testing guide
- **`../shared/help-sections.md`** - RST help formatting

---

## Related Skills

- **`../../nf-to-galaxy/`** - Converting Nextflow to Galaxy (includes process-to-tool conversion)
- **`../updates/`** - Updating existing tools
- **`../../galaxy-integration/`** - Testing tools on Galaxy instances

---

## Examples

See `examples/` directory for:
- Simple single-input/output tool
- Multi-output tool with collections
- Tool with conditional parameters
