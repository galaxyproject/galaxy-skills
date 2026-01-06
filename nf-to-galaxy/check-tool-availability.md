# Tool Availability Checker

Systematic guide for checking if a Galaxy tool exists before creating a new one.

---

## Quick Reference

**When a tool is not available on your Galaxy instance**, check in this order:
1. **Local tools-iuc clone** (if exists) - Can install to instance
2. **tools-iuc on GitHub** - Can install to instance
3. **Known Galaxy tool repositories** - May be installable
4. **Galaxy Main ToolShed** - May be installable
5. **Web search** (last resort)

**IMPORTANT**: If a tool is not on your Galaxy instance but exists in tools-iuc, the user can:
- Install it to their Galaxy instance (if they have admin access)
- Request their Galaxy admin to install it
- Use it in workflows by referencing the tool ID from tools-iuc

**Always check tools-iuc before concluding a tool is "missing"!**

---

## 1. Check Local tools-iuc Clone

**Common locations**:
- `~/Documents/brc-analytics/tools-iuc/`
- `~/galaxy/tools-iuc/`
- `~/tools-iuc/`
- Current workspace subdirectories

**How to check**:
```bash
# Search for tool by name
find /path/to/tools-iuc/tools -name "*tool_name*" -type d

# Search XML files for tool content
grep -r "tool_name" /path/to/tools-iuc/tools --include="*.xml"

# List all tools
ls /path/to/tools-iuc/tools/
```

**Advantages**:
- ✅ Fastest
- ✅ Most authoritative
- ✅ Can see exact implementation
- ✅ Can check if tool needs updates

---

## 2. Check tools-iuc on GitHub

**URL**: https://github.com/galaxyproject/tools-iuc

**Search methods**:

### Method A: GitHub Code Search
1. Go to https://github.com/galaxyproject/tools-iuc
2. Press `/` to open search
3. Search for tool name
4. Filter by "Code" to see XML files

**Direct search URL pattern**:
```
https://github.com/galaxyproject/tools-iuc/search?q=TOOL_NAME
```

### Method B: Browse tools/ directory
```
https://github.com/galaxyproject/tools-iuc/tree/main/tools
```
- Alphabetically organized
- Look for directory matching tool name

### Method C: Use GitHub API
```bash
# Search for tool in repository
curl -s "https://api.github.com/search/code?q=TOOL_NAME+repo:galaxyproject/tools-iuc" | jq '.items[].path'
```

