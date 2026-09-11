---
name: nf-subworkflow-to-galaxy-workflow
description: Convert a Nextflow subworkflow to a Galaxy workflow
---

# Nextflow Subworkflow to Galaxy Workflow

## When to Use

Use this skill when:
- Converting a Nextflow subworkflow (multiple connected processes)
- Creating a Galaxy workflow from a logical group of tools
- Building a reusable workflow component

**Don't use this skill if**:
- Converting a single process (use `nf-process-to-galaxy-tool` instead)
- Converting a complete pipeline (use `nf-pipeline-to-galaxy-workflow` instead)

---

## Step-by-Step Process

### Step 1: Identify All Processes in Subworkflow

List all processes that are part of the subworkflow.

**Example** (CAPHEINE preprocessing):
```
PROCESS_VIRAL_NONRECOMBINANT subworkflow:
1. REMOVETERMINALSTOPCODON
2. SEQKIT_SPLIT
3. CAWLIGN
4. REMOVEAMBIGSEQS
5. HYPHY_CLN
6. IQTREE
7. HYPHY_LABELTREE
```

### Step 2: Check Tool Availability for Each Process

**Use**: `../check-tool-availability.md` and `../scripts/check_tool.sh`

```bash
cd ../
for tool in removeterminalstopcodon seqkit cawlign hyphy iqtree; do
    ./scripts/check_tool.sh $tool
done
```

**Document results**:
```
Process: REMOVETERMINALSTOPCODON
Tool: remove_terminal_stop_codons
Status: ✅ Found in tools-iuc
Action: Use existing tool

Process: SEQKIT_SPLIT
Tool: seqkit_split2
Status: ✅ Found in tools-iuc
Action: Use existing tool

Process: CUSTOM_PROCESS
Tool: custom_tool
Status: ❌ Not found
Action: Need to create tool → Use nf-process-to-galaxy-tool skill
```

### Step 3: Create Missing Tools (if any)

**If any tools are missing**:

For each missing tool, **use the `nf-process-to-galaxy-tool` skill** to create it.

**Wait for all tools to exist before continuing to Step 4.**

### Step 4: Map Data Flow

Identify how data flows between processes in Nextflow:

```groovy
// Nextflow example
PROCESS_A(input_ch)
PROCESS_B(PROCESS_A.out.result)
PROCESS_C(PROCESS_B.out.result)
```

Maps to Galaxy workflow:
```
Step 0: Input dataset
Step 1: Tool A (input from Step 0)
Step 2: Tool B (input from Step 1 output)
Step 3: Tool C (input from Step 2 output)
```

**See**: `../workflow-to-ga.md` for detailed data flow mapping

### Step 5: Handle Special Patterns

**Parallelization** (Nextflow channels splitting):
- Use Galaxy **dataset collections**
- Map scatter/gather patterns

**Conditionals** (Nextflow `when` clauses):
- Use Galaxy workflow conditionals (limited)
- Or create separate workflows for different paths

**Optional inputs**:
- Mark as optional in workflow inputs
- Use conditional steps

**See**: `../workflow-to-ga.md` for pattern details

### Step 6: Build Workflow

**Recommended approach**: Use Galaxy UI

1. Open Galaxy workflow editor
2. Add input datasets
3. Add tools in order (by ToolShed ID)
4. Connect outputs to inputs
5. Configure parameters
6. Test with sample data
7. Export as `.ga` file

**Alternative**: Programmatically create `.ga` JSON

**See**: `../workflow-to-ga.md` for `.ga` format details

### Step 7: Test Workflow

Use the canonical testing docs:
- Tool testing (Planemo): `../../tool-dev/references/testing.md`
- Workflow testing/validation (Galaxy instance): `../../galaxy-integration/galaxy-integration.md`

`../testing-and-validation.md` is a short routing page that links to these.

---

## Quick Reference

**Nextflow subworkflow = Galaxy workflow (.ga file)**

**Key mappings**:
- Process sequence → Workflow steps
- Channel connections → Dataset connections
- Parallel processes → Dataset collections
- Conditional execution → Workflow conditionals (limited)

---

## Resources

All detailed guides are in parent directory (`../`):
- `workflow-to-ga.md` - **Complete workflow conversion guide**
- `check-tool-availability.md` - Tool availability checking
- `nextflow-galaxy-terminology.md` - Conceptual mappings
- `testing-and-validation.md` - Routing page to canonical testing docs

**Related skills**:
- `nf-process-to-galaxy-tool` - For creating missing tools

---

## Example

See `../examples/capheine-mapping.md` for the PROCESS_VIRAL_NONRECOMBINANT subworkflow conversion example.

**Key insight**: In CAPHEINE, all tools already existed in tools-iuc, so conversion was purely workflow assembly - no tool creation needed.
