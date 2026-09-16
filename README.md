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

Use both together -- the skills describe how to drive the connection galaxy-mcp provides.

---

## Installation & Usage

### Claude Code / Codex / Antigravity

Clone into the skills directory your agent reads:

```bash
cd ~/.claude/skills
git clone https://github.com/galaxyproject/galaxy-skills galaxy
```

Packaged installs -- a marketplace entry that also wires up the MCP server -- are assembled in a
separate distribution repository, which vendors the `skills/` tree from here. This repository stays
the source of the skills themselves.

### Windsurf / Cursor / Aider (via openskills)

```bash
# Install openskills
npm i -g openskills

# Install Galaxy skills
openskills install galaxyproject/galaxy-skills

# Load a specific skill when needed
openskills read galaxy-mcp-reference
```

### Any Agent (Manual)

Clone this repo into your workspace and reference skills in your prompts:

```bash
git clone https://github.com/galaxyproject/galaxy-skills
```

The LLM can read skill files directly from the workspace.

### Connecting to a Galaxy instance

The skills drive a live server through [galaxy-mcp](https://github.com/galaxyproject/galaxy-mcp),
which runs under `uvx` and needs an instance and a key:

```bash
export GALAXY_URL=https://usegalaxy.org   # this is the default if unset
export GALAXY_API_KEY=your_api_key        # User -> Preferences -> Manage API Key
```

A `.env` file in your working directory works too, and credentials can also be supplied at runtime
with `connect(url, api_key)`. The server exposes 45 tools; `GALAXY_MCP_EXCLUDE_TAGS` and
`GALAXY_MCP_INCLUDE_TAGS` trim what sits in context. `skills/galaxy-integration/` covers the setup
and the alternatives (JupyterLite, BioBlend) in more detail.

---

## Available Skills

`skills/` holds the skills for *using* Galaxy -- running an analysis on a real instance, keeping it
structured and reproducible, and extending Galaxy when a tool you need is missing. This is the tree
a packaged install ships.

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

### Also in this repo (not shipped to analysts)

`dev-skills/` holds skills for *building* Galaxy rather than using it -- `tool-dev` (authoring tool
XML wrappers for tools-iuc), `nf-to-galaxy` (converting Nextflow processes and pipelines),
`update-usegalaxy-tool` (ToolShed revisions in usegalaxy-tools), `trackhubs` (publishing UCSC Track
Hubs, which is mostly UCSC tooling outside Galaxy), and `hub-news-posts` (galaxyproject.org news).
They sit outside `skills/` so that installing the analysis set doesn't hand an analyst a pile of
tool-development guidance, but they remain here to read, to link to, and to install by hand.

## Repository Structure

```
galaxy-skills/
├── AGENTS.md                    # Cross-agent routing instructions
├── CONTRIBUTING.md              # How to add new skills
│
├── skills/                          # <- using Galaxy; this is what gets packaged
│   ├── galaxy-integration/          # Connect and choose how to drive Galaxy
│   │   └── jupyterlite/             # JupyterLite notebooks (gxy package)
│   ├── galaxy-mcp-reference/        # Galaxy MCP tool surface
│   ├── collection-manipulation/     # Collection transformations
│   ├── udt-authoring/               # User-Defined Tools
│   ├── workflow-reports/            # Workflow report templates
│   └── reproduciblify/              # Ad-hoc history -> reusable workflow
│
└── dev-skills/                      # <- building Galaxy; not registered by any harness
    ├── tool-dev/                    # Authoring Galaxy tool XML wrappers
    ├── nf-to-galaxy/                # Nextflow -> Galaxy conversion
    ├── trackhubs/                    # UCSC Track Hub publishing
    ├── update-usegalaxy-tool/       # ToolShed revisions in usegalaxy-tools
    └── hub-news-posts/              # galaxyproject.org news posts
```

Every major agent harness -- Claude Code, Codex, and Antigravity -- discovers skills at `skills/`
by convention, and none of them scans `dev-skills/`. That is what keeps an install focused on
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

### Running an analysis

```
User: "Upload these FASTQ files and run FastQC on all of them"

AI: [Loads galaxy-integration to connect, then galaxy-mcp-reference]
    [Creates a history, uploads the reads]
    [Builds a list collection so one job covers every sample]
    [Runs FastQC mapped over the collection, reports when the jobs finish]
```

### Adding a step Galaxy doesn't have

```
User: "There's no Galaxy tool for this container -- can I still run it?"

AI: [Loads udt-authoring skill]
    [Writes a `class: GalaxyUserTool` YAML wrapping the container]
    [Creates it with create_user_tool and runs it -- no admin required]
```

### Making a messy history reproducible

```
User: "Turn this history into something I can rerun on new samples"

AI: [Loads reproduciblify skill]
    [Re-executes the analysis on-graph with collection structure]
    [Authors a notebook that extracts into a sample-agnostic workflow]
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
