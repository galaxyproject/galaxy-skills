# Galaxy Tool Sources & Options

Guide for deciding where to find or create Galaxy tools when converting from Nextflow.

---

## Tool Source Hierarchy

When converting a Nextflow process to Galaxy, follow this decision tree:

```
1. Check tools-iuc (preferred)
   └─► Found? Use it!
   
2. Check other known Galaxy tool repositories
   └─► Found? Use it!
   
3. Check Galaxy Main ToolShed
   └─► Found? Evaluate quality, use if good
   
4. Create custom tool
   └─► Workflow-embedded OR standalone XML
```

---

## Option 1: tools-iuc (Preferred)

**Repository**: https://github.com/galaxyproject/tools-iuc

**When to use**:
- Tool exists in tools-iuc
- Tool is actively maintained
- Tool follows IUC standards

**Advantages**:
- ✅ High quality, well-tested
- ✅ Actively maintained
- ✅ Available on usegalaxy.* servers
- ✅ Automatic CI/CD
- ✅ Community support

**How to reference**:
```xml
<!-- In workflow .ga file -->
"tool_id": "toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/hyphy_fel/2.5.84+galaxy0"
```

**Contributing**:
If tool doesn't exist but would be useful to community:
1. **Ask user** if they have access to tools-iuc or can clone it
2. Fork tools-iuc (if approved)
3. Create tool following IUC guidelines
4. Submit PR
5. Wait for review and merge

**When to suggest tools-iuc**:
- Tool is widely used in the community
- Tool is well-maintained upstream
- Tool would benefit multiple users
- Tool is not project-specific

**Example suggestion**:
```
"REMOVETERMINALSTOPCODON is a simple, reusable tool for viral genomics.
It would be valuable in tools-iuc. Do you have access to clone the 
tools-iuc repository? If so, I can create the tool there following
IUC standards. Otherwise, I'll create it as a custom tool."
```

**IUC tool examples**:
- HyPhy suite: `tools/hyphy/`
- IQ-TREE: `tools/iqtree/`
- SeqKit: `tools/seqkit/`
- Most mainstream bioinformatics tools

---

## Option 2: Known Galaxy Tool Repositories

### GenOuest Galaxy Tools

**Repository**: https://github.com/genouest/galaxy-tools

**When to use**:
- Tool exists in GenOuest repo
- Not available in tools-iuc
- Well-maintained tool

**Examples**:
- BRAKER3: `tools/braker3/`
- Various genomics tools

**How to reference**:
```xml
"tool_id": "toolshed.g2.bx.psu.edu/repos/genouest/braker3/braker3/3.0.8+galaxy0"
```

Or if installing locally:
```xml
"tool_id": "braker3"
```

### Other Known Repositories

| Repository | Focus | URL |
|------------|-------|-----|
| **tools-iuc** | General bioinformatics | https://github.com/galaxyproject/tools-iuc |
| **genouest/galaxy-tools** | Genomics, annotation | https://github.com/genouest/galaxy-tools |
| **bgruening/galaxytools** | Cheminformatics, misc | https://github.com/bgruening/galaxytools |
| **ARTbio/tools-artbio** | RNA-seq, small RNA | https://github.com/ARTbio/tools-artbio |
| **galaxyproject/tools-devteam** | Legacy core tools | https://github.com/galaxyproject/tools-devteam |

### Evaluating Repository Quality

✅ **Good signs**:
- Active maintenance (recent commits)
- CI/CD setup
- Test data included
- Clear documentation
- Available on ToolShed

⚠️ **Warning signs**:
- No commits in >1 year
- No tests
- Poor documentation
- Not on ToolShed

---

## Option 3: Galaxy Main ToolShed

**URL**: https://toolshed.g2.bx.psu.edu/

**When to use**:
- Tool exists on ToolShed
- Not in known repositories
- Need to evaluate quality

**How to search**:
1. Go to https://toolshed.g2.bx.psu.edu/
2. Search for tool name
3. Check repository owner, description, reviews

**Quality indicators**:
- ✅ Owner is known organization (IUC, GenOuest, etc.)
- ✅ Recent updates
- ✅ Good documentation
- ✅ Test data included
- ⚠️ Unknown owner
- ⚠️ No updates in years
- ⚠️ No tests

