# Nextflow Workflow to Galaxy .ga Conversion

Guide for converting Nextflow workflows and subworkflows to Galaxy `.ga` workflow format.

---

## Planning Required

**Before converting any workflow**:

1. **Gather workflow metadata from user**:
   - **Workflow name** (descriptive, user-facing)
   - **Author/Creator name(s)** (who created/maintains this workflow)
   - **License** (e.g., MIT, Apache-2.0, GPL-3.0)
   - **Annotation/Description** (what the workflow does)
   - **Tags** (for categorization/search)
   - **NEVER use placeholder values** - always ask the user for this information

2. **Analyze workflow structure**:
   - List all processes/tools used
   - Identify data flow patterns
   - Note conditionals and parallelization
   
3. **Check tool availability** (CRITICAL - verify every tool exists):
   - Search tools-iuc repository for each tool
   - Verify exact tool IDs and current versions
   - Check tool XML for actual parameter names
   - **NEVER assume a tool exists without verification**
   - **NEVER use placeholder or non-existent tools**
   - If a tool doesn't exist, inform user and discuss alternatives
   
4. **Create conversion plan**:
   - Tool sourcing strategy (only verified tools)
   - Workflow structure (flat, nested, or multiple)
   - Custom tool locations (if needed)
   
5. **Make recommendations**:
   - Suggest tools-iuc for community-useful tools
   - Propose workflow structure optimizations
   - Identify potential issues
   
6. **Present plan to user and wait for approval**

7. **Implement only after approval**

8. **After implementation, ask user to verify**:
   - Workflow metadata is correct
   - Tool connections are logical
   - Test import on their Galaxy instance

---

## Overview

| Aspect | Nextflow | Galaxy |
|--------|----------|--------|
| **Format** | Groovy DSL (`.nf`) | JSON (`.ga`) |
| **Structure** | Code-based, imperative | Graph-based, declarative |
| **Data flow** | Channels | Dataset connections |
| **Parallelization** | Implicit via channels | Dataset collections |
| **Conditionals** | Full Groovy logic | Limited (filters, when clauses) |

---

## Conversion Strategy

### 1. Identify Workflow Structure

Map the Nextflow workflow to a directed acyclic graph (DAG):

```groovy
workflow EXAMPLE {
    take:
    ch_input
    
    main:
    STEP_A(ch_input)
    STEP_B(STEP_A.out.result)
    STEP_C(STEP_B.out.result)
    
    emit:
    final = STEP_C.out.result
}
```

Becomes:

```
Input → STEP_A → STEP_B → STEP_C → Output
```

**Note on workflow packaging**:
If the Nextflow workflow behaves like a “mega-workflow” (many modes, many knobs, large optional branches), consider publishing a **family of smaller Galaxy workflows** instead of one monolith.
See `nf-pipeline-to-galaxy-workflow/SKILL.md` (Step 1a) for the splitter vs monolith strategy.

### 2. Check Tool Availability

For each step, verify the Galaxy tool exists:
- Search tools-iuc
- Check Galaxy toolshed
- Note which tools need to be created

### 3. Handle Data Flow Patterns

#### Linear Pipeline

**Nextflow**:
```groovy
STEP_A(input)
STEP_B(STEP_A.out)
STEP_C(STEP_B.out)
```

**Galaxy**: Direct connections between tools.

#### Parallel Branches

**Nextflow**:
```groovy
STEP_A(input)
STEP_B(STEP_A.out)
STEP_C(STEP_A.out)  // Both use STEP_A output
```

**Galaxy**: One output connects to multiple tool inputs.

#### Scatter/Gather

**Nextflow**:
```groovy
ch_input.flatten()  // Scatter
    .map { PROCESS(it) }
    .collect()      // Gather
```

**Galaxy**: Use dataset collections with collection operations.

---

## Galaxy Workflow Format

### Basic Structure

```json
{
    "a_galaxy_workflow": "true",
    "format-version": "0.1",
    "name": "Workflow Name",
    "steps": {
        "0": {
            "tool_id": null,
            "type": "data_input",
            "inputs": [{"name": "input_file"}]
        },
        "1": {
            "tool_id": "tool_name",
            "tool_version": "1.0.0",
            "inputs": {
                "input_param": {
                    "connections": [{
                        "id": 0,
                        "output_name": "output"
                    }]
                }
            }
        }
    }
}
```

### Key Elements

| Element | Purpose |
|---------|---------|
| `steps` | Dictionary of workflow steps (tools) |
| `tool_id` | Galaxy tool identifier |
| `connections` | Links between step outputs and inputs |
| `inputs` | Tool parameters and their values |
| `outputs` | Which outputs to keep in history |

