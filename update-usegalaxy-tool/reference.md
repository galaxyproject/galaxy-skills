# Reference: usegalaxy-tools File Formats

## Toolset directories

- `usegalaxy.org/` — production Galaxy server
- `test.galaxyproject.org/` — test server

## `.yml` file format (unlocked)

```yaml
tool_panel_section_label: Section Name
tools:
- name: tool_name
  owner: toolshed_owner
- name: another_tool
  owner: another_owner
  tool_shed_url: testtoolshed.g2.bx.psu.edu  # optional, only for non-default sheds
```

- `tool_panel_section_label` is the human-readable section name
- Each tool has `name` and `owner`; `tool_shed_url` is optional (defaults to main ToolShed)

## `.yml.lock` file format (locked)

```yaml
install_repository_dependencies: false
install_resolver_dependencies: false
install_tool_dependencies: false
tool_panel_section_label: Section Name
tools:
- name: tool_name
  owner: toolshed_owner
  revisions:
  - 0cdcf7e99b62
  - 54f751e413f4
  tool_panel_section_id: section_name
  tool_panel_section_label: Section Name
- name: another_tool
  owner: another_owner
  revisions:
  - abc123def456
  tool_panel_section_id: section_name
  tool_panel_section_label: Section Name
```

- Top-level `install_*` flags are always present
- `revisions` list is sorted alphabetically (hex strings)
- `tool_panel_section_id` is derived from the label (see below)
- `tool_panel_section_label` is repeated per tool

## Section ID derivation

Convert the label to a section ID:
- Lowercase the entire string
- Replace any non-alphanumeric character with `_`

Examples:
- `Metagenomic Analysis` → `metagenomic_analysis`
- `RNA-seq` → `rna_seq`
- `ChIP-seq` → `chip_seq`

Python implementation (from `scripts/fix_lockfile.py`):
```python
def section_id_chr(c):
    return (c if c in string.ascii_letters + string.digits else '_').lower()

def section_label_to_id(label):
    return ''.join(map(section_id_chr, label))
```

## New section file templates

When creating a section that doesn't exist yet:

**`{section_name}.yml`:**
```yaml
tool_panel_section_label: Section Label Here
tools:
- name: tool_name
  owner: owner_name
```

**`{section_name}.yml.lock`:**
```yaml
install_repository_dependencies: false
install_resolver_dependencies: false
install_tool_dependencies: false
tool_panel_section_label: Section Label Here
tools:
- name: tool_name
  owner: owner_name
  revisions:
  - changeset_hash
  tool_panel_section_id: section_label_here
  tool_panel_section_label: Section Label Here
```

## Section filename convention

The filename is the section ID: `metagenomic_analysis.yml`, `rna_seq.yml`, etc.

## ToolShed API endpoints

Base URL: `https://toolshed.g2.bx.psu.edu/api`

1. **Find repository:** `GET /repositories?name={tool_name}&owner={owner}`
   - Returns array; use `[0]["id"]` for repo ID

2. **Get installable revisions:** `GET /repositories/{repo_id}/installable_revisions`
   - Returns array of changeset hash strings

3. **Get revision metadata:** `GET /repositories/{repo_id}/changeset_revision/{hash}`
   - Contains `tool_versions` dict and/or `tools` array with version info
   - Match the desired version against tool version strings

## Lint script

```bash
python scripts/fix_lockfile.py path/to/section.yml
```

This script:
- Deduplicates tools
- Sorts revisions alphabetically
- Sets `tool_panel_section_id` from the label
- Adds `install_*` flags
- Writes the cleaned `.yml.lock`
