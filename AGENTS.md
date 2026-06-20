# Agent Instructions (galaxyproject/skills)

When working in this repository, treat the contents of `skills/` as the canonical source of “skills” and follow them as process guidance.

## Nextflow → Galaxy conversions

If the user asks to convert Nextflow pipelines/modules/processes to Galaxy tools/workflows, use the nf-to-galaxy skill family:

- Router:
  - `nf-to-galaxy/SKILL.md`

- Sub-skills:
  - `nf-to-galaxy/nf-process-to-galaxy-tool/SKILL.md`
  - `nf-to-galaxy/nf-subworkflow-to-galaxy-workflow/SKILL.md`
  - `nf-to-galaxy/nf-pipeline-to-galaxy-workflow/SKILL.md`

- Shared references:
  - `nf-to-galaxy/check-tool-availability.md`
  - `nf-to-galaxy/scripts/check_tool.sh`
  - `nf-to-galaxy/testing-and-validation.md` (routing page)
  - `tool-dev/references/testing.md` (Planemo tool testing)
  - `tool-dev/references/tool-placement.md` (where to create tools)
  - `galaxy-integration/galaxy-integration.md` (workflow testing on Galaxy instance)
  - `galaxy-integration/examples/` (tool checking and workflow testing examples)

Follow the planning/approval checkpoints required by the skills before implementing changes.

## Galaxy Integration

If the user asks about Galaxy MCP, JupyterLite notebooks, or BioBlend automation:

- Router:
  - `galaxy-integration/SKILL.md`

- Sub-skills:
  - `galaxy-integration/jupyterlite/SKILL.md` (JupyterLite notebooks with gxy package)
  - `galaxy-integration/mcp-reference/SKILL.md` (Galaxy MCP tools reference)

- References:
  - `galaxy-integration/mcp-reference/history-access.md` (history/dataset access patterns)
  - `galaxy-integration/mcp-reference/name-tags.md` (name tags for tracking workflow runs)
  - `galaxy-integration/mcp-reference/gotchas.md` (common pitfalls)
  - `galaxy-integration/galaxy-integration.md` (detailed MCP + BioBlend docs)
  - `galaxy-integration/scripts/galaxy_tool_checker.py` (BioBlend automation)
  - `galaxy-integration/examples/` (tool checking and workflow testing examples)
  - `galaxy-integration/jupyterlite/examples/` (JupyterLite notebook examples)

## Collection Manipulation

If the user asks to transform, filter, sort, relabel, restructure, flatten, nest, merge, or otherwise manipulate Galaxy dataset collections:

- Skill:
  - `collection-manipulation/SKILL.md` (single self-contained command)

- References:
  - `collection-manipulation/references/tools.md` (26 collection operation tools catalog)
  - `collection-manipulation/references/apply-rules.md` (Apply Rules DSL deep-dive)
  - `collection-manipulation/references/api-patterns.md` (Galaxy Tools API patterns)
  - `collection-manipulation/references/test-patterns.md` (real test patterns from Galaxy test suite)

All operations must use Galaxy's native tools for reproducibility and workflow compatibility.

## Update UseGalaxy Tools

If the user asks to add or update a ToolShed tool revision in the usegalaxy-tools repo:

- Skill:
  - `update-usegalaxy-tool/SKILL.md` (single self-contained command)

- References:
  - `update-usegalaxy-tool/references/file-formats.md` (usegalaxy-tools YAML file formats, ToolShed API, lint script)

## Workflow Reports

If the user asks to create, draft, or write a Galaxy workflow report template for the Workflow Editor's Report tab:

- Skill:
  - `workflow-reports/SKILL.md` (single self-contained skill)

- References:
  - `workflow-reports/references/directives.md` (Galaxy markdown directive reference)
  - `workflow-reports/examples/histology-staining.md` (worked example: imaging quantification)
  - `workflow-reports/examples/tissue-microarray-analysis.md` (worked example: multiplex tissue analysis)

## User-Defined Tools (UDTs)

If the user asks to create a tool they (a non-admin) can define and run in their own Galaxy account — the `class: GalaxyUserTool` YAML format, often created/run via Galaxy MCP `create_user_tool` / `run_user_tool` or `POST /api/unprivileged_tools` — use the udt-authoring skill. This is distinct from classic XML/ToolShed wrappers (use `tool-dev` for those).

- Skill:
  - `udt-authoring/SKILL.md`

- References:
  - `udt-authoring/references/schema-reference.md` (UserToolSource fields, input/output types, validators)
  - `udt-authoring/references/templating.md` (`$(...)` ECMAScript, `$GALAXY_SLOTS`, escaping)
  - `udt-authoring/references/common-mistakes.md` (pre-submit self-review checklist)
  - `udt-authoring/scripts/validate.py` (offline validate + lint via galaxy-tool-util)
  - `udt-authoring/examples/` (seven complete UDTs, simple to complex)

## Other skills in this repo

If the user asks about one of these tasks, use the corresponding skill:

- `hub-news-posts/SKILL.md` (Galaxy Hub news posts)
- `tool-dev/SKILL.md` (comprehensive Galaxy tool development reference)
  - `tool-dev/tool-selection-diagram/SKILL.md` (generate tool selection flowchart diagrams)
- `udt-authoring/SKILL.md` (author User-Defined Tools — GalaxyUserTool YAML)

For general discovery of what's available, start at `README.md`.