---

## Step-by-Step Conversion

### Step 1: Create Workflow Inputs

**Nextflow**:
```groovy
workflow EXAMPLE {
    take:
    ch_alignment
    ch_tree
}
```

**Galaxy** (steps 0, 1):
```json
"0": {
    "type": "data_input",
    "inputs": [{"name": "alignment"}],
    "label": "Alignment"
},
"1": {
    "type": "data_input",
    "inputs": [{"name": "tree"}],
    "label": "Tree"
}
```

### Step 2: Add Tool Steps

**Nextflow**:
```groovy
HYPHY_FEL(ch_alignment, ch_tree)
```

**Galaxy** (step 2):
```json
"2": {
    "tool_id": "toolshed.g2.bx.psu.edu/repos/iuc/hyphy_fel/hyphy_fel/2.5.84+galaxy0",
    "tool_version": "2.5.84+galaxy0",
    "inputs": {
        "alignment": {
            "connections": [{
                "id": 0,
                "output_name": "output"
            }]
        },
        "tree": {
            "connections": [{
                "id": 1,
                "output_name": "output"
            }]
        }
    },
    "label": "HyPhy FEL"
}
```

### Step 3: Connect Outputs to Inputs

**Nextflow**:
```groovy
STEP_A(input)
STEP_B(STEP_A.out.result)
```

**Galaxy**:
```json
"3": {
    "tool_id": "step_b_tool",
    "inputs": {
        "input_param": {
            "connections": [{
                "id": 2,  // Step A's ID
                "output_name": "result"
            }]
        }
    }
}
```

### Step 4: Handle Parameters

**Nextflow**:
```groovy
TOOL(input, option: "Yes")
```

**Galaxy**:
```json
"inputs": {
    "input_file": {
        "connections": [...]
    },
    "option": "Yes"
}
```

---

## Real Example: CAPHEINE Preprocessing

### Nextflow Subworkflow

```groovy
workflow PROCESS_VIRAL_NONRECOMBINANT {
    take:
    ch_unaligned
    ch_reference
    
    main:
    REMOVETERMINALSTOPCODON(ch_reference)
    SEQKIT_SPLIT(REMOVETERMINALSTOPCODON.out.clean_ref_fasta)
    CAWLIGN(SEQKIT_SPLIT.out.gene_fastas.flatten(), ch_unaligned)
    REMOVEAMBIGSEQS(CAWLIGN.out.aligned_seqs)
    HYPHY_CLN(REMOVEAMBIGSEQS.out.no_ambigs)
    IQTREE(HYPHY_CLN.out.deduplicated_seqs)
    
    emit:
    deduplicated = HYPHY_CLN.out.deduplicated_seqs
    tree = IQTREE.out.phylogeny
}
```

### Galaxy Workflow Structure

```json
{
    "name": "Viral Sequence Preprocessing",
    "steps": {
        "0": {
            "type": "data_input",
            "label": "Reference Genes"
        },
        "1": {
            "type": "data_input",
            "label": "Unaligned Sequences"
        },
        "2": {
            "tool_id": "remove_terminal_stop_codon",
            "label": "Remove Stop Codons",
            "inputs": {
                "reference": {"connections": [{"id": 0}]}
            }
        },
        "3": {
            "tool_id": "toolshed.../seqkit_split2",
            "label": "Split by Gene",
            "inputs": {
                "input": {"connections": [{"id": 2, "output_name": "output"}]}
            }
        },
        "4": {
            "tool_id": "cawlign",
            "label": "Align Sequences",
            "inputs": {
                "reference": {"connections": [{"id": 3, "output_name": "split"}]},
                "unaligned": {"connections": [{"id": 1}]}
            }
        },
        "5": {
            "tool_id": "toolshed.../hyphy_strike_ambigs",
            "label": "Remove Ambiguous",
            "inputs": {
                "input": {"connections": [{"id": 4, "output_name": "aligned"}]}
            }
        },
        "6": {
            "tool_id": "toolshed.../hyphy_cln",
            "label": "Deduplicate",
            "inputs": {
                "input": {"connections": [{"id": 5, "output_name": "output"}]}
            }
        },
        "7": {
            "tool_id": "toolshed.../iqtree",
            "label": "Build Tree",
            "inputs": {
                "alignment": {"connections": [{"id": 6, "output_name": "output"}]}
            }
        }
    },
    "outputs": [
        {"step": 6, "output_name": "output"},
        {"step": 7, "output_name": "treefile"}
    ]
}
```

---

## Handling Nextflow Patterns

### Flatten/Scatter

