---
name: gxwf-cli
description: Reference for the @galaxy-tool-util/cli binaries — gxwf (workflow validate / clean / lint / convert / roundtrip / mermaid, single-file and tree variants) and galaxy-tool-cache (tool metadata caching). Generated from commander; re-run `make gen-skill` after CLI churn.
---

<!--
SYNCED DOCUMENT — do not hand-edit.
Source of truth: https://github.com/jmchilton/galaxy-tool-util-ts/blob/main/docs/skills/gxwf-cli/SKILL.md
Raw:             https://raw.githubusercontent.com/jmchilton/galaxy-tool-util-ts/main/docs/skills/gxwf-cli/SKILL.md
Upstream it is generated from the CLI via `make gen-skill`.
To update here:  run `make -C gxwf-cli sync` (re-pulls the raw source).
-->

# galaxy-tool-util CLI reference

Single-page skill covering both binaries shipped by `@galaxy-tool-util/cli`.
Auto-generated from the commander program definitions — do not hand-edit.

## `gxwf`

Galaxy workflow operations — validate, clean, lint, convert (single-file and tree)

### `validate <file>`

Validate Galaxy workflow files (structure + optional tool state)

**Arguments:**

- `<file>` — Workflow file (.ga, .gxwf.yml)

| Option | Description |
|---|---|
| `--format <fmt>` | Force format: native or format2 (auto-detected by default) |
| `--no-tool-state` | Skip tool state validation |
| `--cache-dir <dir>` | Tool cache directory |
| `--mode <mode>` | Validation backend: effect (default) or json-schema (default: `effect`) |
| `--tool-schema-dir <dir>` | Directory of pre-exported per-tool JSON Schemas (for offline json-schema mode) |
| `--json` | Output structured JSON report |
| `--report-html [file]` | Write HTML report to file (or stdout if omitted) |
| `--connections` | Validate connection-type compatibility (collection algebra, map-over) |
| `--strict` | Shorthand for --strict-structure --strict-encoding --strict-state |
| `--strict-structure` | Reject unknown keys at envelope/step level |
| `--strict-encoding` | Reject JSON-string tool_state and format2 field misuse |
| `--strict-state` | Require every tool step to validate; no skips allowed |

### `validate-tests <file>`

Validate a workflow-test file (*-tests.yml, *.gxwf-tests.yml) against the Galaxy Tests schema

**Arguments:**

- `<file>` — Tests file (*-tests.yml)

| Option | Description |
|---|---|
| `--json` | Output structured JSON report |
| `--workflow <path>` | Cross-check job inputs + output assertions against a workflow (.ga / .gxwf.yml) |

### `draft-validate <file>`

Validate a draft Galaxy workflow (class: GalaxyWorkflowDraft)

**Arguments:**

- `<file>` — Draft workflow file (.gxwf.yml)

| Option | Description |
|---|---|
| `--format <fmt>` | Force format: format2 (native is rejected for drafts) |
| `--json` | Output structured JSON report |
| `--report-html [file]` | Write HTML report to file (or stdout if omitted) |
| `--report-markdown [file]` | Write Markdown report to file (or stdout if omitted) |
| `--concrete` | Additionally extract the concrete subset and run the regular `gxwf validate` checks on it |
| `--cache-dir <dir>` | Tool cache directory (for --concrete tool-state validation) |
| `--no-tool-state` | Skip tool-state validation in the --concrete pass (default: enabled when --concrete is set) |
| `--connections` | Validate connection-type compatibility on the --concrete subset (collection algebra, map-over) |
| `--strict` | Shorthand for --strict-structure --strict-encoding --strict-state |
| `--strict-structure` | Reject unknown keys at envelope/step level |
| `--strict-encoding` | Reject JSON-string tool_state and format2 field misuse |
| `--strict-state` | Require every tool step to validate; no skips allowed |

### `draft-extract <file>`

Extract the concrete subset of a draft workflow (drop drafty steps, strip _plan_* fields, promote class when fully concrete)

**Arguments:**

- `<file>` — Draft workflow file (.gxwf.yml)

