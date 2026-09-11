# Update UseGalaxy Tool Skill

Add or update a Galaxy ToolShed tool revision in the [usegalaxy-tools](https://github.com/galaxyproject/usegalaxy-tools) repository.

## What This Skill Does

Guides AI agents through the full workflow of installing or updating a ToolShed tool on usegalaxy.org and test.galaxyproject.org — from resolving the correct changeset revision via the ToolShed API, through editing the YAML toolset files, to linting and committing the result.

The skill handles all four scenarios: adding a revision to an existing tool, adding a tool to an existing section, creating entirely new section files, and removing a tool from sections it should no longer belong to.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill definition — arguments, 7-step workflow, troubleshooting |
| `references/file-formats.md` | usegalaxy-tools YAML formats (`.yml` and `.yml.lock`), section ID derivation, ToolShed API endpoints, lint script usage |

## Usage

The skill accepts four arguments:

```
tool-name  owner  version  sections
```

Examples:
- `diamond bgruening 2.1.22 metagenomic_analysis,proteomics`
- `fastp iuc latest ngs_mapping`
- `multiqc iuc 1.24.1 quality_control`

Use `latest` as the version to automatically resolve the most recent ToolShed revision.

## Workflow Overview

1. **Detect toolset** — Scan for `usegalaxy.org/` and `test.galaxyproject.org/` directories
2. **Resolve revision** — Query the ToolShed API to find the changeset hash matching the requested version
3. **Find current occurrences** — Search all `.yml` and `.yml.lock` files for existing entries
4. **Compute diff plan** — Determine what needs to be added, updated, or removed, then present the plan for user approval
5. **Edit files** — Modify `.yml` and `.yml.lock` files following the formats in `references/file-formats.md`
6. **Lint** — Run `python scripts/fix_lockfile.py` on each modified file and flag any unexpected changes
7. **Commit** — Create a branch and commit (does not push — asks the user first)

## Key Concepts

### Toolset directories

The usegalaxy-tools repo contains one directory per Galaxy server:

- `usegalaxy.org/` — production
- `test.galaxyproject.org/` — test server

Each contains per-section `.yml` (unlocked) and `.yml.lock` (locked) file pairs.

### ToolShed API

The skill resolves tool revisions via three API calls:

1. `GET /repositories?name={name}&owner={owner}` — find the repo
2. `GET /repositories/{id}/installable_revisions` — list revision hashes
3. `GET /repositories/{id}/changeset_revision/{hash}` — get version metadata

### Section ID derivation

Section filenames and IDs are derived from the human-readable label by lowercasing and replacing non-alphanumeric characters with `_`:

- `Metagenomic Analysis` -> `metagenomic_analysis`
- `RNA-seq` -> `rna_seq`

## Prerequisites

- Working in a clone of [galaxyproject/usegalaxy-tools](https://github.com/galaxyproject/usegalaxy-tools)
- Python 3 available (for `scripts/fix_lockfile.py` and API queries)
- Network access to `toolshed.g2.bx.psu.edu`

## Troubleshooting

| Problem | Fix |
|---------|-----|
| ToolShed API returns empty array | Double-check tool name and owner against toolshed.g2.bx.psu.edu |
| No revision matches requested version | Use `latest` first, then check available version strings |
| `fix_lockfile.py` reorders unrelated tools | Expected if lock file was unsorted — commit normalization separately |
| Tool appears in unexpected sections | Re-check all occurrences in Step 3 before editing |
| YAML parse errors after editing | Lock files use 2-space indent; revision hashes go under `revisions:` with `- ` prefix |
