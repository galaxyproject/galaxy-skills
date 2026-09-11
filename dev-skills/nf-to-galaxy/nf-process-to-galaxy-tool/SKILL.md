---
name: nf-process-to-galaxy-tool
description: Convert a single Nextflow process to a Galaxy tool XML
---

# Nextflow Process to Galaxy Tool

## When to Use

Use this skill when:
- Converting a single Nextflow process to a Galaxy tool
- Creating a Galaxy tool wrapper for a specific bioinformatics tool
- You've identified a missing tool during pipeline conversion

**Don't use this skill if**:
- The tool already exists in Galaxy (check first with `../check-tool-availability.md`)
- You're converting a whole workflow (use `nf-subworkflow-to-galaxy-workflow` instead)

---

## Step-by-Step Process

### Step 1: Check if Tool Already Exists

**CRITICAL**: Always check first.

**Use**: `../check-tool-availability.md` and `../scripts/check_tool.sh`

```bash
cd ../
./scripts/check_tool.sh TOOL_NAME
```

**If tool exists**: Stop here, use existing tool. You don't need this skill.

**If tool doesn't exist**: Continue to Step 2.

### Step 2: Decide Where to Create Tool

**Use**: `../tool-sources.md` for decision guidance

**Options**:
1. **tools-iuc** (if community-useful and you have access)
2. **Custom tool** (if project-specific)

**Present decision to user and wait for approval.**

If targeting **tools-iuc**, follow the higher-level tool creation guidance in:
- `../../tool-dev/SKILL.md`

### Step 3: Extract Process Information

Identify from Nextflow process:
- Container image
- Input files/parameters
- Output files
- Command/script

**See**: `../process-to-tool.md` for detailed extraction guide

### Step 4: Map to Galaxy Tool XML

**Use these references**:
- `../container-mapping.md` - Container → bioconda package
- `../datatype-mapping.md` - File patterns → Galaxy datatypes
- `../process-to-tool.md` - Complete mapping guide

### Step 5: Create Tool XML

Follow Galaxy tool XML structure:
- `<tool>` wrapper
- `<requirements>` (from container)
- `<command>` (from script)
- `<inputs>` (from process inputs)
- `<outputs>` (from process outputs)
- `<tests>` (create test cases)
- `<help>` (documentation)

**See**: `../process-to-tool.md` for complete examples

### Step 6: Validate

```bash
planemo lint tool.xml
planemo test tool.xml
```

---

## Quick Reference

**One Nextflow process = One Galaxy tool XML**

**Key mappings**:
- `container` → `<requirements>` (bioconda package)
- `input: path(file)` → `<param type="data" format="..."/>`
- `output: path("*.ext")` → `<data format="..." name="output"/>`
- `script: """..."""` → `<command><![CDATA[...]]></command>`

---

## Resources

These docs live in the parent directory (`../`):
- `process-to-tool.md` - **Complete process-to-tool conversion guide**
- `check-tool-availability.md` - Tool availability checking
- `tool-sources.md` - Where to create tools
- `container-mapping.md` - Container to bioconda mapping
- `datatype-mapping.md` - File patterns to Galaxy datatypes
- `testing-and-validation.md` - Routing page to canonical testing docs
- `../../tool-dev/references/testing.md` - Tool testing with Planemo

---

## Example

See `../examples/capheine-mapping.md` for real-world examples of process analysis.

**Note**: CAPHEINE shows a case where all tools already existed, so no tool creation was needed. This is common - always check first!
