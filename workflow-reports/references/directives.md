# Galaxy Markdown Directive Reference

All directives must use **block syntax**. One directive per fenced block.

````
```galaxy
directive_name(arg=value)
```
````

The `${galaxy ...}` inline syntax does **not** work in workflow report templates.

---

## Dataset directives

Reference history items by workflow label (`input=`, `output=`) in templates, or by encoded ID (`history_dataset_id=`) in notebook/direct contexts.

| Directive | Renders | When to use |
|-----------|---------|-------------|
| `history_dataset_display` | Interactive dataset card | Default fallback for any dataset |
| `history_dataset_as_image` | Embedded image | Plots, images, visual outputs — also works for collections |
| `history_dataset_as_table` | Formatted table | Tabular results; supports `compact`, `title`, `footer`, `show_column_headers` |
| `history_dataset_embedded` | Raw content | Small text or HTML outputs |
| `history_dataset_link` | Download link | Inline download with custom `label` |
| `history_dataset_peek` | First rows preview | Data snippets |
| `history_dataset_info` | Dataset metadata | Tool output metadata |
| `history_dataset_name` | Dataset name text | References in prose |
| `history_dataset_type` | Datatype string | References in prose |
| `history_dataset_index` | Composite file listing | Multi-file composite datasets |
| `history_dataset_collection_display` | Collection browser | Paired/list collections |

### Parameters

```
history_dataset_as_table(
  output=           # workflow output label (in templates)
  input=            # workflow input label (in templates)
  history_dataset_id=   # encoded ID (in notebooks)
  title=            # table title
  footer=           # table footer
  compact=          # true/false — compact row height
  show_column_headers=  # true/false
  collapse=         # collapsible section label
)

history_dataset_as_image(
  output=
  input=
  history_dataset_id=
  collapse=
)

history_dataset_link(
  output=
  input=
  history_dataset_id=
  label=            # link text
)
```

---

## Invocation directives

| Directive | Renders | When to use |
|-----------|---------|-------------|
| `invocation_inputs()` | All workflow inputs | Summary of submitted inputs |
| `invocation_outputs()` | All workflow outputs | Summary of all outputs |
| `invocation_time()` | Run timestamp | Always include at top of report |
| `history_link()` | History import link | Always include in Reproducibility section |

---

## Job directives

Use `step="<step label>"` in workflow templates. Step label must match exactly.

| Directive | Renders | When to use |
|-----------|---------|-------------|
| `job_parameters(step=, collapse=)` | Tool parameters table | Key analytical steps |
| `job_metrics(step=, collapse=)` | Runtime metrics | Performance documentation |
| `tool_stdout(step=)` | Tool standard output | Capturing logs |
| `tool_stderr(step=)` | Tool standard error | Capturing warnings |

---

## Workflow directives

| Directive | Renders | When to use |
|-----------|---------|-------------|
| `workflow_image()` | SVG workflow diagram | Always include in Summary section |
| `workflow_display(collapse=)` | Step-by-step breakdown | Optional, usually collapsible |
| `workflow_license()` | License info | Attribution / reproducibility |

---

## Utility directives

| Directive | Renders |
|-----------|---------|
| `generate_time()` | Current timestamp |
| `generate_galaxy_version()` | Galaxy version string |
| `instance_access_link()` | Link to Galaxy instance |
| `instance_citation_link()` | Citation info |
| `instance_help_link()` | Help link |

---

## Universal argument

`collapse="<link text>"` — wraps any block directive in a collapsible section.

````
```galaxy
job_parameters(step="Alignment", collapse="Show alignment parameters")
```
````
