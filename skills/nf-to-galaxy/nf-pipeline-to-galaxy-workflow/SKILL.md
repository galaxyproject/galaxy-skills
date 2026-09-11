---
name: nf-pipeline-to-galaxy-workflow
description: Convert a complete Nextflow pipeline to Galaxy
---

# Nextflow Pipeline to Galaxy Workflow

## When to Use

Use this skill when:
- Converting a complete Nextflow pipeline (e.g., nf-core pipeline)
- Creating a full Galaxy solution with multiple workflows
- Planning a large-scale conversion project

**Don't use this skill if**:
- Converting a single process (use `nf-process-to-galaxy-tool` instead)
- Converting a single subworkflow (use `nf-subworkflow-to-galaxy-workflow` instead)

---

## Step-by-Step Process

### Step 1: Clarify Workflow Scope with User

**REQUIRED before starting conversion** - ask the user:

1. **What parts of the Nextflow pipeline to convert?**
   - Full pipeline end-to-end?
   - Specific subworkflow only?
   - Exclude certain optional steps?
   - Example: "Do you want preprocessing + alignment + variant calling + annotation, or just variant calling?"

2. **Quality control and reporting requirements:**
   - Include QC steps (FastQC, etc.)?
   - Include aggregated reporting (MultiQC)?
   - Include intermediate QC checks?

3. **Best-practice scientific / bioinformatics sanity check (REQUIRED):**
    - If the requested scope has conceptual issues (e.g., missing required preprocessing steps like sort/index, omitting essential QC, incompatible inputs/reference/annotation, or a too-small subset that would violate common analysis best practices), **flag the issue**.
    - Ask the user whether they want to:
      - Expand/adjust the scope to address the best-practice issue(s), or
      - Proceed with the user’s requested scope as-is (explicitly confirmed).

4. **Workflow metadata:**
   - **Workflow name** (descriptive, user-facing)
   - **Author/Creator name(s)** 
   - **License** (e.g., MIT, Apache-2.0, GPL-3.0)
   - **Description/Annotation**
   - **Tags** for categorization

**NEVER use placeholder values** - always get real information from the user.
**NEVER assume scope** - explicitly confirm what to include/exclude.

### Step 2: Analyze Pipeline Structure

Read the main Nextflow file and all imported workflows/subworkflows.

**Document**:
- All processes used
- Data flow between processes
- Conditionals and branches
- Input/output patterns

### Step 3: Check Tool Availability and Requirements (CRITICAL)

**For each process**, verify a corresponding Galaxy tool exists:
- **Search tools-iuc repository** and verify tool XML exists
- **Read the tool XML** to confirm:
  - Exact tool ID and current version
  - Actual input/output parameter names (for connections)
  - Conditional parameter structures
  - Whether tool requires pre-built databases/indices
- **NEVER assume a tool exists** without verification
- **NEVER use placeholder or non-existent tools**
- If a tool doesn't exist, inform user and discuss alternatives

**CRITICAL: Verify tool owner/repository** (COMMON ERROR):
- Tools can exist under **multiple owners** (e.g., `devteam`, `iuc`, `bgruening`)
- **Check the actual ToolShed** at https://toolshed.g2.bx.psu.edu/ to confirm correct owner
- Example: `freebayes` is under `devteam`, NOT `iuc`
- Example: `samtools_sort` is under `iuc`, NOT `devteam`
- **Tool ID format**: `toolshed.g2.bx.psu.edu/repos/{owner}/{repo}/{tool}/{version}`
- Wrong owner = "tool not available" error even if tool exists
- **Always verify owner** before using tool in workflow

**Check for tool dependencies:**
- Does the tool need a database built first? (e.g., SnpEff needs database, not just GTF)
- Does the tool need sorted/indexed input? (e.g., variant callers need sorted BAM + index)
- Are there helper tools needed? (e.g., samtools sort/index after alignment)

Use the **`check-tool-availability.md`** reference.

Prefer a **splitter approach** when the Nextflow workflow:
- Has multiple “modes” controlled by flags (`--mode`, `--skip_*`, etc.)
- Has large optional branches triggered by optional inputs
- Exposes a very large parameter surface (many knobs that overwhelm a Galaxy form)
- Produces materially different outputs depending on configuration

