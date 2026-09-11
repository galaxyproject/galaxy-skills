# Galactic skills

This is a space for depositing various helpful artifacts ([skills](https://claude.com/blog/skills), [commands](https://code.claude.com/docs/en/slash-commands#personal-commands), etc.) for various agentic things like Claude Code or Gemini Code Agent. 
The idea is that by iterating over this we will create a robust set of community curated "skills" that would ultimately create guardrails preventing LLMs from doing crazy :shit: and ensuring best practices. Should probably be called Intergalactic LLM-taming commision (ILT).

This was not written by Claude.

> this is complementary to https://github.com/galaxyproject/galaxy-mcp

---

## What Are Skills?

Skills are structured instructions that teach an agent how to actually use Galaxy -- run analyses on
a real instance, keep the work on-graph and reproducible, and extend Galaxy when the tool you need
isn't there yet. They provide:

- **Best practices** - The right way to run, structure, and hand off an analysis
- **Patterns** - Common solutions to common problems
- **Examples** - Concrete references to learn from
- **Guardrails** - Preventing common mistakes

The analysis runs on Galaxy, not on your laptop. The agent drives a real Galaxy server over MCP, so
compute happens on Galaxy's infrastructure and every step lands in a history with full provenance --
a durable, shareable record rather than a folder of loose files. That includes writing new tools when
one is missing: User-Defined Tools let the agent add a custom step to an analysis without leaving
Galaxy or waiting on an admin.

## Skills vs MCP

| Repository | Purpose | Use For |
|------------|---------|---------|
| **skills** (this repo) | *Knowledge* - How to use Galaxy well | Running analyses, structuring collections, authoring User-Defined Tools, reproducible handoff |
| [**galaxy-mcp**](https://github.com/galaxyproject/galaxy-mcp) | *Capabilities* - Interact with Galaxy programmatically | The live connection the skills drive |

Use both together -- the plugin installs both.

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

These ship in the `galaxy` plugin. They are about *using* Galaxy -- running an analysis on a real
instance, keeping it structured and reproducible, and extending Galaxy when a tool you need is
missing.

**galaxy-integration** -- Connect an agent to a Galaxy instance and choose how to drive it (MCP,
JupyterLite notebooks, or BioBlend). Start here.

**galaxy-mcp-reference** -- The Galaxy MCP tool surface: histories, datasets, tools, workflows,
invocations, and the pitfalls that bite first.

**collection-manipulation** -- Transform Galaxy dataset collections reproducibly with native tools:
filter, sort, relabel, merge, flatten, nest, and the Apply Rules DSL.

**udt-authoring** -- Author User-Defined Tools: a `class: GalaxyUserTool` YAML definition wrapping a
container and command into a tool a non-admin user creates and runs. This is how an agent adds a
custom analysis step without leaving Galaxy or waiting on an admin.

**workflow-reports** -- Write workflow report templates for the Workflow Editor's Report tab.

**reproduciblify** -- Re-execute a messy, ad-hoc history as a clean, fully on-graph,
collection-structured analysis that extracts into a reusable workflow.

**trackhubs** -- Publish UCSC Track Hubs and Assembly Hubs from Galaxy outputs.

### Also in this repo (not in the plugin)

`dev-skills/` holds skills for *building* Galaxy rather than using it -- `tool-dev` (authoring tool
XML wrappers for tools-iuc), `nf-to-galaxy` (converting Nextflow processes and pipelines),
`update-usegalaxy-tool` (ToolShed revisions in usegalaxy-tools), and `hub-news-posts` (galaxyproject.org
news). They are deliberately excluded from the plugin so installing it doesn't hand an analyst a pile
of tool-development guidance, but they remain here to read, to link to, and to install by hand.

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
├── skills/                          # <- shipped in the plugin
│   ├── galaxy-integration/          # Connect and choose how to drive Galaxy
│   │   └── jupyterlite/             # JupyterLite notebooks (gxy package)
│   ├── galaxy-mcp-reference/        # Galaxy MCP tool surface
│   ├── collection-manipulation/     # Collection transformations
│   ├── udt-authoring/               # User-Defined Tools
│   ├── workflow-reports/            # Workflow report templates
│   ├── reproduciblify/              # Ad-hoc history -> reusable workflow
│   └── trackhubs/                   # UCSC Track Hub publishing
│
└── dev-skills/                      # <- in the repo, NOT in the plugin
    ├── tool-dev/                    # Authoring Galaxy tool XML wrappers
    ├── nf-to-galaxy/                # Nextflow -> Galaxy conversion
    ├── update-usegalaxy-tool/       # ToolShed revisions in usegalaxy-tools
    └── hub-news-posts/              # galaxyproject.org news posts
```

Every major agent harness -- Claude Code, Codex, and Antigravity -- discovers skills at `skills/`
by convention, and none of them scans `dev-skills/`. That is what keeps the plugin focused on
analysis without deleting anyone's work.

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
