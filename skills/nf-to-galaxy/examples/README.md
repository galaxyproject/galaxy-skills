# Nextflow to Galaxy Conversion Examples

Real-world examples of converting Nextflow pipelines to Galaxy workflows.

**Note**: These examples focus on **conversion-specific scenarios**. For detailed instructions on **using Galaxy MCP and BioBlend** to check tools and test workflows, see `../../../galaxy-integration/examples/`.

---

## Available Examples

### `capheine-mapping.md`
**Complete pipeline conversion example**

Shows the full conversion of the CAPHEINE pipeline:
- Process inventory and tool identification
- Tool availability checking
- Workflow structure planning
- Step-by-step conversion approach

**When to read**: Converting a complete Nextflow pipeline to Galaxy

---

### `tool-checking-example.md`
**Tool availability checking walkthrough**

Demonstrates checking if tools exist using:
- Galaxy MCP (interactive method)
- BioBlend script (batch method)
- Comparison of both approaches

**When to read**: Need to check if tools exist before conversion

---

### `workflow-testing-example.md`
**Workflow testing and iteration**

Shows how to:
- Test converted .ga workflows
- Iterate on failures automatically
- Fix common issues (tool IDs, datatypes, parameters)
- Use both MCP and BioBlend script for testing

**When to read**: Testing a converted workflow

---

## Quick Links

**Setup Galaxy integration**: See `../../../galaxy-integration/galaxy-integration.md` → Setup

**Tool checking**:
- Interactive (1-3 tools): `tool-checking-example.md` → Method 1
- Batch (5+ tools): `tool-checking-example.md` → Method 2

**Workflow testing**:
- Interactive: `workflow-testing-example.md` → Method 1
- Automated: `workflow-testing-example.md` → Method 2

**Complete conversion**: `capheine-mapping.md`