**How to reference**:
```xml
"tool_id": "toolshed.g2.bx.psu.edu/repos/OWNER/REPO/TOOL/VERSION"
```

---

## Option 4: Custom Tools

When no existing tool is available or suitable.

### 4a. Workflow-Embedded Tools

**What**: Tool definition embedded directly in workflow `.ga` file.

**When to use**:
- Simple, project-specific tool
- Not reusable outside this workflow
- Quick prototyping

**Advantages**:
- ✅ Self-contained workflow
- ✅ No separate tool installation
- ✅ Fast to create

**Disadvantages**:
- ❌ Not reusable
- ❌ Harder to maintain
- ❌ Limited testing options

**Example**:
```json
{
    "name": "My Workflow",
    "steps": {
        "0": {"type": "data_input"},
        "1": {
            "tool_id": null,
            "tool_type": "expression",
            "tool_state": {
                "expression": "import pandas as pd; ..."
            }
        }
    }
}
```

Or using tool shed install but with custom XML:
```json
"1": {
    "content_id": "custom_tool",
    "tool_shed_repository": {
        "changeset_revision": "local",
        "name": "custom_tool",
        "owner": "local",
        "tool_shed": "local"
    }
}
```

### 4b. Standalone Custom Tool

**What**: Full tool XML in separate file/repository.

**When to use**:
- Tool is reusable
- Tool is complex
- Want proper testing
- May contribute later

**Structure**:
```
my_custom_tools/
  my_tool/
    my_tool.xml
    my_tool.py          # If needed
    test-data/
      input.txt
      expected_output.txt
    .shed.yml           # If publishing to ToolShed
```

**Example tool XML**:
```xml
<tool id="my_custom_tool" name="My Custom Tool" version="1.0.0">
    <description>Does something specific</description>
    <requirements>
        <requirement type="package" version="1.0">some_package</requirement>
    </requirements>
    <command><![CDATA[
        python '$__tool_directory__/my_tool.py'
            --input '$input'
            --output '$output'
    ]]></command>
    <inputs>
        <param name="input" type="data" format="txt" label="Input file"/>
    </inputs>
    <outputs>
        <data name="output" format="txt" label="Output"/>
    </outputs>
    <tests>
        <test>
            <param name="input" value="input.txt"/>
            <output name="output" file="expected_output.txt"/>
        </test>
    </tests>
    <help><![CDATA[
        Tool help text here.
    ]]></help>
</tool>
```

**Advantages**:
- ✅ Reusable
- ✅ Testable with planemo
- ✅ Can contribute to community later
- ✅ Proper version control

**Disadvantages**:
- ❌ More setup required
- ❌ Need to install on Galaxy instance

---

## Decision Matrix

| Scenario | Recommended Option | Action Required |
|----------|-------------------|-----------------|
| Tool exists in tools-iuc | **Use tools-iuc** | No action needed |
| Tool exists in GenOuest/other known repo | **Use that repo** | No action needed |
| Tool on ToolShed, good quality | **Use ToolShed tool** | Verify quality first |
| Tool on ToolShed, poor quality | **Create custom** | Better to own quality |
| Simple script, workflow-specific | **Workflow-embedded** | Quick and contained |
| Complex tool, reusable | **Standalone custom** | Proper tool development |
| Tool could benefit community | **Create for tools-iuc** | **Ask user about access first** |

**Important**: Before creating any tool for tools-iuc:
1. Present analysis showing why tool belongs in tools-iuc
2. Ask if user has access to clone/fork tools-iuc
3. Wait for approval
4. Only then proceed with implementation

---

## CAPHEINE Example

### Existing Tools (Use as-is)

| Tool | Source | Tool ID |
|------|--------|---------|
| HyPhy FEL | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/...` |
| HyPhy MEME | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_meme/...` |
| IQ-TREE | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/iqtree/...` |
| SeqKit | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/seqkit_split2/...` |
| MultiQC | tools-iuc | `toolshed.g2.bx.psu.edu/repos/iuc/multiqc/...` |

### Custom Tools Needed

