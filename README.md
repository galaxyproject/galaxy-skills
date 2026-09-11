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

### Claude Code (Plugin -- Recommended)

```bash
# Add the Galaxy Project marketplace
/plugin marketplace add galaxyproject/galaxy-skills

# Install the plugin
/plugin install galaxy@galaxyproject
```

This installs the skills *and* wires up the
[galaxy-mcp](https://github.com/galaxyproject/galaxy-mcp) server, so the agent can work against a
live Galaxy instance -- create histories, upload data, run tools, invoke workflows.

#### Connecting to a Galaxy instance

The MCP server launches through `uvx`, so you need [uv](https://docs.astral.sh/uv/) installed.
Point it at an instance and give it a key:

```bash
export GALAXY_URL=https://usegalaxy.org   # this is the default if unset
export GALAXY_API_KEY=your_api_key        # User -> Preferences -> Manage API Key
```

A `.env` file in your working directory works too. Without a key the plugin still installs and the
skills still load -- only the live-instance tools fail, and you can supply credentials at runtime
with `connect(url, api_key)`.

The first launch downloads the server and its dependencies, which can take long enough that Claude
Code reports the MCP server as failed. Run `uvx galaxy-mcp --version` once to warm the cache, or
`uv tool install galaxy-mcp` to install it outright.

The server exposes 38 tools. To trim what sits in context, set `GALAXY_MCP_EXCLUDE_TAGS` (for
example `niche` drops the five IWC workflow-discovery tools) or `GALAXY_MCP_INCLUDE_TAGS`.

### Claude Code (Manual)

Clone into your skills directory if you prefer not to use the plugin system:

```bash
cd ~/.claude/skills
git clone https://github.com/galaxyproject/galaxy-skills galaxy
```

### Windsurf / Cursor / Aider (via openskills)

```bash
# Install openskills
npm i -g openskills

# Install Galaxy skills
openskills install galaxyproject/galaxy-skills

# Load a specific skill when needed
openskills read tool-updates
```

### Any Agent (Manual)

Clone this repo into your workspace and reference skills in your prompts:

```bash
git clone https://github.com/galaxyproject/galaxy-skills
```

The LLM can read skill files directly from the workspace.

---

## Available Skills

### Tool Development

**tool-dev** ✅

Create and update Galaxy tool wrappers.

- Comprehensive SKILL.md covering tool creation, testing, IUC review, and updates
- **references/** - Standalone testing and tool placement guides (also used by other skills)
- **tool-selection-diagram/** - Generate "which tool?" flowchart PNGs for multi-tool suites

**udt-authoring** ✅

Author Galaxy User-Defined Tools (UDTs) — the `class: GalaxyUserTool` YAML format a non-admin user creates and runs (distinct from classic XML/ToolShed wrappers).

- SKILL.md with the authoring loop and offline/server validation tiers
- **references/** - UserToolSource schema, `$(...)` templating, common mistakes checklist
- **scripts/validate.py** - offline validate + lint via galaxy-tool-util
- **examples/** - seven complete UDTs, simple to complex

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
- **galaxy-mcp-reference** (now its own skill) - Complete MCP tools reference
- Tool checking and workflow testing examples
- BioBlend automation scripts

### Server Tool Management

**update-usegalaxy-tool** ✅

Add or update ToolShed tool revisions in the [usegalaxy-tools](https://github.com/galaxyproject/usegalaxy-tools) repository.

- Resolve changeset revisions via ToolShed API
- Edit `.yml` / `.yml.lock` toolset files
- Handle adds, updates, moves, and removals across sections
- Lint with `fix_lockfile.py`

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
galaxy-skills/
├── plugin.json                  # Plugin manifest (Antigravity reads this)
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest (Claude Code, Codex)
│   └── marketplace.json         # Marketplace manifest
├── .mcp.json                    # galaxy-mcp server config
├── AGENTS.md                    # Cross-agent routing instructions
├── CONTRIBUTING.md              # How to add new skills
│
└── skills/
    ├── tool-dev/                    # Galaxy tool development
    │   ├── references/              # Testing, tool placement guides
    │   └── tool-selection-diagram/  # Flowchart generator for multi-tool suites
    ├── udt-authoring/               # User-Defined Tools (GalaxyUserTool YAML)
    ├── nf-to-galaxy/                # Nextflow → Galaxy conversion
    ├── galaxy-integration/          # Instance integration router
    │   └── jupyterlite/             # JupyterLite notebooks (gxy package)
    ├── galaxy-mcp-reference/        # Galaxy MCP tool reference
    ├── collection-manipulation/     # Collection transformations
    ├── workflow-reports/            # Workflow report templates
    ├── reproduciblify/              # Turn ad-hoc analysis into a workflow
    ├── trackhubs/                   # UCSC Track Hub / Assembly Hub publishing
    ├── update-usegalaxy-tool/       # UseGalaxy tool management
    └── hub-news-posts/              # Galaxy Hub news posts
```

Skills live under `skills/` because that is the layout every major agent harness discovers
by convention -- Claude Code, Codex, and Antigravity all read it without extra configuration.

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
