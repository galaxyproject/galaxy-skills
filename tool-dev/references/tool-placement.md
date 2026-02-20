# Galaxy Tool Placement Decision Guide

Where to create your Galaxy tool wrapper.

---

## Decision Tree

```
Where should I create this tool?

1. Check if tool already exists
   ├─ tools-iuc? → Use it!
   ├─ Other known repo? → Use it!
   └─ ToolShed? → Evaluate quality, use if good

2. Tool doesn't exist - where to create?
   ├─ Community-useful? → tools-iuc (preferred)
   ├─ Domain-specific? → Appropriate repo (genouest, bgruening, etc.)
   └─ Project-specific? → Custom/local
```

---

## Option 1: tools-iuc (Preferred)

**Repository**: https://github.com/galaxyproject/tools-iuc

**Create here when**:
- Tool is widely used in the community
- Tool is well-maintained upstream
- Tool would benefit multiple users
- Tool is not project-specific

**Advantages**:
- High quality, well-tested
- Actively maintained
- Available on usegalaxy.* servers
- Automatic CI/CD
- Community support

**Process**:
1. Check existing PRs — someone may already be working on it
2. Open an issue to discuss the tool before implementing
3. Fork the repository
4. Create tool following IUC guidelines (see `../SKILL.md`)
5. Submit PR
6. Address review feedback

**IUC requirements**:
- Follow directory structure: `tools/toolname/`
- Include `macros.xml` for version tokens
- Include comprehensive tests with `expect_num_outputs` and `assert_contents`
- Test data under 1 MB
- Write clear help section (`format="markdown"`)
- Add citations (`type="doi"`)
- Use `argument=` on CLI-mapped params
- Bioconda/conda-forge dependencies

---

## Option 2: Domain-Specific Repositories

| Repository | Focus | When to Use |
|------------|-------|-------------|
| **tools-iuc** | General bioinformatics | Default choice for community tools |
| **genouest/galaxy-tools** | Genomics, annotation | Genomics-specific tools (BRAKER3, etc.) |
| **bgruening/galaxytools** | Cheminformatics, misc | Chemistry, specialized tools |
| **ARTbio/tools-artbio** | RNA-seq, small RNA | RNA analysis tools |

---

## Option 3: Custom/Local Tools

**Create custom when**:
- Tool is project-specific
- Tool is not useful to broader community
- Quick prototyping needed
- Workflow-embedded tool is sufficient

### Standalone Custom Tool

```
my-project/
└── tools/
    └── mytool/
        ├── mytool.xml
        ├── macros.xml
        └── test-data/
```

Advantages: full control, fast iteration, no review process.
Disadvantages: not available to community, manual maintenance, no automatic CI/CD.

### Workflow-Embedded Tool

Tool definition embedded in workflow `.ga` file. Only for very simple tools (< 50 lines) used in a single workflow. Limited to expression tools.

---

## Evaluation Criteria

### Choose tools-iuc if:

- Tool is used by multiple research groups
- Tool is actively maintained upstream
- Tool has stable API/interface
- You can commit to maintaining it
- Tool follows bioinformatics best practices

### Choose custom if:

- Tool is project-specific
- Tool is experimental/prototype
- Tool is simple wrapper script
- No community benefit expected

---

## Quality Standards

Regardless of where you create the tool:

**Required**: valid XML structure, version information, at least one test case, help section, proper input/output definitions.

**Recommended**: multiple test cases, comprehensive help, citations, macros for version tokens, proper error handling.

**Best practice**: test data < 1 MB, flexible test assertions, clear parameter descriptions, sensible defaults.

---

## Migration Path

It's OK to start with a custom tool for development, then submit to tools-iuc once stable. This approach allows rapid iteration, proves tool usefulness, and results in better quality submissions.

---

## Related

- **Full tool development guide**: `../SKILL.md`
- **Testing guide**: `testing.md`