**Splitter pattern**:
- Create 2–N intent-focused Galaxy workflows with simpler inputs
- Keep an “advanced” variant only when needed
- Minimize workflow conditionals; prefer separate workflows when branches are substantial

**Deliverable**: your plan should explicitly state whether you are producing:
- One Galaxy workflow
- Multiple related Galaxy workflows (recommended for complex pipelines)
- Optional “meta-workflow” that chains subworkflows (only if it improves usability)

**Example** (CAPHEINE):
```
CAPHEINE Pipeline:
├── PIPELINE_INITIALISATION (setup)
├── CAPHEINE (main analysis)
│   ├── PROCESS_VIRAL_NONRECOMBINANT (preprocessing subworkflow)
│   ├── HYPHY_ANALYSES (analyses subworkflow)
│   └── DRHIP (aggregation)
└── PIPELINE_COMPLETION (reporting)
```

**CAPHEINE splitter example (foreground branch)**:
CAPHEINE has an optional branch controlled by providing a foreground regexp/list.
In Galaxy, it may be clearer to publish two workflows:

- **Workflow A: CAPHEINE (no foreground)**
  - Inputs: reference genes, unaligned sequences
  - Runs the baseline HyPhy analyses
  - Outputs: baseline result set

- **Workflow B: CAPHEINE (with foreground)**
  - Inputs: reference genes, unaligned sequences, foreground regexp/list
  - Runs additional foreground-dependent HyPhy analyses
  - Outputs: baseline + additional foreground-dependent results

This keeps each workflow form smaller and avoids large conditional sections.

### Step 2: Check Tool Availability for All Processes

**Use**: `../check-tool-availability.md` and `../scripts/check_tool.sh`

Create comprehensive tool inventory:

```bash
cd ../
# List all unique tools used in pipeline
for tool in tool1 tool2 tool3; do
    ./scripts/check_tool.sh $tool
done
```

**Document all findings** in a table:
```
| Process | Tool | Status | Action |
|---------|------|--------|--------|
| PROCESS_A | tool_a | ✅ Exists | Use existing |
| PROCESS_B | tool_b | ❌ Missing | Create tool |
```

### Step 3: Create Conversion Plan

**Plan must include**:

1. **Tool inventory** (from Step 2)
   - Existing tools and their locations
   - Missing tools that need creation
   
2. **Tool creation strategy** (for missing tools)
   - Which should go in tools-iuc?
   - Which should be custom?
   - Ask user about tools-iuc access
   
3. **Workflow structure**
   - Single workflow or multiple related workflows?
   - If multiple: how do they differ by intent/inputs/outputs?
   - Nested subworkflows?
   - Where do you intentionally split to reduce conditionals/knobs?
   
4. **Implementation order**
   - Which tools to create first
   - Which workflows to build first
   - Testing strategy

**Present plan to user and wait for approval before implementing.**

**See**: `../tool-sources.md` for tool placement decisions

### Step 4: Create Missing Tools

**For each missing tool**, use the **`nf-process-to-galaxy-tool` skill**.

**Wait for all tools to be created and validated before continuing.**

### Step 5: Build Workflows