| Option | Description |
|---|---|
| `-o, --output <file>` | Write extracted workflow to file (default: stdout) |
| `--report-json [file]` | Write extraction report JSON (drops, rewrites, class flip) — to file or stdout if omitted |
| `--format <fmt>` | Force input format: format2 (default; native is rejected) |

### `draft-next-step <file>`

Pick the next step a downstream agent should work on (or report no remaining work)

**Arguments:**

- `<file>` — Draft workflow file (.gxwf.yml)

| Option | Description |
|---|---|
| `--format <fmt>` | Force input format: format2 (default; native is rejected) |
| `--output-format <fmt>` | Output format: json (default) or markdown (default: `json`) |

### `clean <file>`

Strip stale keys and decode legacy tool_state encoding

**Arguments:**

- `<file>` — Workflow file (.ga, .gxwf.yml)

| Option | Description |
|---|---|
| `--output <file>` | Write cleaned workflow to file (default: stdout) |
| `--diff` | Show diff of changes instead of writing output |
| `--format <fmt>` | Force format: native or format2 (auto-detected by default) |
| `--json` | Output structured JSON report |
| `--report-html [file]` | Write HTML report to file (or stdout if omitted) |
| `--skip-uuid` | Skip stripping uuid fields (errors are always stripped) |

### `lint <file>`

Lint Galaxy workflow — structural checks, best practices, tool state validation

**Arguments:**

- `<file>` — Workflow file (.ga, .gxwf.yml)

| Option | Description |
|---|---|
| `--skip-best-practices` | Skip annotation/creator/license/label checks |
| `--skip-state-validation` | Skip tool state validation against cached tool definitions |
| `--cache-dir <dir>` | Tool cache directory (for state validation) |
| `--format <fmt>` | Force format: native or format2 (auto-detected by default) |
| `--json` | Output structured JSON result |
| `--report-html [file]` | Write HTML report to file (or stdout if omitted) |
| `--strict` | Shorthand for --strict-structure --strict-encoding --strict-state |
| `--strict-structure` | Reject unknown keys at envelope/step level |
| `--strict-encoding` | Reject JSON-string tool_state and format2 field misuse |
| `--strict-state` | Require every tool step to validate; no skips allowed |

### `convert <file>`

Convert between native (.ga) and format2 (.gxwf.yml) formats

**Arguments:**

- `<file>` — Workflow file (.ga, .gxwf.yml)

| Option | Description |
|---|---|
| `--to <format>` | Target format: native or format2 (infers opposite by default) |
| `--output <file>` | Write result to file (default: stdout) |
| `--compact` | Omit position info in format2 output |
| `--json` | Force JSON output |
| `--yaml` | Force YAML output |
| `--format <fmt>` | Force source format (auto-detected by default) |
| `--stateful` | Use cached tool definitions for schema-aware state re-encoding |
| `--cache-dir <dir>` | Tool cache directory (for --stateful) |
| `--strict` | Shorthand for --strict-structure --strict-encoding --strict-state |
| `--strict-structure` | Reject unknown keys at envelope/step level |
| `--strict-encoding` | Reject JSON-string tool_state and format2 field misuse |
| `--strict-state` | Require every tool step to validate; no skips allowed |

### `roundtrip <file>`

Roundtrip-validate a native workflow: native → format2 → native, diff tool_state

**Arguments:**

- `<file>` — Native workflow file (.ga)

| Option | Description |
|---|---|
| `--cache-dir <dir>` | Tool cache directory |
| `--format <fmt>` | Force source format (must resolve to native) |
| `--json` | Output structured JSON report |
| `--errors-only` | Suppress benign diffs and clean steps from output |
| `--benign-only` | Show only steps with benign diffs (no errors, no failures) |
| `--brief` | Omit per-diff list; show only the one-line summary |
| `--strict` | Shorthand for --strict-structure --strict-encoding --strict-state |
| `--strict-structure` | Reject unknown keys at envelope/step level |
| `--strict-encoding` | Reject JSON-string tool_state and format2 field misuse |
| `--strict-state` | Require every tool step to validate; no skips allowed |