| Tool | Recommendation | Rationale |
|------|---------------|-----------|
| REMOVETERMINALSTOPCODON | Standalone custom | Simple, reusable for viral genomics |
| CAWLIGN | Check GenOuest first | Alignment tool, may exist |
| DRHIP | Standalone custom | CAPHEINE-specific aggregation |

**For REMOVETERMINALSTOPCODON**:
- Create in `tools/capheine/remove_terminal_stop_codon.xml`
- Simple Python script
- Could contribute to tools-iuc later

**For CAWLIGN**:
- Search GenOuest, ToolShed first
- If not found, create custom
- Potentially useful for other viral projects

**For DRHIP**:
- Create in `tools/capheine/drhip.xml`
- CAPHEINE-specific, unlikely to be in tools-iuc
- Keep as custom tool

---

## Workflow .ga Tool References

### Tools-iuc Tool

```json
"2": {
    "tool_id": "toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/hyphy_fel/2.5.84+galaxy0",
    "tool_version": "2.5.84+galaxy0",
    "tool_shed_repository": {
        "changeset_revision": "abcd1234",
        "name": "hyphy_fel",
        "owner": "iuc",
        "tool_shed": "toolshed.g2.bx.psu.edu"
    }
}
```

### GenOuest Tool

```json
"3": {
    "tool_id": "toolshed.g2.bx.psu.edu/repos/genouest/braker3/braker3/3.0.8+galaxy0",
    "tool_version": "3.0.8+galaxy0",
    "tool_shed_repository": {
        "changeset_revision": "xyz789",
        "name": "braker3",
        "owner": "genouest",
        "tool_shed": "toolshed.g2.bx.psu.edu"
    }
}
```

### Local Custom Tool

```json
"4": {
    "tool_id": "remove_terminal_stop_codon",
    "tool_version": "1.0.0",
    "tool_shed_repository": null
}
```

Or if in local ToolShed:
```json
"4": {
    "tool_id": "toolshed.local/repos/local/capheine_tools/remove_terminal_stop_codon/1.0.0",
    "tool_shed_repository": {
        "name": "capheine_tools",
        "owner": "local",
        "tool_shed": "toolshed.local"
    }
}
```

---

## Installing Tools

### From ToolShed (via Galaxy Admin)

1. Admin → Install and Uninstall → Search ToolShed
2. Search for tool
3. Install to Galaxy instance

### Custom Tools (Local)

**Option A**: Add to Galaxy's `tool_conf.xml`:
```xml
<toolbox>
    <section id="custom" name="Custom Tools">
        <tool file="custom_tools/my_tool/my_tool.xml"/>
    </section>
</toolbox>
```

**Option B**: Create local ToolShed repository:
```bash
planemo shed_init --name="capheine_tools" --owner="local"
planemo shed_create --shed_target=local
planemo shed_upload --shed_target=local
```

---

## Best Practices

### 1. Always Check tools-iuc First

```bash
# Search tools-iuc
cd tools-iuc
find . -name "*.xml" | xargs grep -l "tool_name"
```

### 2. Evaluate ToolShed Tools Carefully

- Check last update date
- Look for test data
- Read documentation
- Check owner reputation

### 3. Document Tool Sources

In your workflow documentation:
```markdown
## Tools Used

- HyPhy FEL: tools-iuc (toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel)
- BRAKER3: GenOuest (toolshed.g2.bx.psu.edu/repos/genouest/braker3)
- DRHIP: Custom (local, tools/capheine/drhip.xml)
```

### 4. Plan for Contribution

If creating custom tools that could benefit others:
- Follow IUC guidelines from the start
- Include comprehensive tests
- Write good documentation
- Plan to submit PR to tools-iuc

---

## Resources

- **tools-iuc**: https://github.com/galaxyproject/tools-iuc
- **GenOuest tools**: https://github.com/genouest/galaxy-tools
- **Main ToolShed**: https://toolshed.g2.bx.psu.edu/
- **IUC Standards**: https://galaxy-iuc-standards.readthedocs.io/
- **Planemo docs**: https://planemo.readthedocs.io/
- **Tool development**: https://docs.galaxyproject.org/en/latest/dev/schema.html
