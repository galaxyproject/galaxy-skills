---
name: udt-authoring
description: Use when authoring a Galaxy User-Defined Tool (UDT) -- a `class: GalaxyUserTool` YAML definition that wraps a container and command into a tool a non-admin user creates and runs (e.g. via Galaxy MCP create_user_tool / run_user_tool, or POST /api/unprivileged_tools). Not for classic XML/ToolShed tool wrappers.
version: 1.0.0
tags: [galaxy, tools, udt, user-defined-tools, custom-tool]
---

# Authoring Galaxy User-Defined Tools (UDTs)

A **User-Defined Tool (UDT)** is a tool that a regular (non-admin) Galaxy user defines in YAML
and runs unprivileged, introduced in Galaxy 25.0. It is declared with `class: GalaxyUserTool` and
validated against the `UserToolSource` schema. This skill is the reference for producing a correct,
lint-clean definition.

## When to Use

- The user wants to wrap a command + container as a runnable Galaxy tool they own.
- Triggers: "make me a Galaxy tool that runs X", "wrap this command as a UDT", "create a custom
  tool", "register a tool in my account".
- You are an external agent (Loom, an MCP client, a notebook) that will create/run the tool via
  `create_user_tool` / `run_user_tool` or `POST /api/unprivileged_tools`.

**When NOT to use:** classic XML / ToolShed tool wrappers (Cheetah templating, `tools-iuc`
submission) -- that is a different format; use the `tool-dev` skill instead. A UDT is **not** XML
and does **not** use Cheetah.

## Mental Model (read this first -- it is where agents go wrong)

A UDT = a **container** + a **`shell_command`** + typed **`inputs`** and **`outputs`**.

- The command lives under **`shell_command`** (NOT `command`).
- Parameters are interpolated with **sandboxed ECMAScript inside `$(...)`** -- NOT Cheetah `$x` and
  NOT `#for#` loops. A data file's path is `$(inputs.name.path)`; a scalar value is
  `$(inputs.name)`.
- The sandbox has **no database, filesystem, or network access**. Every UDT **must run in a
  container** (`container:` is a required plain string).
- Every output must **claim a file** it produced via `from_work_dir` (one file) or
  `discover_datasets` (many) -- you do not write to a templated output path.

If you find yourself writing `command:`, `$param`, `#for#`, `truevalue:`, or `${on_string}`, stop
-- those are XML/Cheetah habits the schema rejects. See `references/common-mistakes.md`.

## Quick Reference -- minimal valid skeleton

```yaml
class: GalaxyUserTool          # required, exactly this
id: my-tool                    # lowercase, ^[a-z][a-z0-9_-]*$, 3-255 chars (recommended)
version: "0.1.0"               # recommended
name: My Tool                  # required, min 5 chars
description: One line shown in the tool menu
container: quay.io/biocontainers/seqkit:2.8.2--h9ee0642_0   # required STRING, a real image
shell_command: |
  seqkit stats --tabular '$(inputs.input.path)' > stats.tsv
inputs:
  - name: input
    type: data
    format: fastq
    label: Input sequences
outputs:
  - name: report
    type: data
    format: tabular
    from_work_dir: stats.tsv        # claim the file the command wrote
    label: Sequence statistics
```

Full field list, input/output types, and validator rules: **`references/schema-reference.md`**.
Templating syntax (`$(inputs.x)`, arrays, `$GALAXY_SLOTS`, escaping): **`references/templating.md`**.

## Authoring Workflow

1. **Understand the command.** What binary runs, what inputs it consumes, what files it produces.
2. **Pick a real container** -- this is the #1 cause of runtime failure. Prefer a verified
   biocontainer (`quay.io/biocontainers/<tool>:<tag>`), but **never guess the `--<hash>_<build>`
   tag suffix** -- it is not predictable. Look up the real tag, or, when the tool needs only the
   Python standard library, use an official `python:3.x-slim` image and write the logic inline.
   **Do not invent an image or flag you cannot verify** -- ask instead. See "Choosing a container"
   below. Lint will *not* catch a bad image; the job simply fails to pull it.
3. **Draft the definition** using `references/schema-reference.md`. Reference each input as
   `$(inputs.name.path)` (data) or `$(inputs.name)` (scalar). Write outputs to fixed filenames and
   claim them with `from_work_dir` / `discover_datasets`.