### `mermaid <file> [output]`

Render a Galaxy workflow as a Mermaid flowchart diagram

**Arguments:**

- `<file>` — Workflow file (.ga, .gxwf.yml)
- `[output]` — Output path (.mmd for raw, .md for fenced code block); stdout if omitted

| Option | Description |
|---|---|
| `--comments` | Render frame comments as Mermaid subgraphs |
| `--annotate-connections` | Encode map-over depth and reductions on edges (runs the connection validator) |
| `--cache-dir <dir>` | Tool cache directory (used by --annotate-connections) |

### `cytoscapejs <file> [output]`

Render a Galaxy workflow as Cytoscape.js elements (JSON or standalone HTML)

**Arguments:**

- `<file>` — Workflow file (.ga, .gxwf.yml)
- `[output]` — Output path (.json or .html); stdout JSON if omitted

| Option | Description |
|---|---|
| `--html` | Force HTML output regardless of file extension |
| `--json` | Force JSON output regardless of file extension |
| `--annotate-connections` | Encode map-over depth and reductions on edges (runs the connection validator) |
| `--cache-dir <dir>` | Tool cache directory (used by --annotate-connections) |

### `validate-tree <dir>`

Batch validate all workflows under a directory

**Arguments:**

- `<dir>` — Directory to scan for workflows

| Option | Description |
|---|---|
| `--format <fmt>` | Force format: native or format2 (auto-detected by default) |
| `--no-tool-state` | Skip tool state validation |
| `--cache-dir <dir>` | Tool cache directory |
| `--mode <mode>` | Validation backend: effect (default) or json-schema (default: `effect`) |
| `--tool-schema-dir <dir>` | Directory of pre-exported per-tool JSON Schemas (for offline json-schema mode) |
| `--json` | Output structured JSON report |
| `--report-markdown [file]` | Write Markdown report to file (or stdout if omitted) |
| `--report-html [file]` | Write HTML report to file (or stdout if omitted) |
| `--strict` | Shorthand for --strict-structure --strict-encoding --strict-state |
| `--strict-structure` | Reject unknown keys at envelope/step level |
| `--strict-encoding` | Reject JSON-string tool_state and format2 field misuse |
| `--strict-state` | Require every tool step to validate; no skips allowed |

### `lint-tree <dir>`

Batch lint all workflows under a directory

**Arguments:**

- `<dir>` — Directory to scan for workflows

| Option | Description |
|---|---|
| `--skip-best-practices` | Skip annotation/creator/license/label checks |
| `--skip-state-validation` | Skip tool state validation against cached tool definitions |
| `--cache-dir <dir>` | Tool cache directory (for state validation) |
| `--format <fmt>` | Force format: native or format2 (auto-detected by default) |
| `--json` | Output structured JSON report |
| `--report-markdown [file]` | Write Markdown report to file (or stdout if omitted) |
| `--report-html [file]` | Write HTML report to file (or stdout if omitted) |
| `--strict` | Shorthand for --strict-structure --strict-encoding --strict-state |
| `--strict-structure` | Reject unknown keys at envelope/step level |
| `--strict-encoding` | Reject JSON-string tool_state and format2 field misuse |
| `--strict-state` | Require every tool step to validate; no skips allowed |

### `clean-tree <dir>`

Batch clean all workflows under a directory

**Arguments:**

- `<dir>` — Directory to scan for workflows

| Option | Description |
|---|---|
| `--output-dir <dir>` | Write cleaned workflows to directory (mirrors source tree) |
| `--format <fmt>` | Force format: native or format2 (auto-detected by default) |
| `--json` | Output structured JSON report |
| `--report-markdown [file]` | Write Markdown report to file (or stdout if omitted) |
| `--report-html [file]` | Write HTML report to file (or stdout if omitted) |
| `--skip-uuid` | Skip stripping uuid fields (errors are always stripped) |

### `convert-tree <dir>`

Batch convert all workflows under a directory

**Arguments:**

- `<dir>` — Directory to scan for workflows

