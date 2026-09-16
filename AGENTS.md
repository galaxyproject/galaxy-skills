# Agent Instructions (galaxyproject/galaxy-skills)

When working in this repository, treat each directory holding a `SKILL.md` as the canonical source
of "skills" and follow them as process guidance. They sit in two trees. `skills/` holds everything
needed to *use* Galaxy to run an analysis, and is the tree every agent harness discovers.
`dev-skills/` holds skills for *building* Galaxy itself, and no agent harness scans it.

## Working against a live Galaxy instance

Driving a real Galaxy server (histories, uploads, running tools, invoking workflows) goes through
the [galaxy-mcp](https://github.com/galaxyproject/galaxy-mcp) MCP server, which any MCP-capable
agent can connect to. It needs `GALAXY_URL` and `GALAXY_API_KEY`. The tool surface is documented in
`skills/galaxy-mcp-reference/SKILL.md` -- read that before calling any Galaxy MCP tool. It
names the operations; match them to whatever your client exposes, since tool-naming differs
between MCP clients.

## Nextflow → Galaxy conversions

If the user asks to convert Nextflow pipelines/modules/processes to Galaxy tools/workflows, use the nf-to-galaxy skill family:

- Router:
  - `dev-skills/nf-to-galaxy/SKILL.md`

- Sub-skills:
  - `dev-skills/nf-to-galaxy/nf-process-to-galaxy-tool/SKILL.md`
  - `dev-skills/nf-to-galaxy/nf-subworkflow-to-galaxy-workflow/SKILL.md`
  - `dev-skills/nf-to-galaxy/nf-pipeline-to-galaxy-workflow/SKILL.md`

- Shared references:
  - `dev-skills/nf-to-galaxy/check-tool-availability.md`
  - `dev-skills/nf-to-galaxy/scripts/check_tool.sh`
  - `dev-skills/nf-to-galaxy/testing-and-validation.md` (routing page)
  - `dev-skills/tool-dev/references/testing.md` (Planemo tool testing)
  - `dev-skills/tool-dev/references/tool-placement.md` (where to create tools)
  - `skills/galaxy-integration/galaxy-integration.md` (workflow testing on Galaxy instance)
  - `skills/galaxy-integration/examples/` (tool checking and workflow testing examples)

Follow the planning/approval checkpoints required by the skills before implementing changes.

## Galaxy Integration

If the user asks about Galaxy MCP, JupyterLite notebooks, or BioBlend automation:

- Router:
  - `skills/galaxy-integration/SKILL.md`

- Sub-skills:
  - `skills/galaxy-integration/jupyterlite/SKILL.md` (JupyterLite notebooks with gxy package)
  - `skills/galaxy-mcp-reference/SKILL.md` (Galaxy MCP tools reference)

- References:
  - `skills/galaxy-mcp-reference/history-access.md` (history/dataset access patterns)
  - `skills/galaxy-mcp-reference/gotchas.md` (common pitfalls)
  - `skills/galaxy-integration/galaxy-integration.md` (detailed MCP + BioBlend docs)
  - `skills/galaxy-integration/scripts/galaxy_tool_checker.py` (BioBlend automation)
  - `skills/galaxy-integration/examples/` (tool checking and workflow testing examples)
  - `skills/galaxy-integration/jupyterlite/examples/` (JupyterLite notebook examples)

## Collection Manipulation

If the user asks to transform, filter, sort, relabel, restructure, flatten, nest, merge, or otherwise manipulate Galaxy dataset collections:

- Skill:
  - `skills/collection-manipulation/SKILL.md` (single self-contained command)

- References:
  - `skills/collection-manipulation/references/tools.md` (26 collection operation tools catalog)
  - `skills/collection-manipulation/references/apply-rules.md` (Apply Rules DSL deep-dive)
  - `skills/collection-manipulation/references/api-patterns.md` (Galaxy Tools API patterns)
  - `skills/collection-manipulation/references/test-patterns.md` (real test patterns from Galaxy test suite)

All operations must use Galaxy's native tools for reproducibility and workflow compatibility.

## Update UseGalaxy Tools

If the user asks to add or update a ToolShed tool revision in the usegalaxy-tools repo:

- Skill:
  - `dev-skills/update-usegalaxy-tool/SKILL.md` (single self-contained command)

- References:
  - `dev-skills/update-usegalaxy-tool/references/file-formats.md` (usegalaxy-tools YAML file formats, ToolShed API, lint script)

## Workflow Reports

If the user asks to create, draft, or write a Galaxy workflow report template for the Workflow Editor's Report tab:

- Skill:
  - `skills/workflow-reports/SKILL.md` (single self-contained skill)

- References:
  - `skills/workflow-reports/references/directives.md` (Galaxy markdown directive reference, synced from upstream Galaxy via `make sync-directives`)
  - `skills/workflow-reports/examples/histology-staining.md` (worked example: imaging quantification)
  - `skills/workflow-reports/examples/tissue-microarray-analysis.md` (worked example: multiplex tissue analysis)

## User-Defined Tools (UDTs)

If the user asks to create a tool they (a non-admin) can define and run in their own Galaxy account — the `class: GalaxyUserTool` YAML format, often created/run via Galaxy MCP `create_user_tool` / `run_user_tool` or `POST /api/unprivileged_tools` — use the udt-authoring skill. This is distinct from classic XML/ToolShed wrappers (use `dev-skills/tool-dev` for those).

- Skill:
  - `skills/udt-authoring/SKILL.md`

- References:
  - `skills/udt-authoring/references/schema-reference.md` (UserToolSource fields, input/output types, validators)
  - `skills/udt-authoring/references/templating.md` (`$(...)` ECMAScript, `$GALAXY_SLOTS`, escaping)
  - `skills/udt-authoring/references/common-mistakes.md` (pre-submit self-review checklist)
  - `skills/udt-authoring/scripts/validate.py` (offline validate + lint via galaxy-tool-util)
  - `skills/udt-authoring/examples/` (seven complete UDTs, simple to complex)

## Reproduciblify

If the user asks to "reproduciblify" a Galaxy history, rebuild a messy analysis on-graph, or turn a history into a clean Galaxy Notebook that extracts into a reusable workflow:

- Skill:
  - `skills/reproduciblify/SKILL.md` (single self-contained skill)

- References:
  - `skills/reproduciblify/references/directives.yml` (machine-readable Galaxy markdown directive metadata, synced from upstream Galaxy via `make sync-directives`)

Depends on `skills/galaxy-integration` (MCP access), `skills/collection-manipulation` (map/reduce restructuring), `dev-skills/tool-dev` (creating tools as a fallback), and `skills/workflow-reports` (markdown directives for embedding on-graph artifacts).

## Other skills in this repo

If the user asks about one of these tasks, use the corresponding skill:

- `dev-skills/hub-news-posts/SKILL.md` (Galaxy Hub news posts)
- `dev-skills/tool-dev/SKILL.md` (comprehensive Galaxy tool development reference)
  - `dev-skills/tool-dev/tool-selection-diagram/SKILL.md` (generate tool selection flowchart diagrams)
- `skills/udt-authoring/SKILL.md` (author User-Defined Tools — GalaxyUserTool YAML)
- `dev-skills/trackhubs/SKILL.md` (UCSC Track Hub / Assembly Hub publishing)

For general discovery of what's available, start at `README.md`.
