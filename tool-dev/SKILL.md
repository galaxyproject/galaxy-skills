# Galaxy Tool Development Skill

**Purpose**: Router for Galaxy tool development tasks - creating new tools or updating existing tools.

---

## When to Use This Skill

Use this skill family when you need to:
- Create a new Galaxy tool wrapper
- Update an existing Galaxy tool to a new version
- Fix bugs in Galaxy tools
- Improve tool documentation or tests
- Work with Galaxy tool XML structure

---

## Decision Tree

### Creating New Tools?

If you need to:
- Wrap a CLI tool that doesn't have a Galaxy wrapper yet
- Create a tool from scratch
- Convert a Nextflow process to a Galaxy tool
- Decide where to place a new tool (tools-iuc vs custom)

**→ Use: `creation/SKILL.md`**

---

### Updating Existing Tools?

If you need to:
- Update a Galaxy tool to a new version
- Fix bugs in existing tool wrappers
- Debug failing planemo tests
- Improve help sections or documentation
- Research upstream changes

**→ Use: `updates/SKILL.md`**

---

### Need Reference Material?

If you need to understand:
- Galaxy XML structure and syntax
- How to write planemo tests
- RST help section formatting

**→ See: `shared/` directory**
- `shared/xml-structure.md` - Galaxy XML anatomy
- `shared/testing.md` - Planemo testing guide
- `shared/help-sections.md` - RST help formatting

---

## Skill Structure

```
tool-dev/
├── SKILL.md              # This router file
├── creation/             # Creating new Galaxy tools
│   ├── SKILL.md
│   ├── create-tool.md
│   ├── from-scratch.md
│   ├── from-nextflow.md
│   ├── tool-placement.md
│   └── examples/
├── updates/              # Updating existing Galaxy tools
│   ├── SKILL.md
│   ├── update-tool.md
│   ├── research-upstream.md
│   ├── common-bugs.md
│   └── commit-template.md
└── shared/               # Shared references
    ├── xml-structure.md
    ├── testing.md
    └── help-sections.md
```

---

## Related Skills

- **`../nf-to-galaxy/`** - Converting Nextflow to Galaxy (includes process-to-tool conversion)
- **`../galaxy-integration/`** - Testing tools on Galaxy instances

---

## Quick Start

**New tool?** → `creation/SKILL.md`

**Update tool?** → `updates/SKILL.md`

**Need XML help?** → `shared/xml-structure.md`

**Need testing help?** → `shared/testing.md`
