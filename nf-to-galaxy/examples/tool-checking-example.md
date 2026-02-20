# Tool Checking Example: CAPHEINE Conversion

Example of checking tool availability during a Nextflow-to-Galaxy conversion.

---

## Scenario

Converting the CAPHEINE pipeline which uses these tools:
- HyPhy (multiple subtools: FEL, MEME, etc.)
- IQ-TREE
- SeqKit
- Custom alignment tool

**Goal**: Verify which tools exist on Galaxy before creating the workflow.

---

## Expected Results

| Tool | Status | Action |
|------|--------|--------|
| HyPhy (FEL, MEME, etc.) | ✅ Found | Use existing tools-iuc tools |
| IQ-TREE | ✅ Found | Use existing tools-iuc tool |
| SeqKit | ✅ Found | Use existing tools-iuc tools |
| Custom alignment tool | ❌ Not found | Create custom tool wrapper |

**Outcome**: 3/4 tool families found (75%), need to create 1 custom tool.

---

## How to Check Tools

**For detailed instructions on using Galaxy MCP and BioBlend to check tools**, see:

**→ `../../../galaxy-integration/examples/tool-checking.md`**

That guide covers:
- Using Galaxy MCP for interactive tool checking
- Using BioBlend script for batch tool checking
- Decision matrix: when to use MCP vs BioBlend
- Parsing results and extracting tool IDs

---

## Quick Reference for This Scenario

### Using Galaxy MCP

### Step 1: Connect to Galaxy

```python
# Check if already connected
get_server_info()

# If not connected
connect(url="https://usegalaxy.org", api_key="YOUR_API_KEY")
```

### Step 2: Check Each Tool

```python
# Check HyPhy
hyphy_results = search_tools_by_name(query="hyphy")
# Returns multiple HyPhy tools: hyphy_fel, hyphy_meme, hyphy_bgm, etc.

# Get details for specific tool
hyphy_fel_details = get_tool_details(
    tool_id="toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/hyphy_fel/2.5.84+galaxy0",
    io_details=True
)
# Returns: inputs, outputs, parameters, version

# Check IQ-TREE
iqtree_results = search_tools_by_name(query="iqtree")

# Check SeqKit
seqkit_results = search_tools_by_name(query="seqkit")

# Check custom tool (likely not found)
custom_results = search_tools_by_name(query="custom_alignment")
```

### Step 3: Compile Results

```markdown
## Tool Availability Report

### HyPhy
- ✅ **Found**: Multiple tools available
- **FEL**: `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/hyphy_fel/2.5.84+galaxy0`
- **MEME**: `toolshed.g2.bx.psu.edu/repos/iuc/hyphy_meme/hyphy_meme/2.5.84+galaxy0`
- **Action**: Use existing tools

### IQ-TREE
- ✅ **Found**: `toolshed.g2.bx.psu.edu/repos/iuc/iqtree/iqtree/2.1.2+galaxy2`
- **Action**: Use existing tool

### SeqKit
- ✅ **Found**: Multiple SeqKit tools available
- **Action**: Identify which SeqKit subcommands are needed

### Custom Alignment Tool
- ❌ **Not Found**: No existing Galaxy tool
- **Action**: Create custom tool wrapper
```

---

## Method 2: Using BioBlend Script

### Step 1: Create Tool List

```bash
# Create tools.txt
cat > tools.txt << EOF
hyphy
iqtree
seqkit
custom_alignment
EOF
```

### Step 2: Run Batch Check

```bash
python ../../../galaxy-integration/scripts/galaxy_tool_checker.py \
    --url https://usegalaxy.org \
    --api-key $GALAXY_API_KEY \
    --tool-list tools.txt \
    --output tool_report.json \
    --verbose
```

### Step 3: Review Output

```
============================================================
Tool Availability Report
Galaxy: https://usegalaxy.org
============================================================

✅ hyphy: Found 8 match(es)
   - HyPhy-FEL (2.5.84+galaxy0)
     ID: toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/hyphy_fel/2.5.84+galaxy0
   - HyPhy-MEME (2.5.84+galaxy0)
     ID: toolshed.g2.bx.psu.edu/repos/iuc/hyphy_meme/hyphy_meme/2.5.84+galaxy0
   [... more matches ...]

✅ iqtree: Found 1 match(es)
   - IQ-TREE (2.1.2+galaxy2)
     ID: toolshed.g2.bx.psu.edu/repos/iuc/iqtree/iqtree/2.1.2+galaxy2

✅ seqkit: Found 12 match(es)
   - SeqKit split (2.3.1+galaxy0)
     ID: toolshed.g2.bx.psu.edu/repos/iuc/seqkit_split/seqkit_split/2.3.1+galaxy0
   [... more matches ...]

❌ custom_alignment: Not found

============================================================
Summary: 3/4 tools found (75.0%)
============================================================
```

### Step 4: Parse JSON Output

```python
import json

with open('tool_report.json', 'r') as f:
    report = json.load(f)

# Extract tool IDs for workflow creation
tool_mapping = {}
for tool_name, result in report['tools'].items():
    if result['found'] and result['matches']:
        # Use first match (usually most relevant)
        tool_mapping[tool_name] = result['matches'][0]['id']

print(json.dumps(tool_mapping, indent=2))
```

Output:
```json
{
  "hyphy": "toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/hyphy_fel/2.5.84+galaxy0",
  "iqtree": "toolshed.g2.bx.psu.edu/repos/iuc/iqtree/iqtree/2.1.2+galaxy2",
  "seqkit": "toolshed.g2.bx.psu.edu/repos/iuc/seqkit_split/seqkit_split/2.3.1+galaxy0"
}
```

---

## Comparison: MCP vs BioBlend Script

| Aspect | Galaxy MCP | BioBlend Script |
|--------|-----------|-----------------|
| **Token Usage** | Higher (conversational) | Lower (structured output) |
| **Speed** | Interactive | Fast batch processing |
| **Best For** | Exploring, iterating | Automation, batch checks |
| **Output Format** | Conversational | JSON, structured |
| **User Interaction** | High | Low |

---

## Next Steps in Conversion

After checking tool availability:

1. **For found tools** (HyPhy, IQ-TREE, SeqKit):
   - Note exact tool IDs with versions
   - Use these IDs in workflow `.ga` file

2. **For missing tools** (custom alignment):
   - Create custom tool wrapper
   - See: `../nf-process-to-galaxy-tool/SKILL.md`
   - Or: `../../../tool-dev/SKILL.md`

3. **Create workflow**:
   - Use verified tool IDs in `.ga` file
   - See: `../workflow-to-ga.md`

4. **Test workflow**:
   - See: `workflow-testing-example.md` (this directory)
   - Or: `../../../galaxy-integration/examples/workflow-testing.md`

---

## Related

- **Detailed tool checking guide**: `../../../galaxy-integration/examples/tool-checking.md`
- **CAPHEINE mapping**: `capheine-mapping.md` (complete tool mapping)
- **Tool creation**: `../nf-process-to-galaxy-tool/SKILL.md`
- **Workflow testing**: `workflow-testing-example.md`