**Nextflow**:
```groovy
SEQKIT_SPLIT(reference)
PROCESS(SEQKIT_SPLIT.out.genes.flatten())
```

**Galaxy**: Use dataset collections.

Tool that produces multiple outputs → collection.
Tool that processes collection → runs on each element.

### Collect/Gather

**Nextflow**:
```groovy
results = PROCESS.out.collect()
AGGREGATE(results)
```

**Galaxy**: Tool accepts collection as input, processes all at once.

### Conditional Execution

**Nextflow**:
```groovy
if (params.foreground_list) {
    HYPHY_CONTRASTFEL(input)
}
```

**Galaxy**: Limited options:
1. Create two workflow variants (with/without optional steps)
2. Use tool `when` clauses (if tool supports)
3. Use workflow conditionals (newer Galaxy feature)

For CAPHEINE: Create two workflows or use optional inputs that skip when empty.

### Parallel Branches

**Nextflow**:
```groovy
HYPHY_FEL(input)
HYPHY_MEME(input)
HYPHY_PRIME(input)
// All run in parallel
```

**Galaxy**: All tools can connect to same input, run in parallel automatically.

```json
"8": {
    "tool_id": "hyphy_fel",
    "inputs": {"alignment": {"connections": [{"id": 6}]}}
},
"9": {
    "tool_id": "hyphy_meme",
    "inputs": {"alignment": {"connections": [{"id": 6}]}}
},
"10": {
    "tool_id": "hyphy_prime",
    "inputs": {"alignment": {"connections": [{"id": 6}]}}
}
```

---

## Creating .ga Files

### Option 1: Galaxy Workflow Editor (Recommended)

1. Open Galaxy instance
2. Workflow menu → Create new workflow
3. Add tools from toolbox
4. Connect inputs/outputs visually
5. Export as `.ga` file

---

## Caveats (Apply to Most Conversions)

When drafting `.ga` files by hand (or generating them programmatically), these issues commonly break imports/runs across Galaxy instances. **As the agent doing the conversion**, you should proactively check/fix them when possible:

- **UUIDs must be in proper UUID4 format**:
  - Galaxy validates that all `uuid` fields (workflow-level and step-level) are valid UUID4 strings (e.g., `550e8400-e29b-41d4-a716-446655440000`).
  - **Do NOT use descriptive strings** like `"input-reference-genes"` or `"step-fel"` - these will cause import errors like `Invalid step UUID4 'input-reference-genes' in request`.
  - Generate proper UUIDs using `uuid.uuid4()` in Python or equivalent in other languages.
  - Every step and workflow output must have a unique, valid UUID4.

- **Tool existence must be verified** (CRITICAL):
  - **NEVER reference a tool without verifying it exists** in tools-iuc or the target repository.
  - Check the actual tool XML file to confirm the tool ID and available versions.
  - **NEVER use placeholder or assumed tool names** - if a tool doesn't exist, inform the user.
  - Example: Don't assume `seqkit_split` exists just because `seqkit_split2` does - verify each tool independently.

- **Tool semantics must be validated (tool may exist but still be wrong)** (CRITICAL):
  - Do not stop at “the tool exists” — confirm it performs the intended transformation (read the help/command or run a small mental check against the Nextflow step).
  - If there are multiple similarly-named commands/wrappers (e.g. `split` vs `split2`), verify which one matches the pipeline intent.
  - If semantics are unclear from the pipeline context, **ask the user** what behavior is expected before emitting a `.ga` step.
  - Example (CAPHEINE): `seqkit_split2` exists, but it splits into parts/chunks; to split a multi-FASTA into **one dataset per record**, use a purpose-built splitter (e.g. ToolShed `rnateam/splitfasta` / `rbc_splitfasta`) that outputs a dataset collection.

- **Tool input/output connections require careful validation** (CRITICAL):
  - **Read the actual tool XML** to get exact parameter names - do not guess or assume.
  - Parameter names often use conditional paths (e.g., `reference_cond|reference_history` not just `reference`).
  - Input parameter names vary by tool (e.g., CAwlign uses `fasta` not `query` for sequences to align).
  - Output names must match the tool's actual output definitions (e.g., `labeled_tree` not `output`).
  - **Incorrect connections will cause workflow execution failures** even if import succeeds.
  - When in doubt, explicitly tell the user which connections need verification.

- **Tool versions are instance-specific**:
  - If you have access to the target Galaxy instance (UI or API), **resolve each step's `tool_id`/`tool_version` to what is actually installed** (tool revisions and `+galaxyN` suffixes vary).
  - If you cannot check the instance, use the most recent version and treat any `tool_id`/`tool_version` you emit as a **placeholder** and explicitly tell the user they must verify/adjust versions against their Galaxy.

