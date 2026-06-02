---
name: user-defined-tools
description: Create Galaxy user-defined tools (UDTs) via `galaxy_create_user_tool`. Use when an agent needs to register a small custom tool in a user's Galaxy account — gap-filling glue, reformatters, light filters that aren't in the public tool panel. Every UDT must include a minimal `help` section.
---

# Galaxy User-Defined Tools

User-defined tools (UDTs) are server-side custom tools a user registers in
their own Galaxy account and runs unprivileged. They are *not* legacy
ToolShed XML wrappers — UDTs are created over the API as a JSON
representation, not as `<tool>` XML files reviewed by IUC.

This skill covers creation via the `galaxy_create_user_tool` MCP tool and
states the project convention that every UDT carries a `help` section.

## When to Use This Skill

- Agent needs a small custom tool that isn't in the Galaxy public panel.
- Use cases: column filters, format reshapers, joiners, header strippers,
  thin wrappers around a CLI step that fits between Galaxy native tools.
- The tool will run on Galaxy infrastructure under the user's own
  account (unprivileged), often dispatched to a per-user Pulsar
  endpoint.

**Do not** use this skill to author IUC tool wrappers — those are XML
artifacts reviewed by `tools-iuc`, see `tool-dev/SKILL.md`.

**Do not** invent a local script when a UDT would do — UDTs preserve
provenance in the user's history and stay reusable across sessions.

## The Representation Schema

UDTs are created with a JSON body of class `GalaxyUserTool`. Authoritative
schema:

- [`UserToolSource`](https://github.com/galaxyproject/galaxy/blob/dev/lib/galaxy/tool_util_models/__init__.py)
  — top-level fields.
- [`HelpContent`](https://github.com/galaxyproject/galaxy/blob/dev/lib/galaxy/tool_util_models/tool_source.py)
  — shape of `help`.
- API endpoint: `POST /api/unprivileged_tools` (the MCP tool wraps this).

Top-level fields the agent typically supplies:

| Field | Required | Notes |
|-------|----------|-------|
| `class` | Yes | Always `"GalaxyUserTool"`. |
| `id` | Yes | Lowercase, underscores. Stable identifier (`cut_column`, `pggb_align`). |
| `name` | Yes | Human-readable title case. |
| `version` | Yes | Semver. Increment on every iteration; old versions stay in Galaxy. |
| `container` | Yes | Pinned image (`ghcr.io/org/tool:tag`). |
| `shell_command` | Yes | The actual command. |
| `inputs` / `outputs` | Yes | Galaxy parameter / output declarations. |
| `description` | Recommended | One-line summary shown in tool list. |
| `requirements` | Optional | Conda packages if not relying on container. |
| `help` | **Required by convention** | See below. |
| `citations` | Optional | DOI preferred when wrapping a published method. |

## Help Section — Required by Convention

Every UDT registered through this skill must include a non-empty `help`
block. Galaxy renders it under the parameter form on the tool page; a UDT
without `help` is a documentation-free black box for any human (including
the same user weeks later) who opens it.

Wire shape — both fields are required by Galaxy:

```json
"help": {
  "format": "markdown",
  "content": "..."
}
```

`format` accepts `markdown`, `restructuredtext`, or `plain_text`. Default
to `markdown` — matches IUC tool-dev direction and renders identically to
modern XML help blocks.

### Minimal Template

Three short paragraphs is enough. Keep the structure free-form, but cover:

1. **What the tool does** — one sentence.
2. **Inputs and outputs** — a tiny bullet list or one sentence each.
3. **Caveats** — resource limits, expected file shape, any non-obvious
   behavior (one sentence).

```markdown
Cuts a single column from a tab-separated file.

**Inputs**
- `input`: TSV file (with or without header).
- `column`: 1-based column index.

**Outputs**
- `output`: TSV containing only the selected column, in input row order.

Empty rows in the input are preserved as empty rows in the output.
Header lines are not auto-detected — the column index applies to every
row.
```

## Example — Good vs Bad

### Good

```json
{
  "class": "GalaxyUserTool",
  "id": "cut_column",
  "name": "Cut Column",
  "version": "0.1.0",
  "description": "Extract a single column from a TSV file",
  "container": "quay.io/biocontainers/coreutils:9.4",
  "shell_command": "cut -f $column $input > $output",
  "inputs": [
    {"name": "input", "type": "data", "format": "tabular"},
    {"name": "column", "type": "integer", "value": 1, "min": 1}
  ],
  "outputs": [
    {"name": "output", "type": "data", "format": "tabular"}
  ],
  "help": {
    "format": "markdown",
    "content": "Cuts a single column from a tab-separated file.\n\n**Inputs**\n- `input`: TSV file.\n- `column`: 1-based column index.\n\n**Outputs**\n- `output`: TSV containing only the selected column.\n\nNo header detection; the column index applies to every row."
  }
}
```

### Bad

```json
{
  "class": "GalaxyUserTool",
  "id": "cut_column",
  "name": "Cut Column",
  "version": "0.1.0",
  "container": "quay.io/biocontainers/coreutils:9.4",
  "shell_command": "cut -f $column $input > $output",
  "inputs": [...],
  "outputs": [...]
  // help omitted — anyone opening this tool in Galaxy sees no docs
}
```

Equally bad — `help.content` set to a placeholder:

```json
"help": {"format": "markdown", "content": "TODO"}
```

If `help` is genuinely impossible to write (e.g. a single-line ad-hoc
probe the user explicitly does not want documented), say so in the
agent's response and ask the user to confirm before creating the UDT.

## Workflow

1. Decide a UDT is the right shape (gap-fill, reusable, runs on Galaxy
   infra). If it's a one-shot local probe, use a local script instead.
2. Pick a stable `id` and a starting `version` (typically `0.1.0`).
3. Pin the `container` to a versioned image — never `:latest`.
4. Author `inputs`, `outputs`, and `shell_command`.
5. **Write the `help.content` before calling `galaxy_create_user_tool`.**
   Three paragraphs, markdown. Cover what / inputs+outputs / caveats.
6. Call `galaxy_create_user_tool` with the full representation.
7. On iteration, bump `version` (e.g. `0.1.0` → `0.2.0`). Galaxy keeps
   every prior version under the user's account; there is no in-place
   update API.

## Iteration & Cleanup

Every `galaxy_create_user_tool` call creates a new UDT — there is no
update endpoint. Heavy iteration produces accumulated stale versions
under the user's account. Surface this to the user when iterating
aggressively and offer to delete superseded versions with
`galaxy_delete_user_tool` once the design stabilizes.

## Failure Modes

| Symptom | Likely cause |
|---------|--------------|
| HTTP 403 "User is not allowed to run unprivileged" | Galaxy admin has not configured a destination that accepts `tool_type_user_defined`. Default TPV behavior rejects UDTs — the admin must add a routing rule. Contact the admin; this is not fixable client-side. |
| HTTP 400 on `help` field | `help` was sent as a bare string. Wrap as `{format, content}`. |
| Tool runs but help is blank in UI | `help.content` empty or whitespace-only. Re-create with real content (no in-place edit). |

## References

- [`UserToolSource` schema](https://github.com/galaxyproject/galaxy/blob/dev/lib/galaxy/tool_util_models/__init__.py)
- [`HelpContent` schema](https://github.com/galaxyproject/galaxy/blob/dev/lib/galaxy/tool_util_models/tool_source.py)
- [Galaxy tool XML schema docs](https://docs.galaxyproject.org/en/master/dev/schema.html) — `<help>` rendering reference (UDTs render the same content the same way)
- [`tool-dev/SKILL.md`](../tool-dev/SKILL.md) — for full IUC-style XML tool wrappers (different surface, related help conventions)