**For each subworkflow**, use the **`nf-subworkflow-to-galaxy-workflow` skill**.

 **Caveats (important for most pipelines)**:

 - **UUIDs must be in proper UUID4 format**:
   - Galaxy validates that all `uuid` fields are valid UUID4 strings (e.g., `550e8400-e29b-41d4-a716-446655440000`).
 - **UUIDs must be unique across the entire workflow JSON**:
   - Galaxy rejects workflows if any `uuid` is duplicated (common failure: copying the workflow `uuid` into a step `uuid`, or reusing the same step UUID across multiple steps).
   - Check uniqueness for:
     - Workflow-level `uuid`
     - Every `steps.<n>.uuid`
     - Every `steps.<n>.workflow_outputs[*].uuid`
   - Validate before import (e.g., parse JSON and ensure the set of UUIDs has no duplicates).

 - **Interpret Galaxy warnings correctly**: The user may provide a list of warnings produced by Galaxy for a workflow they try to import.
   - **Benign (often OK)**:
     - Warnings for optional advanced parameters (e.g. “Disable grouping… Using default False”).
     - These usually just indicate the workflow JSON omitted optional parameters and Galaxy filled defaults.
   - **Usually indicates a real workflow bug**:
     - Warnings where the missing value is a *dataset input* (e.g. “BAM file … default ''”, “VCF Data … default ''”, “GFF dataset … default ''”).
     - This typically means:
       - `input_connections` uses the wrong parameter name, **or**
       - a conditional selector in `tool_state` was not set, so Galaxy expects a different input branch.
   - **Environment mismatch (action required)**:
     - “Tool is not installed” → the target Galaxy instance doesn’t have that exact `tool_id`.
     - “Using version X instead of version Y specified” → Galaxy substituted an installed version.
       - This is often OK, but you must re-check parameter names/outputs against the installed tool.

 - **These two mistakes are extremely common — preempt them**:
   - **Tool ID / owner / version mismatch**:
     - The workflow may reference a real tool, but under the wrong owner or an uninstalled version.
     - Symptoms: “Tool is not installed”, “tool not available”, or silent version substitution.
     - Mitigation: verify ToolShed owner + inspect the tool XML for the exact `tool_id` + version.
   - **Conditional branch / input key mismatch**:
     - The tool may have the correct upstream dataset available, but Galaxy still warns that the dataset input is empty.
     - Symptoms: “No value found for 'BAM file'… default ''” / “No value found for 'GFF dataset'… default ''”.
     - Mitigation: set the correct selector in `tool_state` *and* use the exact conditional parameter path in `input_connections`.

 - **Tool forms often require setting conditional selectors in `tool_state`**:
   - Many tools expose inputs only after a selector is set (e.g. “use cached genome vs history dataset”, “single vs collection”, “region mode on/off”).
   - Even if you wire `input_connections` correctly, Galaxy may still treat the input as missing unless the selector branch is chosen in `tool_state`.

 - **Validation checkpoint (recommended)**:
   - After generating the `.ga`, import into the target Galaxy and scan for:
     - Any “Tool is not installed” messages (fix tool IDs/owners/versions)
     - Any dataset-input warnings defaulting to empty (fix `input_connections` key names and/or conditional selectors)
     - Any version substitutions that might change parameter/output names
   - If any dataset-input warnings remain, treat the workflow as **not runnable** until resolved.

 - **Iterate using Galaxy’s import warnings report**:
   - Do not assume the user will proactively provide these warnings.
   - If your first draft doesn’t import cleanly, ask the user to:
     - Import the `.ga` into their Galaxy instance
     - Copy/paste the resulting import warnings report
   - Use that report to quickly identify which failures are:
     - Missing tools (instance mismatch)
     - Wrong tool IDs/owners/versions
     - Wrong `input_connections` keys
     - Missing conditional selectors in `tool_state`

 - **Tool existence and repository owner must be verified**:
   - Tools can exist under multiple owners; wrong owner produces “tool not available” errors.
   - Confirm tool IDs via ToolShed URLs and/or tool XML in the authoritative repository.

- **Tool existence must be verified** (CRITICAL):
  - **NEVER reference a tool without verifying it exists** in tools-iuc or target repository.
  - Check the actual tool XML file to confirm tool ID and versions.
  - **NEVER use placeholder or assumed tool names**.
  - If a tool doesn't exist, inform user and discuss alternatives

- **Tool semantics must be validated (tool may exist but still be wrong)** (CRITICAL):
  - Do not stop at “the tool exists” — confirm it performs the intended transformation.
  - If semantics are unclear, **ask the user** what behavior is expected before drafting the step.
  - Example (CAPHEINE): `seqkit_split2` exists, but it splits into parts/chunks; for “one FASTA record → one dataset in a collection”, use an appropriate splitter tool (e.g. ToolShed `rnateam/splitfasta` / `rbc_splitfasta`).

