# Nextflow to Galaxy Terminology & Structure

Clarifying the conceptual mapping between Nextflow and Galaxy organizational structures.

---

## Core Concepts

### Nextflow Hierarchy

```
Pipeline/Workflow (main.nf)
  └─► Subworkflow (workflows/*.nf)
       └─► Process (modules/*/main.nf)
            └─► Script/Command
```

### Galaxy Hierarchy

```
Workflow (.ga file)
  └─► Subworkflow (nested .ga)
       └─► Tool (*.xml)
            └─► Command (<command> section)
```

---

## Direct Mappings

| Nextflow | Galaxy | Notes |
|----------|--------|-------|
| **Process** | **Tool** | One-to-one mapping. A process becomes a tool XML. |
| **Subworkflow** | **Workflow** or **Subworkflow** | Can be standalone workflow or nested subworkflow. |
| **Workflow** | **Workflow** | Top-level workflow file. |
| **Module** | **Tool directory** | Organizational unit, not a runtime concept. |
| **Script block** | **Command section** | The actual command executed. |

---

## What is a Nextflow Module?

A **module** in Nextflow is purely an organizational concept:

```
modules/
  local/
    hyphy/
      fel/
        main.nf          # Contains HYPHY_FEL process
      meme/
        main.nf          # Contains HYPHY_MEME process
      busted/
        main.nf          # Contains HYPHY_BUSTED process
```

**Key points**:
- A module directory contains a `main.nf` file
- The `main.nf` file defines one (or sometimes multiple) processes
- The directory structure is for organization, not runtime behavior
- Modules are imported into workflows: `include { HYPHY_FEL } from './modules/local/hyphy/fel/main'`

### Module ≠ Process

Common confusion: "module" and "process" are often used interchangeably, but:
- **Module** = file/directory structure
- **Process** = the actual computational unit

A module file can contain multiple processes, though by convention it usually contains one.

---

## Galaxy Equivalent: Tool Directories

Galaxy has a similar organizational concept:

```
tools/
  hyphy/
    hyphy_fel.xml
    hyphy_meme.xml
    hyphy_busted.xml
    macros.xml
    test-data/
```

**Key points**:
- Tools for the same software are grouped in a directory
- Each tool is a separate XML file
- Shared code goes in `macros.xml`
- Test data is co-located

### Best Practice: Mirror Nextflow Structure

**If Nextflow has**:
```
modules/local/hyphy/
  fel/main.nf
  meme/main.nf
  busted/main.nf
```

**Galaxy should have**:
```
tools/hyphy/
  hyphy_fel.xml
  hyphy_meme.xml
  hyphy_busted.xml
  macros.xml
```

**Rationale**:
- Logical grouping by software package
- Easier to maintain related tools together
- Shared requirements/macros in one place
- Mirrors user mental model

---

## Process → Tool: The Core Mapping

### One Process = One Tool

```groovy
// modules/local/hyphy/fel/main.nf
process HYPHY_FEL {
    container 'biocontainers/hyphy:2.5.84--hbee74ec_0'
    
    input:
    tuple val(meta), path(alignment), path(tree)
    
    output:
    tuple val(meta), path("*.FEL.json"), emit: fel_json
    
    script:
    """
    hyphy fel --alignment $alignment --tree $tree --output output.FEL.json
    """
}
```

Becomes:

```xml
<!-- tools/hyphy/hyphy_fel.xml -->
<tool id="hyphy_fel" name="HyPhy-FEL" version="2.5.84+galaxy0">
    <requirements>
        <requirement type="package" version="2.5.84">hyphy</requirement>
    </requirements>
    <command><![CDATA[
        hyphy fel --alignment '$alignment' --tree '$tree' --output '$output'
    ]]></command>
    <inputs>
        <param name="alignment" type="data" format="fasta"/>
        <param name="tree" type="data" format="nhx,newick"/>
    </inputs>
    <outputs>
        <data name="output" format="hyphy_results.json"/>
    </outputs>
</tool>
```

**Mapping**:
- Process name → Tool ID (lowercase, underscores)
- Container → Requirements
- Input paths → Input params
- Output paths → Output data elements
- Script → Command section

---

## Module Groups → Tool Suites

### Nextflow Module Group

```
modules/local/hyphy/
  fel/main.nf
  meme/main.nf
  prime/main.nf
  busted/main.nf
  cln/main.nf
  annotate/main.nf
```

All processes use HyPhy, share similar structure.

### Galaxy Tool Suite

```
tools/hyphy/
  hyphy_fel.xml
  hyphy_meme.xml
  hyphy_prime.xml
  hyphy_busted.xml
  hyphy_cln.xml
  hyphy_annotate.xml
  macros.xml              # Shared macros
  .shed.yml               # Tool suite metadata
```

**Shared macros.xml**:
```xml
<macros>
    <token name="@TOOL_VERSION@">2.5.84</token>
    <token name="@VERSION_SUFFIX@">0</token>
    
    <xml name="requirements">
        <requirements>
            <requirement type="package" version="@TOOL_VERSION@">hyphy</requirement>
        </requirements>
    </xml>
    
    <xml name="inputs">
        <param name="alignment" type="data" format="fasta" label="Alignment"/>
        <param name="tree" type="data" format="nhx,newick" label="Tree"/>
    </xml>
    
    <xml name="citations">
        <citations>
            <citation type="doi">10.1093/molbev/msi105</citation>
        </citations>
    </xml>
</macros>
```

Each tool then uses:
```xml
<tool id="hyphy_fel" ...>
    <macros>
        <import>macros.xml</import>
    </macros>
    <expand macro="requirements"/>
    <expand macro="inputs"/>
    <expand macro="citations"/>
    ...
</tool>
```

