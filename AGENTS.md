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
  - `tool-dev/shared/testing.md` (Planemo tool testing)
  - `tool-dev/creation/tool-placement.md` (where to create tools)
  - `galaxy-integration/galaxy-integration.md` (workflow testing on Galaxy instance)
  - `galaxy-integration/examples/` (tool checking and workflow testing examples)

Follow the planning/approval checkpoints required by the skills before implementing changes.

## Other skills in this repo

If the user asks about one of these tasks, use the corresponding skill:

- `hub-news-posts/SKILL.md` (Galaxy Hub news posts)
- `tool-dev/SKILL.md` (Galaxy tool development - router to creation/ or updates/)

For general discovery of what's available, start at `README.md`.