- **Tool input/output connections are REQUIRED** (CRITICAL):
  - **Every tool step must have `input_connections`** that wire it to upstream steps (except workflow inputs).
  - **Tools without connections will not receive data and will fail at runtime**.
  - Each connection must specify: upstream step `id` + exact `output_name` from that step.
  - **Read the actual tool XML** to get exact input parameter names - do not guess.
  - Parameter names often use conditional paths (e.g., `reference_cond|reference_history` not `reference`).
  - Input names vary by tool (e.g., CAwlign uses `fasta` not `query`).
  - Output names must match tool definitions (e.g., `labeled_tree` not `output`).
  - **Incorrect connections cause execution failures** even if import succeeds.
  - Explicitly tell user which connections need verification.

- **Dataset collections vs individual datasets**:
  - Paired FASTQ inputs should use `data_collection_input` type with `collection_type: "paired"`.
  - Tools that process collections need collection-aware parameter names (check tool XML).
  - Some tools iterate over collections, others process them as a unit.
  - Collection outputs have `type: "input"` to preserve collection structure.

- **Tool dependencies and helper steps**:
  - Some tools require pre-built databases (e.g., SnpEff needs database built from GTF, not raw GTF).
  - Some tools require sorted/indexed input (e.g., variant callers need sorted BAM + BAI index).
  - Add helper tools as needed (e.g., samtools sort/index after alignment).
  - Check Nextflow workflow for these preprocessing steps.

- **Tool versions in drafted `.ga` files are often placeholders**:
  - If you have access to the target Galaxy instance (UI or API), **resolve each step's `tool_id`/`tool_version` to what is actually installed** (tool revisions and `+galaxyN` suffixes differ).
  - If you cannot check the instance, use the most recent version of each tool and treat any `tool_id`/`tool_version` you emit as a **placeholder** and explicitly tell the user they must verify/adjust versions against their Galaxy.

**Recommended structure**:
- Break pipeline into logical workflow units
- Create subworkflows first
- Compose into main workflow(s)

**Example** (CAPHEINE):
```
Workflow 1: CAPHEINE_Preprocessing
  - Input: Raw sequences
  - Output: Alignment + Tree
  
Workflow 2: CAPHEINE_Analyses
  - Input: Alignment + Tree
  - Output: Analysis results + DRHIP report
```

### Step 6: Integration Testing
 
 Use the canonical testing docs:
 - Tool testing (Planemo): `../../tool-dev/references/testing.md`
 - Workflow testing/validation (Galaxy instance): `../../galaxy-integration/galaxy-integration.md`
 
 `../testing-and-validation.md` is a short routing page that links to these.
 
At minimum:
1. Upload pipeline test data
2. Run workflows in sequence
3. Compare outputs to Nextflow results (structural/semantic match)
4. Document differences

### Step 7: Documentation

Create documentation for users:
- Which workflows to run in what order
- Input data requirements
- Expected outputs
- Tool versions used
- Differences from Nextflow version (if any)

---

## Quick Reference

**Nextflow pipeline = Multiple Galaxy workflows + tools**

**Decomposition strategy**:
1. Identify logical workflow boundaries
2. Check all tool availability
3. Create missing tools (use `nf-process-to-galaxy-tool`)
4. Build subworkflows (use `nf-subworkflow-to-galaxy-workflow`)
5. Compose and test

---

## Resources

All detailed guides are in parent directory (`../`):
- `check-tool-availability.md` - Tool availability checking
- `tool-sources.md` - Where to create tools
- `workflow-to-ga.md` - Workflow creation guide
- `nextflow-galaxy-terminology.md` - Conceptual mappings
- `testing-and-validation.md` - Routing page to canonical testing docs

**Related skills**:
- `nf-process-to-galaxy-tool` - For creating missing tools
- `nf-subworkflow-to-galaxy-workflow` - For building workflow components

---

## Complete Example: CAPHEINE Pipeline

See `../examples/capheine-mapping.md` for full CAPHEINE conversion.

**Key findings**:
- ✅ 15/15 tools exist in tools-iuc (100% coverage)
- ✅ No tool creation needed
- ✅ Conversion is purely workflow assembly
- Recommended: 2 workflows (preprocessing + analyses)

**This demonstrates the ideal case**: Most established pipelines use common tools that already exist in Galaxy.
