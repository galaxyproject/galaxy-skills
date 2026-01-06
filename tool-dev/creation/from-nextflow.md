# Creating a Tool from Nextflow

**This is a pointer document.**

---

## For Nextflow-to-Galaxy Conversion

If you're converting a Nextflow process to a Galaxy tool, use the **conversion skill**:

**Main guide**: `../../nf-to-galaxy/process-to-tool.md`

That guide covers:
- Extracting information from Nextflow processes
- Mapping Nextflow containers to bioconda packages
- Converting Nextflow inputs/outputs to Galaxy XML
- Nextflow-specific patterns and conventions

---

## Quick Reference

**Nextflow process** → **Galaxy tool XML**

| Nextflow Element | Galaxy Element | Guide |
|------------------|----------------|-------|
| `container` | `<requirements>` | `../../nf-to-galaxy/container-mapping.md` |
| `input: path(x)` | `<param type="data">` | `../../nf-to-galaxy/datatype-mapping.md` |
| `output: path(y)` | `<data>` | `../../nf-to-galaxy/datatype-mapping.md` |
| `script: """..."""` | `<command><![CDATA[...]]>` | `../../nf-to-galaxy/process-to-tool.md` |

---

## When to Use This vs Conversion Skill

**Use conversion skill** (`../../nf-to-galaxy/`) when:
- You have a Nextflow process to convert
- You're porting an nf-core module
- You need Nextflow-specific guidance

**Use tool-creation skill** (this directory) when:
- You're creating a tool from scratch (no Nextflow source)
- You need generic tool creation guidance
- You're wrapping a CLI tool directly

---

## After Conversion

Once you've created the tool XML from Nextflow, use these guides:

- **Testing**: `../shared/testing.md`
- **XML structure**: `../shared/xml-structure.md`
- **Help sections**: `../shared/help-sections.md`
- **Tool placement**: `tool-placement.md`

---

## Related

- **Main conversion guide**: `../../nf-to-galaxy/process-to-tool.md`
- **Conversion skill router**: `../../nf-to-galaxy/SKILL.md`
- **Generic tool creation**: `create-tool.md`
