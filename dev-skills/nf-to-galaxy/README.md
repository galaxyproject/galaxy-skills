# Nextflow to Galaxy Conversion Skill

Convert Nextflow workflows to Galaxy tools and workflows.

---

## Quick Start

**New to this skill?** Start here:

1. **Read**: `SKILL.md` - Main router and overview
2. **Choose your conversion type**:
   - Single process → `nf-process-to-galaxy-tool/`
   - Subworkflow → `nf-subworkflow-to-galaxy-workflow/`
   - Complete pipeline → `nf-pipeline-to-galaxy-workflow/`

**Using Galaxy integration?** See `../../skills/galaxy-integration/README.md` and `../../skills/galaxy-integration/galaxy-integration.md`.

---

## File Organization

### 📋 Core Documentation

| File | Purpose | When to Read |
|------|---------|--------------|
| **`SKILL.md`** | Main router, decides which sub-skill to use | **Start here** |
| **`../../skills/galaxy-integration/galaxy-integration.md`** | Galaxy MCP/BioBlend setup, usage, examples | Using Galaxy features |

### 🔧 Reference Documentation

| File | Purpose |
|------|---------|
| `check-tool-availability.md` | How to find if tools exist |
| `testing-and-validation.md` | Routing page to canonical testing docs |
| `../tool-dev/references/testing.md` | Tool testing with Planemo |
| `nextflow-galaxy-terminology.md` | Concept mappings |
| `process-to-tool.md` | Process → Tool conversion details |
| `workflow-to-ga.md` | Workflow → .ga conversion details |
| `container-mapping.md` | Container → Conda package mapping |
| `datatype-mapping.md` | File patterns → Galaxy datatypes |
| `tool-sources.md` | Where to create tools |

### 🎯 Sub-Skills

| Directory | Purpose |
|-----------|---------|
| `nf-process-to-galaxy-tool/` | Convert single Nextflow process to Galaxy tool |
| `nf-subworkflow-to-galaxy-workflow/` | Convert subworkflow to Galaxy workflow |
| `nf-pipeline-to-galaxy-workflow/` | Convert complete pipeline |

### 📁 Supporting Files

| Directory/File | Purpose |
|----------------|---------|
| `scripts/` | Repository availability helper scripts (check_tool.sh) |
| `examples/` | Complete conversion examples |
| `.env.example` (skills repo root) | Template for Galaxy credentials (copy to `.env` at repo root; see `../../skills/galaxy-integration/README.md`) |

---

## Common Workflows

### Check if Tool Exists on Galaxy

```bash
# Option 1: Use script (efficient)
python ../../skills/galaxy-integration/scripts/galaxy_tool_checker.py --tool hyphy iqtree

# Option 2: Use MCP (interactive)
# In agent: "Check if hyphy and iqtree are available on usegalaxy.org"
```

See: `../../skills/galaxy-integration/galaxy-integration.md` → Tool Checking

### Validate Workflow File

```bash
python ../../skills/galaxy-integration/scripts/galaxy_tool_checker.py --workflow my_workflow.ga
```

See: `../../skills/galaxy-integration/galaxy-integration.md` → Workflow Validation

### Convert Process to Tool

1. Read: `nf-process-to-galaxy-tool/SKILL.md`
2. Check tool availability: `check-tool-availability.md`
3. If tool doesn't exist, create wrapper following the sub-skill

### Convert Pipeline to Workflows

1. Read: `nf-pipeline-to-galaxy-workflow/SKILL.md`
2. Inventory tools: Use `../../skills/galaxy-integration/scripts/galaxy_tool_checker.py`
3. Create workflows with verified tool IDs
4. Test: `../../skills/galaxy-integration/galaxy-integration.md` → Workflow Testing

---

## Decision Tree

```
What do you need?
│
├─ Learn concepts?
│  └─ Read: nextflow-galaxy-terminology.md
│
├─ Check if tool exists?
│  ├─ On Galaxy instance? → ../../skills/galaxy-integration/galaxy-integration.md (Tool Checking)
│  └─ In repositories? → check-tool-availability.md
│
├─ Convert something?
│  └─ Read: SKILL.md (router)
│
├─ Test workflow?
│  └─ Read: ../../skills/galaxy-integration/galaxy-integration.md (Workflow Testing)
│
└─ Understand mappings?
   ├─ Containers → container-mapping.md
   ├─ Datatypes → datatype-mapping.md
   └─ Processes → process-to-tool.md
```

---

## Key Principles

1. **Always check if tools exist** before creating new ones
2. **Use exact tool IDs** in workflows (full ToolShed format)
3. **Test incrementally** - don't wait for full pipeline to fail
4. **Choose the right method**:
   - Galaxy MCP: Interactive, 1-3 tools
   - BioBlend script: Batch operations, 5+ tools

---

## Getting Help

- **Confused about structure?** Read this README
- **Don't know which sub-skill?** Read `SKILL.md`
- **Need Galaxy setup?** See `../../skills/galaxy-integration/galaxy-integration.md` → Setup
- **Want examples?** See `examples/` directory
- **Script usage?** See `../../skills/galaxy-integration/scripts/README.md`
