# Galactic skills

This is a space for depositing various helpful artifacts ([skills](https://claude.com/blog/skills), [commands](https://code.claude.com/docs/en/slash-commands#personal-commands), etc.) for various agentic things like Claude Code or Gemini Code Agent. 
The idea is that by iterating over this we will create a robust set of community curated "skills" that would ultimately create guardrails preventing LLMs from doing crazy :shit: and ensuring best practices. Should probably be called Intergalactic LLM-taming commision (ILT).

This was not written by Claude.

> this is complementary to https://github.com/galaxyproject/galaxy-mcp

---

## What Are Skills?

Skills are structured instructions that help AI agents work effectively with Galaxy development. They provide:

- **Best practices** - The right way to build Galaxy tools, workflows, and content
- **Patterns** - Common solutions to common problems
- **Examples** - Concrete references to learn from
- **Guardrails** - Preventing common mistakes

> **Important**: This repo is for *developers* building Galaxy infrastructure. End-user analysis should happen in Galaxy itself to leverage its reproducibility and tracking features.

## Skills vs MCP

| Repository | Purpose | Use For |
|------------|---------|---------|
| **skills** (this repo) | *Knowledge* - How to build things well | Tool development, workflow conversion, content creation |
| [**galaxy-mcp**](https://github.com/galaxyproject/galaxy-mcp) | *Capabilities* - Interact with Galaxy programmatically | Testing, automation, CI/CD |

Use both together for best results.

---

## Installation & Usage

### Claude Code (Native Support)

Skills are automatically available. Just clone this repo into your workspace or add to `.claude/skills/`:

```bash
# Personal skills (available in all projects)
cd ~/.claude/skills
git clone https://github.com/galaxyproject/skills galaxy

# Project skills (specific to one project)
cd your-project/.claude/skills
git clone https://github.com/galaxyproject/skills galaxy
```

Claude will automatically discover and use skills when relevant.

### Windsurf / Cursor / Aider (via openskills)

```bash
# Install openskills
npm i -g openskills

# Install Galaxy skills
openskills install galaxyproject/skills

# Load a specific skill when needed
openskills read tool-updates
```

### Any Agent (Manual)

Clone this repo into your workspace and reference skills in your prompts:

```bash
git clone https://github.com/galaxyproject/skills
```

The LLM can read skill files directly from the workspace.

---

## Available Skills

### Tool Development

**tool-dev** ✅

Create and update Galaxy tool wrappers.

- **creation/** - Create new tool wrappers from scratch or Nextflow
- **updates/** - Update existing tools to new versions
- **shared/** - XML structure, testing, help formatting
- Router SKILL.md directs to appropriate sub-skill

### Content

**hub-news-posts** ✅

Write news posts for the Galaxy Project website (galaxyproject.org).

- Frontmatter templates
- Image handling
- Vega charts
- Styled tables

### Conversion

**nf-to-galaxy** ✅

Convert Nextflow processes and workflows to Galaxy tools and workflows.

- Process → Tool XML
- Container → bioconda mapping
- Workflow → .ga files
- Test with planemo and galaxy-mcp

### Integration

**galaxy-integration** ✅

Interact with Galaxy instances via MCP, JupyterLite, or BioBlend.

- **jupyterlite/** - Write notebooks using gxy package
- **mcp-reference/** - Complete MCP tools reference
- Tool checking and workflow testing examples
- BioBlend automation scripts

### Collection Manipulation

**collection-manipulation** ✅

Transform Galaxy dataset collections reproducibly using native tools.

- Filter, sort, relabel, merge, flatten, nest collections
- 26 collection operation tools
- Apply Rules DSL for complex restructuring
- API patterns and pitfall avoidance

---

## Repository Structure

```
skills/
├── README.md                    # This file
├── CONTRIBUTING.md              # How to add new skills
├── AGENTS.md                    # Agent routing instructions
│
├── tool-dev/                    # ✅ Galaxy tool development
│   ├── SKILL.md                # Router to creation/ or updates/
│   ├── creation/               # Create new tools
│   ├── updates/                # Update existing tools
│   └── shared/                 # XML, testing, help references
│
├── hub-news-posts/              # ✅ Galaxy Hub posts
│
├── nf-to-galaxy/                # ✅ Nextflow → Galaxy conversion
│
├── galaxy-integration/          # ✅ Galaxy instance integration
│   ├── jupyterlite/             # JupyterLite notebooks (gxy package)
│   └── mcp-reference/           # MCP tools reference
│
└── collection-manipulation/     # ✅ Collection transformations
    ├── SKILL.md                 # Main command (filter, sort, restructure, etc.)
    └── references/              # Tools catalog, Apply Rules DSL, API, tests
```

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:

- How to create a new skill
- Skill structure and format
- Testing and validation
- Submission guidelines

---

## Examples

### Updating a Galaxy Tool

```
User: "Update the ncbi-datasets tool to version 18.13.0"

AI: [Loads tool-updates skill]
    [Follows workflow: research upstream → update version → fix bugs → test]
    [Uses planemo for validation]
```

### Converting Nextflow to Galaxy

```
User: "Convert this Nextflow process to a Galaxy tool"

AI: [Loads nf-to-galaxy skill]
    [Maps container → bioconda package]
    [Generates Galaxy tool XML]
    [Tests with planemo lint]
    [Optionally tests on Galaxy instance via galaxy-mcp]
```

---

## Related Projects

- [galaxy-mcp](https://github.com/galaxyproject/galaxy-mcp) - MCP server for Galaxy interaction
- [planemo](https://github.com/galaxyproject/planemo) - Galaxy tool development toolkit
- [Galaxy](https://github.com/galaxyproject/galaxy) - Main Galaxy platform
- [IWC](https://github.com/galaxyproject/iwc) - Intergalactic Workflow Commission

---

## License

[MIT](LICENSE)
