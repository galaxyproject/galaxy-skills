---
name: update-usegalaxy-tool
description: Add/update a ToolShed tool revision in usegalaxy-tools repo
argument-hint: [tool-name] [owner] [version] [sections]
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
---

# Update UseGalaxy Tool

Add or update a Galaxy ToolShed tool revision in the `usegalaxy-tools` repository.

## Arguments

- `$0` — tool name (e.g. `diamond`)
- `$1` — ToolShed owner (e.g. `bgruening`)
- `$2` — version string or `latest` (e.g. `2.1.22`)
- `$3` — comma-separated target section(s) (e.g. `metagenomic_analysis,proteomics`)

## Workflow

### Step 1 — Detect toolset

Scan the current working directory for `usegalaxy.org/` and/or `test.galaxyproject.org/` directories.

- If neither exists, error: "Not in a usegalaxy-tools repo"
- Default: operate on all found toolsets

### Step 2 — Resolve revision from ToolShed

Use the ToolShed API to find the changeset revision matching the requested version.

```bash
# Get repo ID
REPO=$(curl -s "https://toolshed.g2.bx.psu.edu/api/repositories?name=$0&owner=$1")
REPO_ID=$(echo "$REPO" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['id'])")

# Get all installable revisions
REVISIONS=$(curl -s "https://toolshed.g2.bx.psu.edu/api/repositories/$REPO_ID/installable_revisions")
```

For each revision hash, fetch metadata to find the one matching `$2`:
```bash
curl -s "https://toolshed.g2.bx.psu.edu/api/repositories/$REPO_ID/changeset_revision/$HASH"
```

Look for `"tool_versions"` keys containing `$2` in the version string, or check `"tools"` array `"version"` field.

If `$2` is `latest`, use the last revision in the installable_revisions list and report what version it corresponds to.

Display: `Found revision: $HASH (version $VERSION)`

### Step 3 — Find current occurrences

Search across all `.yml` and `.yml.lock` files in each toolset directory:

```
grep -rl "name: $0" {toolset}/*.yml
```

Report which sections currently have the tool and which revisions are installed.

### Step 4 — Compute diff plan

For each section in `$3` (comma-separated):

| Situation | Action |
|-----------|--------|
| Section exists, tool present | Add new revision to `.yml.lock` `revisions` list |
| Section exists, tool absent | Add tool to both `.yml` and `.yml.lock` |
| Section `.yml` doesn't exist | Create new `.yml` + `.yml.lock` files |
| Tool in section NOT in `$3` | Remove tool from both `.yml` and `.yml.lock` |

**Present the plan to the user and wait for confirmation before editing.**

### Step 5 — Edit files

Read `references/file-formats.md` (in this skill's directory) for file format details.

**Adding tool to `.yml`:** Insert under `tools:`:
```yaml
- name: $TOOL_NAME
  owner: $OWNER
```

**Adding tool to `.yml.lock`:** Insert a block:
```yaml
- name: $TOOL_NAME
  owner: $OWNER
  revisions:
  - $HASH
  tool_panel_section_id: $SECTION_ID
  tool_panel_section_label: $SECTION_LABEL
```

**Adding revision to existing tool in `.yml.lock`:** Insert the new hash into the `revisions` list, keeping alphabetical order.

**Removing a tool:** Delete the tool's `- name: ... owner: ...` block from `.yml` and the full block (including revisions/section info) from `.yml.lock`.

**Creating new section files:** See `references/file-formats.md` for templates.

### Step 6 — Lint

Run the lockfile fixer on each modified `.yml` file:

```bash
python scripts/fix_lockfile.py $MODIFIED_YML_FILE
```

Then check `git diff` to see if fix_lockfile changed anything unexpected beyond what you edited. Flag any surprises to the user.

### Step 7 — Commit (stop here)

- Create branch: `update_${tool_name}_${version}` (if not already on it)
- Stage all changed files
- Commit with message like: `Update $TOOL_NAME to $VERSION in $SECTIONS`
- **Do NOT push or create PR.** Ask the user if they want to push/PR.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| ToolShed API returns empty array | Tool name or owner is misspelled | Double-check name/owner against toolshed.g2.bx.psu.edu |
| No revision matches requested version | Version string doesn't match ToolShed metadata exactly | Use `latest` to find the most recent, then check what version strings are available |
| `fix_lockfile.py` reorders unrelated tools | Lock file was previously unsorted | Expected — review the diff and commit the normalization separately |
| Tool appears in unexpected sections after update | Existing entries in other sections weren't noticed in Step 3 | Re-run Step 3 and review all occurrences before editing |
| YAML parse errors after editing | Indentation mismatch (spaces vs tabs, wrong depth) | Lock files use 2-space indent; revision hashes are indented under `revisions:` with `- ` prefix |