| Option | Description |
|---|---|
| `--to <format>` | Target format: native or format2 (infers opposite by default) |
| `--output-dir <dir>` | Write converted workflows to directory (required) |
| `--compact` | Omit position info in format2 output |
| `--report-json` | Output structured JSON report |
| `--json` | Force JSON output for converted files |
| `--yaml` | Force YAML output |
| `--format <fmt>` | Force source format (auto-detected by default) |
| `--stateful` | Use cached tool definitions for schema-aware state re-encoding |
| `--cache-dir <dir>` | Tool cache directory (for --stateful) |
| `--strict` | Shorthand for --strict-structure --strict-encoding --strict-state |
| `--strict-structure` | Reject unknown keys at envelope/step level |
| `--strict-encoding` | Reject JSON-string tool_state and format2 field misuse |
| `--strict-state` | Require every tool step to validate; no skips allowed |

### `roundtrip-tree <dir>`

Batch roundtrip-validate native workflows under a directory

**Arguments:**

- `<dir>` — Directory to scan for native workflows

| Option | Description |
|---|---|
| `--cache-dir <dir>` | Tool cache directory |
| `--format <fmt>` | Force source format (must resolve to native) |
| `--json` | Output structured JSON report |
| `--errors-only` | List only files with errors or failures |
| `--benign-only` | List only files with benign diffs (no errors, no failures) |
| `--brief` | Omit per-file lines; print only the aggregate summary |
| `--report-markdown [file]` | Write Markdown report to file (or stdout if omitted) |
| `--report-html [file]` | Write HTML report to file (or stdout if omitted) |
| `--strict` | Shorthand for --strict-structure --strict-encoding --strict-state |
| `--strict-structure` | Reject unknown keys at envelope/step level |
| `--strict-encoding` | Reject JSON-string tool_state and format2 field misuse |
| `--strict-state` | Require every tool step to validate; no skips allowed |

### `validate-tests-tree <dir>`

Batch validate workflow-test files (*-tests.yml / *.gxwf-tests.yml) under a directory

**Arguments:**

- `<dir>` — Directory to scan for test files

| Option | Description |
|---|---|
| `--json` | Output structured JSON report |
| `--auto-workflow` | Pair each tests file with a sibling workflow by filename convention (foo.gxwf-tests.yml ↔ foo.gxwf.yml/foo.ga) and cross-check inputs/outputs |

### `validate-tool-source <file>`

Validate a user-defined Galaxy tool source YAML (class: GalaxyUserTool / GalaxyTool) against the Galaxy DynamicToolSources schema + #22615 semantic checks

**Arguments:**

- `<file>` — Tool source YAML file

| Option | Description |
|---|---|
| `--json` | Output structured JSON report |
| `--schema-only` | Skip semantic (model_validator) checks; structural JSON-Schema validation only |

### `validate-tool-source-tree <dir>`

Batch validate user-defined Galaxy tool source YAMLs (auto-discovered by class:) under a directory

**Arguments:**

- `<dir>` — Directory to scan for tool source files

| Option | Description |
|---|---|
| `--json` | Output structured JSON report |
| `--schema-only` | Skip semantic (model_validator) checks; structural JSON-Schema validation only |

### `tool-search <query>`

Search the Galaxy Tool Shed for tools matching a query

**Arguments:**

- `<query>` — Search text (e.g. 'fastqc')

| Option | Description |
|---|---|
| `--page-size <n>` | Server-side page size (default: `20`) |
| `--max-results <n>` | Hard cap on hits returned (default: `50`) |
| `--page <n>` | Starting page (1-indexed) (default: `1`) |
| `--owner <user>` | Filter hits to a single repo owner (client-side) |
| `--match-name` | Drop hits where the query is not a token in the tool name |
| `--json` | Emit machine-readable JSON envelope |
| `--enrich` | Resolve each hit's ParsedTool and attach it as `parsedTool` (one fetch per hit; off by default) |
| `--cache-dir <dir>` | Tool cache directory (used by --enrich; shared with galaxy-tool-cache) |

### `tool-versions <tool-id>`

