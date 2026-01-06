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
- ✅ High quality, well-tested
- ✅ Actively maintained
- ✅ Available on usegalaxy.* servers
- ✅ Automatic CI/CD
- ✅ Community support

**Process**:
1. Check if you have access to tools-iuc
2. Fork the repository
3. Create tool following IUC guidelines
4. Submit PR
5. Wait for review and merge

**IUC Guidelines**:
- Follow directory structure: `tools/toolname/`
- Include `macros.xml` for version tokens
- Include comprehensive tests
- Include test data (keep files small)
- Write clear help section
- Add citations

---

## Option 2: Domain-Specific Repositories

### GenOuest Galaxy Tools

**Repository**: https://github.com/genouest/galaxy-tools

**Use for**:
- Genomics and annotation tools
- Tools specific to genomics workflows

**Examples**:
- BRAKER3
- Various annotation tools

### bgruening/galaxytools

**Repository**: https://github.com/bgruening/galaxytools

**Use for**:
- Cheminformatics tools
- Miscellaneous bioinformatics tools

### ARTbio/tools-artbio

**Repository**: https://github.com/ARTbio/tools-artbio

**Use for**:
- RNA-seq tools
- Small RNA analysis

### Summary Table

| Repository | Focus | When to Use |
|------------|-------|-------------|
| **tools-iuc** | General bioinformatics | Default choice for community tools |
| **genouest/galaxy-tools** | Genomics, annotation | Genomics-specific tools |
| **bgruening/galaxytools** | Cheminformatics, misc | Chemistry, specialized tools |
| **ARTbio/tools-artbio** | RNA-seq, small RNA | RNA analysis tools |

---

## Option 3: Custom/Local Tools

**Create custom when**:
- Tool is project-specific
- Tool is not useful to broader community
- Quick prototyping needed
- Workflow-embedded tool is sufficient

### 3a. Standalone Custom Tool

**Structure**:
```
my-project/
└── tools/
    └── mytool/
        ├── mytool.xml
        ├── macros.xml
        └── test-data/
```

**Advantages**:
- ✅ Full control
- ✅ Fast iteration
- ✅ No review process

**Disadvantages**:
- ❌ Not available to community
- ❌ Manual maintenance
- ❌ No automatic CI/CD

### 3b. Workflow-Embedded Tool

**What**: Tool definition embedded in workflow `.ga` file

**When to use**:
- Very simple tool (< 50 lines)
- Only used in this specific workflow
- Quick prototyping

**Advantages**:
- ✅ Self-contained
- ✅ No separate installation

**Disadvantages**:
- ❌ Not reusable
- ❌ Harder to test
- ❌ Limited to expression tools

---

## Evaluation Criteria

### Choose tools-iuc if:

- [ ] Tool is used by multiple research groups
- [ ] Tool is actively maintained upstream
- [ ] Tool has stable API/interface
- [ ] You can commit to maintaining it
- [ ] Tool follows bioinformatics best practices

### Choose domain-specific repo if:

- [ ] Tool fits specific domain (genomics, cheminformatics, etc.)
- [ ] Domain repo is actively maintained
- [ ] Tool would benefit that community
- [ ] tools-iuc is not appropriate

### Choose custom if:

- [ ] Tool is project-specific
- [ ] Tool is experimental/prototype
- [ ] Tool is simple wrapper script
- [ ] No community benefit expected

---

## Quality Standards

Regardless of where you create the tool, maintain these standards:

**Required**:
- ✅ Valid XML structure
- ✅ Version information
- ✅ At least one test case
- ✅ Help section with usage
- ✅ Proper input/output definitions

**Recommended**:
- ✅ Multiple test cases
- ✅ Comprehensive help with examples
- ✅ Citations
- ✅ Macros for version tokens
- ✅ Proper error handling

**Best Practice**:
- ✅ Test data < 1MB
- ✅ Flexible test assertions
- ✅ Clear parameter descriptions
- ✅ Sensible defaults
- ✅ Good documentation

---

## Contributing to tools-iuc

### Before You Start

1. **Check existing PRs**: Someone may already be working on it
2. **Open an issue**: Discuss the tool before implementing
3. **Read guidelines**: https://github.com/galaxyproject/tools-iuc/blob/master/CONTRIBUTING.md

### Submission Process

1. Fork tools-iuc
2. Create branch: `git checkout -b add-mytool`
3. Create tool in `tools/mytool/`
4. Test thoroughly: `planemo test tools/mytool/`
5. Commit with clear message
6. Push and create PR
7. Address review feedback
8. Wait for merge

### Common Review Feedback

- Add more test cases
- Reduce test data size
- Improve help section
- Add citations
- Fix linting issues
- Update to latest tool version

---

## Migration Path

**Start custom → Move to tools-iuc later**

It's OK to:
1. Create custom tool for initial development
2. Test and refine in your workflows
3. Submit to tools-iuc once stable

This approach:
- ✅ Allows rapid iteration
- ✅ Proves tool usefulness
- ✅ Results in better quality submission

---

## Related

- **Creating tools**: `create-tool.md`
- **From scratch**: `from-scratch.md`
- **From Nextflow**: `from-nextflow.md`
- **XML structure**: `../shared/xml-structure.md`