4. **Self-review** against `references/common-mistakes.md` (it doubles as a checklist).
5. **Validate** (see below) and iterate on real errors.
6. **Create + run.** Hand the validated definition to `create_user_tool`, then `run_user_tool`
   (this skill stops at a valid definition -- the run/invocation loop is the caller's job).

## Choosing a Container

The container is the part most likely to pass validation but fail at run time, because nothing in
the schema or lint checks that the image actually exists or pulls. A real example: a plotting UDT
that declared `quay.io/biocontainers/seaborn:0.13.2--pyhd8ed1ab_3` was accepted by
`create_user_tool`, then the job died with `manifest unknown` -- that exact build tag did not exist
on quay. Guard against it:

- **Don't guess the biocontainers build suffix** (`--<hash>_<build>`). It is not derivable from the
  version. Look up the real tag: browse `https://quay.io/repository/biocontainers/<tool>?tab=tags`
  or query `https://quay.io/api/v1/repository/biocontainers/<tool>/tag/?onlyActiveTags=true`.
- **For a stdlib-only tool, skip biocontainers entirely.** Use an official base image like
  `python:3.11-slim` (or `busybox` for shell-only) and write the logic inline (see the heredoc
  pattern in `references/templating.md`). The seaborn failure above was fixed exactly this way:
  switch to `python:3.11-slim` and emit SVG with the standard library, no third-party image to get
  wrong.
- **Never invent an image, tag, or CLI flag you can't verify** -- ask the user rather than guessing.

## Validating a Definition

Validation logic is pure Python in `galaxy-tool-util` -- the same code the server runs -- so you can
check offline before submitting. Three tiers, weakest to strongest:

1. **Local** (fast, offline, side-effect-free): `python scripts/validate.py my-tool.yml`. Needs
   `pip install galaxy-tool-util`. Catches structural errors, the four semantic validators, and
   lint warnings. Use this whenever a Python env is available (terminal, CI). See `scripts/`.
2. **`planemo lint`** -- not available yet (planemo does not lint UDTs as of this writing); will be
   the preferred ergonomic check once it lands.
3. **Server create** -- `create_user_tool` / `POST /api/unprivileged_tools` runs the same lint and
   confirms *this server* accepts it (needs `enable_beta_tool_formats` + the Custom Tool Execution
   role). This is the final word, and the practical gate for environments without Python (e.g.
   Loom): submit, then iterate on the returned errors.

> **Lint-clean is necessary but not sufficient.** No check here -- not validate.py, not the server's
> create lint -- verifies that the container image actually pulls or that the command succeeds.
> Those only surface when the job runs. A nonexistent container tag (`manifest unknown` at run
> time) is the most common real-world UDT failure, so verify the image (see "Choosing a Container")
> before relying on a clean validation.

## Common Patterns

| Goal | shell_command snippet |
|------|-----------------------|
| Single data file path | `tool '$(inputs.reads.path)'` |
| Scalar value | `tool --count $(inputs.count)` |
| Multiple data files | `cat $(inputs.datasets.map(d => d.path).join(' ')) > out.txt` |
| Boolean as a flag | `tool $(inputs.verbose ? '--verbose' : '')` |
| Use the job's allocated cores | `tool --threads $GALAXY_SLOTS` (+ a `resource` requirement, `cores_min`) |
| Capture one output file | declare output with `from_work_dir: out.txt` |
| Capture many outputs | declare output `type: collection` with `discover_datasets` |
| Run a non-trivial inline script | `python <<'PY'` ... `PY` heredoc; reference inputs as `$(inputs.x)` inside (see `references/templating.md`) |

See `examples/` for seven complete, validated UDTs spanning these patterns.

## Troubleshooting

| Symptom / error code | Cause | Fix |
|----------------------|-------|-----|
| `dynamic_tool.output_unclaimed` | Output has no `from_work_dir`/`discover_datasets` | Write to a fixed filename and claim it |
| `dynamic_tool.undeclared_input_ref` | `$(inputs.X)` with no input named `X` | Declare the input or fix the name |
| `dynamic_tool.blank_container` | `container` empty / missing | Set a real container image string |
| `string_pattern_mismatch` on `id` | Uppercase, leading digit, spaces | Use `^[a-z][a-z0-9_-]*$` |
| extra-field rejection | XML-ism like `truevalue`, `command`, `${on_string}` | Remove it -- schema is `extra="forbid"` |
| `manifest unknown` / `Unable to find image` at **run** time | Container tag doesn't exist on the registry | Use a real, verified tag (or `python:3.x-slim` for stdlib tools) -- lint can't catch this |

Full list with the why behind each: `references/common-mistakes.md`.

## Resources

- `references/schema-reference.md` -- every `UserToolSource` field, input/output types, validators
- `references/templating.md` -- the `$(...)` ECMAScript model, arrays, `$GALAXY_SLOTS`, escaping
- `references/common-mistakes.md` -- pre-submit self-review checklist
- `scripts/validate.py` -- offline validate + lint via `galaxy-tool-util`
- `examples/` -- seven complete UDTs, simple to complex (incl. an inline-script `python:slim` tool)
- Galaxy docs: [User-Defined Tools](https://docs.galaxyproject.org/en/master/admin/user_defined_tools.html)
- For classic XML tools instead: the `tool-dev` skill.