**Benefits**:
- DRY (Don't Repeat Yourself)
- Version updates in one place
- Consistent structure across related tools
- Easier maintenance

---

## nf-core Modules vs Local Modules

### nf-core Modules

```
modules/nf-core/
  iqtree/main.nf
  multiqc/main.nf
```

These are standardized, community-maintained modules.

**Galaxy equivalent**: Tools in Galaxy ToolShed (especially tools-iuc).

**Best practice**: Check if tool already exists in ToolShed before creating new one.

### Local Modules

```
modules/local/
  custom_script/main.nf
  project_specific_tool/main.nf
```

These are project-specific or not yet contributed to nf-core.

**Galaxy equivalent**: Custom tools in your local Galaxy or project-specific tool repository.

**Best practice**: 
- For project-specific tools: Keep in project repo
- For reusable tools: Consider contributing to tools-iuc

---

## Subworkflows

### Nextflow Subworkflow

```groovy
// subworkflows/local/hyphy_analyses/main.nf
workflow HYPHY_ANALYSES {
    take:
    ch_input  // [meta, alignment, tree]
    
    main:
    HYPHY_FEL(ch_input)
    HYPHY_MEME(ch_input)
    HYPHY_PRIME(ch_input)
    
    emit:
    fel_json = HYPHY_FEL.out.fel_json
    meme_json = HYPHY_MEME.out.meme_json
    prime_json = HYPHY_PRIME.out.prime_json
}
```

### Galaxy Options

**Option 1: Flat workflow** (all tools in one .ga)
```json
{
    "name": "HyPhy Analyses",
    "steps": {
        "0": {"type": "data_input", "label": "Alignment"},
        "1": {"type": "data_input", "label": "Tree"},
        "2": {"tool_id": "hyphy_fel", ...},
        "3": {"tool_id": "hyphy_meme", ...},
        "4": {"tool_id": "hyphy_prime", ...}
    }
}
```

**Option 2: Nested subworkflow** (Galaxy 21.05+)
```json
{
    "name": "Main Workflow",
    "steps": {
        "0": {"type": "data_input"},
        "1": {
            "type": "subworkflow",
            "subworkflow": {
                "name": "HyPhy Analyses",
                "steps": {...}
            }
        }
    }
}
```

**Recommendation**: 
- For simple subworkflows: Use flat workflow
- For complex/reusable subworkflows: Use nested subworkflows
- For CAPHEINE: Flat workflow is sufficient

---

## Directory Structure Best Practices

### Nextflow Project

```
my-pipeline/
  main.nf
  nextflow.config
  workflows/
    pipeline.nf
  subworkflows/
    local/
      preprocessing/main.nf
      analyses/main.nf
  modules/
    local/
      tool_a/main.nf
      tool_b/main.nf
    nf-core/
      iqtree/main.nf
```

### Galaxy Equivalent

```
my-galaxy-tools/
  workflows/
    pipeline.ga
    preprocessing.ga
    analyses.ga
  tools/
    tool_a/
      tool_a.xml
      test-data/
    tool_b/
      tool_b.xml
      test-data/
  # Note: nf-core equivalent tools likely already in ToolShed
```

**Key differences**:
- Galaxy workflows are JSON files, not code
- Tools are XML, not Groovy
- No direct equivalent to nf-core modules (use ToolShed instead)

---

## When to Group Tools

### Group together if:

✅ Tools use the same underlying software (e.g., all HyPhy tools)
✅ Tools share common parameters/structure
✅ Tools are logically related (e.g., preprocessing suite)
✅ Tools share test data

### Keep separate if:

❌ Tools use different software packages
❌ Tools have completely different purposes
❌ Tools are maintained by different people/teams
❌ Tools have different release cycles

---

## CAPHEINE Example

### Nextflow Structure

```
CAPHEINE/
  main.nf
  workflows/
    capheine.nf
  subworkflows/
    local/
      process_viral_nonrecombinant/main.nf
      hyphy_analyses/main.nf
  modules/
    local/
      hyphy/
        fel/main.nf
        meme/main.nf
        ...
      cawlign/main.nf
      drhip/main.nf
    nf-core/
      iqtree/main.nf
      multiqc/main.nf
```

### Galaxy Structure

```
galaxy-capheine/
  workflows/
    capheine.ga                    # Main workflow
  tools/
    hyphy/                         # Already in tools-iuc
      hyphy_fel.xml
      hyphy_meme.xml
      ...
    capheine/                      # Custom CAPHEINE tools
      cawlign.xml
      remove_terminal_stop.xml
      drhip.xml
      macros.xml
      test-data/
  # iqtree, multiqc already in ToolShed
```

**Rationale**:
- HyPhy tools grouped together (already done in tools-iuc)
- CAPHEINE-specific tools grouped separately
- Standard tools (iqtree, multiqc) referenced from ToolShed
- Workflow file references all tools

---

## Summary

| Concept | Nextflow | Galaxy | Mapping |
|---------|----------|--------|---------|
| **Computational unit** | Process | Tool | 1:1 |
| **Organization** | Module (directory) | Tool directory | Mirror structure |
| **Composition** | Subworkflow | Workflow/Subworkflow | Depends on complexity |
| **Top-level** | Workflow | Workflow | 1:1 |
| **Shared code** | Groovy functions | Macros.xml | Similar purpose |
| **Community modules** | nf-core | ToolShed | Check before creating |

**Golden rule**: One Nextflow process = One Galaxy tool XML, organized in directories that mirror the Nextflow module structure.