**What to look for**:
- Tool directory: `tools/TOOL_NAME/`
- Tool XML: `TOOL_NAME.xml`
- `.shed.yml` file (confirms it's published)
- Recent commits (indicates maintenance)

---

## 3. Check Known Galaxy Tool Repositories

Check these repositories in order:

### GenOuest Galaxy Tools
**URL**: https://github.com/genouest/galaxy-tools
**Focus**: Genomics, annotation (BRAKER, MAKER, etc.)

**Search**:
```
https://github.com/genouest/galaxy-tools/search?q=TOOL_NAME
```

**Browse**:
```
https://github.com/genouest/galaxy-tools/tree/master/tools
```

### bgruening/galaxytools
**URL**: https://github.com/bgruening/galaxytools
**Focus**: Cheminformatics, diverse tools

**Search**:
```
https://github.com/bgruening/galaxytools/search?q=TOOL_NAME
```

### ARTbio/tools-artbio
**URL**: https://github.com/ARTbio/tools-artbio
**Focus**: RNA-seq, small RNA analysis

**Search**:
```
https://github.com/ARTbio/tools-artbio/search?q=TOOL_NAME
```

### galaxyproject/tools-devteam
**URL**: https://github.com/galaxyproject/tools-devteam
**Focus**: Legacy core tools

**Search**:
```
https://github.com/galaxyproject/tools-devteam/search?q=TOOL_NAME
```

---

## 4. Check Galaxy Main ToolShed

**URL**: https://toolshed.g2.bx.psu.edu/

**Search process**:
1. Go to https://toolshed.g2.bx.psu.edu/
2. Click "Search for valid repositories"
3. Enter tool name in search box
4. Review results

**Direct search URL pattern**:
```
https://toolshed.g2.bx.psu.edu/repository/browse_repositories?sort=name&operation=repositories_by_category&id=all&f-free-text-search=TOOL_NAME
```

**Evaluate results**:
- ✅ Owner: `iuc`, `genouest`, `bgruening`, etc. (known maintainers)
- ✅ Recent updates (within last year)
- ✅ Has test data
- ⚠️ Unknown owner
- ⚠️ No updates in >2 years
- ⚠️ No description/documentation

**Get tool details**:
```
https://toolshed.g2.bx.psu.edu/view/OWNER/REPO_NAME
```

---

## 5. Web Search (Last Resort)

**Search patterns**:
```
"galaxy tool" TOOL_NAME
"galaxy wrapper" TOOL_NAME
TOOL_NAME site:github.com galaxy
TOOL_NAME site:toolshed.g2.bx.psu.edu
```

**Look for**:
- Galaxy tool repositories
- Tool documentation mentioning Galaxy
- Galaxy training materials using the tool

---

## Systematic Check Script

Here's a systematic approach to check all sources:

```bash
#!/bin/bash
# check_galaxy_tool.sh
# Usage: ./check_galaxy_tool.sh TOOL_NAME

TOOL_NAME=$1

echo "Checking for Galaxy tool: $TOOL_NAME"
echo "========================================"

# 1. Check local tools-iuc (if exists)
echo -e "\n1. Checking local tools-iuc clone..."
if [ -d ~/Documents/brc-analytics/tools-iuc ]; then
    echo "Found local clone at ~/Documents/brc-analytics/tools-iuc"
    find ~/Documents/brc-analytics/tools-iuc/tools -name "*${TOOL_NAME}*" -type d
    grep -r "$TOOL_NAME" ~/Documents/brc-analytics/tools-iuc/tools --include="*.xml" -l | head -5
else
    echo "No local tools-iuc clone found"
fi

# 2. Check tools-iuc on GitHub
echo -e "\n2. Check tools-iuc on GitHub:"
echo "https://github.com/galaxyproject/tools-iuc/search?q=${TOOL_NAME}"

# 3. Check GenOuest
echo -e "\n3. Check GenOuest galaxy-tools:"
echo "https://github.com/genouest/galaxy-tools/search?q=${TOOL_NAME}"

# 4. Check bgruening
echo -e "\n4. Check bgruening/galaxytools:"
echo "https://github.com/bgruening/galaxytools/search?q=${TOOL_NAME}"

# 5. Check ToolShed
echo -e "\n5. Check Galaxy Main ToolShed:"
echo "https://toolshed.g2.bx.psu.edu/repository/browse_repositories?f-free-text-search=${TOOL_NAME}"

echo -e "\n========================================"
echo "Check the URLs above to find the tool"
```

---

## Integration with nf-to-galaxy Skill

When converting a Nextflow process, use this checklist:

### For Each Process

```
Process: PROCESS_NAME
Tool: TOOL_NAME (extracted from container or process name)

Availability Check:
[ ] Local tools-iuc: _____________
[ ] GitHub tools-iuc: _____________
[ ] GenOuest: _____________
[ ] bgruening: _____________
[ ] ARTbio: _____________
[ ] ToolShed: _____________

Result: 
- Found in: _____________
- Tool ID: _____________
- Status: ✅ Use existing / 🔲 Create new
```

### Example Check

```
Process: HYPHY_FEL
Tool: hyphy (from container biocontainers/hyphy:2.5.84)

Availability Check:
[x] Local tools-iuc: ~/Documents/brc-analytics/tools-iuc/tools/hyphy/
[x] GitHub tools-iuc: https://github.com/galaxyproject/tools-iuc/tree/main/tools/hyphy
[ ] GenOuest: Not found
[ ] bgruening: Not found
[ ] ARTbio: Not found
[x] ToolShed: https://toolshed.g2.bx.psu.edu/view/iuc/hyphy_fel

Result:
- Found in: tools-iuc (local and GitHub)
- Tool ID: toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/hyphy_fel/2.5.84+galaxy0
- Status: ✅ Use existing
```

---

## Automation with Galaxy Integration

### Option A: Galaxy MCP (Interactive)

If Galaxy MCP is available and connected to a Galaxy instance:

```python
# Search for tools on connected Galaxy instance
search_tools_by_name(query="hyphy")

# Get tool details
get_tool_details(tool_id="hyphy_fel", io_details=True)

# Search by keywords/file types
search_tools_by_keywords(keywords=["fasta", "alignment"])
```

 This shows what's actually installed on the target Galaxy instance.
 
 **See**: `../../galaxy-integration/galaxy-integration.md` for complete MCP usage guide

### Option B: BioBlend Script (Automated)

For batch checking and minimal token usage:

 ```bash
 # Check multiple tools at once
 python ../../galaxy-integration/scripts/galaxy_tool_checker.py \
     --url https://usegalaxy.org \
     --api-key $GALAXY_API_KEY \
     --tool hyphy iqtree seqkit \
     --output report.json
 ```
 
 **See**: `../../galaxy-integration/scripts/galaxy_tool_checker.py` for complete script documentation

---

## Common Tool Name Patterns

When searching, try variations:

| Software | Possible Tool Names |
|----------|-------------------|
| HyPhy | `hyphy`, `hyphy_fel`, `hyphy_meme` |
| IQ-TREE | `iqtree`, `iq-tree` |
| SeqKit | `seqkit`, `seqkit_split`, `seqkit_grep` |
| SAMtools | `samtools`, `samtools_view`, `samtools_sort` |
| BWA | `bwa`, `bwa_mem`, `bwa_aln` |

---

## Decision Tree

```
Start: Need tool for Nextflow process
  │
  ├─► Check target Galaxy instance (via API/MCP)
  │   ├─► Found? → Use it ✅
  │   └─► Not found → Continue (tool may still be installable!)
  │
  ├─► Check local tools-iuc clone
  │   ├─► Found? → Recommend installation ✅
  │   │   └─► Provide: tool ID, installation instructions
  │   └─► Not found → Continue
  │
  ├─► Check GitHub tools-iuc
  │   ├─► Found? → Recommend installation ✅
  │   │   └─► Provide: tool ID, installation instructions
  │   └─► Not found → Continue
  │
  ├─► Check known repos (GenOuest, bgruening, etc.)
  │   ├─► Found? → Evaluate quality
  │   │   ├─► Good quality? → Recommend installation ✅
  │   │   └─► Poor quality? → Continue
  │   └─► Not found → Continue
  │
  ├─► Check ToolShed
  │   ├─► Found? → Evaluate quality
  │   │   ├─► Good quality? → Recommend installation ✅
  │   │   └─► Poor quality? → Continue
  │   └─► Not found → Continue
  │
  └─► Create custom tool 🔲
      ├─► Community-useful? → Suggest tools-iuc PR
      └─► Project-specific? → Custom tool
```

---

## Output Format

When reporting tool availability, use this format:

```markdown
## Tool Availability Report

### TOOL_NAME

**Status on target Galaxy instance**: ❌ Not installed

**Checked**:
- ✅ Local tools-iuc: Found at `tools/hyphy/hyphy_fel.xml`
- ✅ GitHub tools-iuc: https://github.com/galaxyproject/tools-iuc/tree/main/tools/hyphy
- ⬜ GenOuest: Not checked
- ⬜ bgruening: Not checked
- ⬜ ToolShed: Not checked (found in tools-iuc)

**Result**: ✅ Tool exists in tools-iuc (installable)
**Tool ID**: `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/hyphy_fel/2.5.84+galaxy0`
**Action**: Recommend user install from tools-iuc

**Installation Instructions**:
1. If you have Galaxy admin access:
   - Go to Admin → Install and Uninstall → Search Tool Shed
   - Search for "hyphy"
   - Install from repository: iuc/hyphy_fel
2. If you don't have admin access:
   - Request your Galaxy admin to install tool ID: `hyphy_fel` from tools-iuc
```

**Alternative format when tool is truly missing**:

```markdown
### TOOL_NAME

**Status on target Galaxy instance**: ❌ Not installed

**Checked**:
- ❌ Local tools-iuc: Not found
- ❌ GitHub tools-iuc: Not found
- ❌ GenOuest: Not found
- ❌ bgruening: Not found
- ❌ ToolShed: Not found

**Result**: ❌ Tool does not exist in Galaxy ecosystem
**Action**: Create custom tool wrapper

**Recommendation**: 
- Effort estimate: [Low/Medium/High]
- Suggest tools-iuc PR: [Yes/No - explain why]
- Alternative tools: [List if any]
```

---

## Best Practices

1. **Always check local first** - Fastest and most reliable
2. **Check tools-iuc before declaring "missing"** - Tool may be installable even if not on instance
3. **Use Galaxy integration when available** - Check target instance directly
   - Use **Galaxy MCP** for interactive exploration (1-3 tools)
   - Use **BioBlend script** for batch checking (5+ tools)
4. **Distinguish "not installed" from "not available"**:
   - ✅ **Not installed but in tools-iuc** → User can install
   - ⚠️ **Not in tools-iuc** → May need custom wrapper
5. **Document your search** - Record where you looked
6. **Verify quality** - Don't use unmaintained tools
7. **Recommend installation** - If tool exists in tools-iuc, guide user to install it
8. **Ask before creating** - Tool might exist under different name

---

## Related Documentation

- **`../../galaxy-integration/galaxy-integration.md`** - Complete guide to using Galaxy MCP and BioBlend
- **`examples/tool-checking-example.md`** - Step-by-step tool checking examples
- **`../../galaxy-integration/scripts/galaxy_tool_checker.py`** - Automated tool checking script