List TRS-published versions of a Tool Shed tool (newest last)

**Arguments:**

- `<tool-id>` — TRS id (owner~repo~tool_id) or pretty form (owner/repo/tool_id)

| Option | Description |
|---|---|
| `--json` | Emit machine-readable JSON envelope |
| `--latest` | Print only the latest version |

### `tool-revisions <tool-id>`

List changeset revisions that publish a Tool Shed tool (ordered oldest→newest). Use for reproducible (name, owner, changeset_revision) workflow pins. Caveat: version strings are not monotonic — the same version can appear in multiple changesets.

**Arguments:**

- `<tool-id>` — TRS id (owner~repo~tool_id) or pretty form (owner/repo/tool_id)

| Option | Description |
|---|---|
| `--tool-version <v>` | Restrict to revisions that publish this exact tool version |
| `--latest` | Print only the newest matching revision |
| `--json` | Emit machine-readable JSON envelope |

### `repo-search <query>`

Search the Galaxy Tool Shed for repositories. Ranking is popularity-boosted; supports server-side --owner / --category filters via reserved keywords.

**Arguments:**

- `<query>` — Search text (e.g. 'fastqc')

| Option | Description |
|---|---|
| `--page-size <n>` | Server-side page size (default: `20`) |
| `--max-results <n>` | Hard cap on hits returned (default: `50`) |
| `--page <n>` | Starting page (1-indexed) (default: `1`) |
| `--owner <user>` | Restrict to a single owner (server-side `owner:` keyword) |
| `--category <name>` | Restrict to a category (server-side `category:` keyword) |
| `--json` | Emit machine-readable JSON envelope |

### `structural-schema`

Export the structural JSON Schema for Galaxy workflows

| Option | Description |
|---|---|
| `--format <fmt>` | Workflow format: format2 (default) or native (default: `format2`) |
| `--output <file>` | Output file (default: stdout) |

## `galaxy-tool-cache`

Cache and inspect Galaxy tool metadata

### `add <tool_id>`

Fetch a tool from ToolShed/Galaxy and cache it

**Arguments:**

- `<tool_id>` — Tool ID (full toolshed path or TRS ID)

| Option | Description |
|---|---|
| `--tool-version <ver>` | Tool version |
| `--cache-dir <dir>` | Cache directory |
| `--galaxy-url <url>` | Galaxy instance URL for fallback |

### `list`

List cached tools

| Option | Description |
|---|---|
| `--json` | Output as JSON |
| `--cache-dir <dir>` | Cache directory |

### `info <tool_id>`

Show metadata for a cached tool

**Arguments:**

- `<tool_id>` — Tool ID

| Option | Description |
|---|---|
| `--tool-version <ver>` | Tool version |
| `--cache-dir <dir>` | Cache directory |

### `clear [prefix]`

Clear cached tools

**Arguments:**

- `[prefix]` — Only clear tools matching this prefix

| Option | Description |
|---|---|
| `--cache-dir <dir>` | Cache directory |

### `schema <tool_id>`

Export JSON Schema for a cached tool's parameters

**Arguments:**

- `<tool_id>` — Tool ID

| Option | Description |
|---|---|
| `--tool-version <ver>` | Tool version |
| `--representation <rep>` | State representation (e.g., workflow_step) (default: `workflow_step`) |
| `--output <file>` | Output file (default: stdout) |
| `--cache-dir <dir>` | Cache directory |

### `summarize <tool_id>`

Emit a deterministic summary manifest for a cached Galaxy tool

**Arguments:**

- `<tool_id>` — Tool ID

| Option | Description |
|---|---|
| `--tool-version <ver>` | Tool version |
| `--output <file>` | Output file (default: stdout) |
| `--cache-dir <dir>` | Cache directory |

### `populate-workflow <file>`

Scan a workflow and cache all referenced tools

**Arguments:**

- `<file>` — Workflow file (.ga, .gxwf.yml)

| Option | Description |
|---|---|
| `--cache-dir <dir>` | Cache directory |
| `--galaxy-url <url>` | Galaxy instance URL for fallback |
