# Common Mistakes & Pre-Submit Checklist

UDTs are modeled after XML tools, so the most common failures are XML/Cheetah habits leaking in,
plus a few schema-specific traps. Run through this before submitting.

## Checklist

- [ ] Command is under **`shell_command`**, not `command`.
- [ ] Parameters use **`$(inputs.x)`** / **`$(inputs.x.path)`**, not Cheetah `$x` or `#for#`.
- [ ] `container` is a **plain string** of a **real** image (verified biocontainer when possible).
- [ ] Every output has **`from_work_dir`** or **`discover_datasets`** (collections: `discover_datasets`).
- [ ] Every `$(inputs.X)` reference has a matching declared input named `X`.
- [ ] `id` matches `^[a-z][a-z0-9_-]*$`; `name` is at least 5 characters.
- [ ] No rejected fields: `truevalue`, `falsevalue`, `argument`, `parameter_type`, `${on_string}`, `${tool.name}`.
- [ ] Booleans become flags via a ternary, not `truevalue`/`falsevalue`.
- [ ] Threads/cores use `$GALAXY_SLOTS` (+ a `resource` requirement) unless manual control is wanted.
- [ ] Optional parameters have sensible `value` defaults.
- [ ] Labels and description say what the tool actually does (not "Run the tool").

## Mistakes table

| Mistake | Why it's wrong | Fix |
|---------|----------------|-----|
| `command: ...` | The field is `shell_command`; `command` is rejected (`extra="forbid"`). | Rename to `shell_command`. |
| `$threads`, `#for f in $files#` | Cheetah templating. UDTs use sandboxed ECMAScript. | `$(inputs.threads)`, `$(inputs.files.map(f => f.path).join(' '))`. |
| `'$(inputs.reads)'` for a data input | A data input is an object, not a path. | `'$(inputs.reads.path)'`. |
| `container: {type: docker, image: ...}` | `container` is a plain string. | `container: quay.io/biocontainers/...`. |
| Output written to `'$(inputs.out)'` / a templated output path | UDTs don't pass output paths in; the file is claimed afterward. | Write to a fixed filename, then `from_work_dir: that-file`. |
| Output with neither `from_work_dir` nor `discover_datasets` | `dynamic_tool.output_unclaimed`. | Add one of them. |
| `$(inputs.foo)` but no input `foo` | `dynamic_tool.undeclared_input_ref`. | Declare `foo` or fix the typo. |
| `truevalue: --x` / `falsevalue: ""` on a boolean | XML-only fields, rejected. | `value: false` + `$(inputs.x ? '--x' : '')` in the command. |
| `${on_string}`, `${tool.name}` in labels | Cheetah macros; not supported. | Use a plain string label, or `format_source` to inherit. |
| `id: My_Tool` / `id: 2pass` | Must be lowercase and start with a letter (`string_pattern_mismatch`). | `id: my-tool`, `id: two-pass`. |
| Hardcoded `--threads 8` | Ignores the job's real allocation. | `--threads $GALAXY_SLOTS` + `resource` `cores_min`. |
| `container: ubuntu:latest` for a bioinformatics tool | Generic image won't have the binary; not reproducible. | Use the tool's biocontainer. |
| Invented image/tag/flags | A guessed container or CLI flag fails at runtime. | Use only images/flags you can verify; otherwise ask. |
| Unescaped literal `$(date)` in the command | Galaxy treats `$(...)` as an expression and errors/misfires. | Escape it: `\$(date)`. |

## Verifying a container (the #1 runtime failure)

A wrong container is the most common way a UDT passes validation and then fails at run time --
schema/lint never check that the image exists. Real case: a plotting UDT declared
`quay.io/biocontainers/seaborn:0.13.2--pyhd8ed1ab_3`, was accepted by `create_user_tool`, and the
job died with `manifest unknown` because that exact build tag didn't exist on quay.

- **Never guess the biocontainers build suffix** (`--<hash>_<build>`) -- it isn't derivable from the
  version number. Look it up: browse `https://quay.io/repository/biocontainers/<tool>?tab=tags` or
  query `https://quay.io/api/v1/repository/biocontainers/<tool>/tag/?onlyActiveTags=true`.
- **Stdlib-only tool? Skip biocontainers.** Use `python:3.x-slim` (or `busybox` for shell-only) and
  write the logic inline -- there's no third-party tag to get wrong. The seaborn failure above was
  fixed precisely this way: switch to `python:3.11-slim` and emit SVG with the standard library.
- **A clean `validate.py` does not mean the image pulls.** Lint validates the YAML, not the
  registry. Verify the image separately, or let the server-create + first run confirm it.

## Clarity pass (what a deterministic validator can't catch)

The schema accepts plenty of unhelpful-but-valid tools. Before finishing, also check:

- `description` states what the tool does, specifically.
- Non-obvious inputs have `help` text; `label`s aren't just the parameter name repeated.
- Common, useful options for the wrapped tool are exposed (e.g. a threads input for an aligner).
- Defaults are sensible so a user can run it without filling in everything.