- **Tool input parameter names must be validated**:
  - Prefer to **look up the tool’s actual input names** (Galaxy UI form, tool XML, or API) and ensure the JSON keys under `input_connections` / `inputs` match exactly (e.g. `input_file`, `input_nhx`, `general_options|s`).
  - If you cannot validate parameter names, explicitly tell the user which parameters are uncertain and that they must be confirmed against the installed tool definition.

### Option 2: Programmatic (via galaxy-mcp)

```python
# Using galaxy-mcp
workflow_dict = {
    "name": "My Workflow",
    "steps": {...}
}

# Import workflow
import_workflow(workflow_dict)
```

### Option 3: Manual JSON

Write `.ga` JSON directly (error-prone, use for simple workflows only).

---

## Dataset Collections

For workflows that process multiple files (like CAPHEINE processing multiple genes):

### Input Collection

```json
"0": {
    "type": "data_collection_input",
    "collection_type": "list",
    "label": "Gene Alignments"
}
```

### Tool Processing Collection

```json
"1": {
    "tool_id": "hyphy_fel",
    "inputs": {
        "alignment": {
            "connections": [{
                "id": 0,
                "output_name": "output"
            }]
        }
    }
}
```

Tool runs once per collection element, outputs new collection.

### Merging Collections

Use collection operation tools:
- `__FLATTEN__` - Flatten nested collections
- `__MERGE_COLLECTION__` - Merge multiple collections
- `__FILTER_FAILED_DATASETS__` - Remove failed datasets

---

## Validation

### Test Workflow

1. **Import** `.ga` file to Galaxy
2. **Run** with test data
3. **Compare** outputs to Nextflow outputs
4. **Iterate** on connections/parameters

### Using galaxy-mcp

```python
# Connect to Galaxy
connect(url="http://localhost:8080", api_key="...")

# Import workflow
workflow_id = import_workflow(path="workflow.ga")

# Get workflow details
details = get_workflow_details(workflow_id)

# Invoke workflow
invocation_id = invoke_workflow(
    workflow_id=workflow_id,
    inputs={"0": dataset_id_1, "1": dataset_id_2}
)

# Monitor progress
status = get_invocations(invocation_id=invocation_id)
```

---

## CAPHEINE Full Workflow

### Main Workflow Structure

```
Inputs:
  - reference_genes (fasta)
  - unaligned_seqs (fasta)
  - foreground_list (optional)

Preprocessing Subworkflow:
  └─► (alignment, tree) for each gene

Parallel HyPhy Analyses (per gene):
  ├─► FEL
  ├─► MEME
  ├─► PRIME
  ├─► BUSTED
  ├─► Contrast-FEL (if foreground)
  └─► RELAX (if foreground)

Aggregation:
  └─► DRHIP (collect all JSONs → CSVs)

Outputs:
  - summary.csv
  - sites.csv
  - comparison_summary.csv (if foreground)
  - comparison_sites.csv (if foreground)
```

### Implementation Approach

**Option A**: Single large workflow
- All steps in one `.ga` file
- Complex, harder to debug

**Option B**: Nested workflows (Recommended)
- Preprocessing as subworkflow
- HyPhy analyses as subworkflow
- Main workflow connects them

**Option C**: Multiple independent workflows
- User runs preprocessing
- User runs analyses on results
- User runs aggregation
- More manual, but simpler individual workflows

---

## Limitations & Workarounds

### Nextflow Feature → Galaxy Workaround

| Nextflow | Galaxy Solution |
|----------|-----------------|
| Complex conditionals | Multiple workflow variants |
| Dynamic file patterns | Collections + discover datasets |
| Groovy logic | Pre-processing tools or manual steps |
| `task.ext.args` | Expose params explicitly or use advanced sections |
| Meta propagation | Dataset names/identifiers |

---

## Checklist

- [ ] Map Nextflow workflow to DAG
- [ ] Verify all tools exist in Galaxy
- [ ] Create workflow inputs (data_input steps)
- [ ] Add tool steps with correct tool_ids
- [ ] Connect outputs to inputs via connections
- [ ] Set tool parameters
- [ ] Handle collections for scatter/gather
- [ ] Mark workflow outputs
- [ ] Test workflow with sample data
- [ ] Compare outputs to Nextflow
- [ ] Document workflow usage

---

## Resources

- Galaxy Workflow Format: https://galaxyproject.org/learn/advanced-workflow/
- Workflow Editor: https://usegalaxy.org/workflows/list
- galaxy-mcp workflow tools: `list_workflows()`, `get_workflow_details()`, `invoke_workflow()`
