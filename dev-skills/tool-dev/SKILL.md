---
name: tool-dev
description: Galaxy tool development reference — creating new tools, testing, IUC review preparation, and updating existing tools. Use when authoring or modifying Galaxy tool wrappers for tools-iuc.
---

# Galaxy Tool Development Reference

Reference for authoring Galaxy tool wrappers that pass tools-iuc review. Derived from real IUC review feedback (25 inline comments, 3 reviewers) on a 5-tool submission.

## When to Use This Skill

- Creating a new Galaxy tool wrapper from scratch
- Wrapping a CLI bioinformatics tool or an external API
- Wrapping R or Python packages/libraries
- Modifying an existing tool for IUC submission
- Updating an existing tool to a new upstream version
- Debugging planemo lint or test failures
- Preparing a tools-iuc PR
- Reviewing Galaxy XML conventions

## Tool Wrapper Patterns by Type

Galaxy tool wrappers fall into three main categories, each with distinct patterns:

### 1. Command-Line Tools (CLI)

**Examples:** chewBBACA, samtools, bedtools, BLAST
**Pattern:** Direct CLI invocation in `<command>` block

```xml
<command detect_errors="aggressive"><![CDATA[
    mytool subcommand
        --input '$input_file'
        --output '$output_file'
        --threads \${GALAXY_SLOTS:-1}
]]></command>
```

**Key characteristics:**
- No wrapper script needed (tool binary is in PATH via conda/container)
- Parameters map 1:1 to CLI flags
- Use `argument="--flag"` on params
- Simplest pattern to maintain

### 2. R Package Wrappers

**Examples:** spacexr, DESeq2, infercnv
**Pattern:** Generate R script via `<configfiles>`, execute with Rscript

```xml
<command detect_errors="exit_code"><![CDATA[
    Rscript '$rscript'
]]></command>

<configfiles>
    <configfile name="rscript"><![CDATA[
library('mypackage')
data <- read.table('$input_file', sep='\t', header=TRUE)
result <- mypackage_function(data, param=$param_value)
write.table(result, '$output_file', sep='\t')
    ]]></configfile>
</configfiles>
```

**Key characteristics:**
- R packages don't have CLI interfaces
- Generate entire R script dynamically
- Handle R-specific data types (data.frames, matrices, Seurat objects)
- Threading via `Sys.getenv("GALAXY_SLOTS")`

### 3. Python Library Wrappers

**Examples:** squidpy, celltypist, scanpy
**Pattern:** Generate Python script via `<configfiles>`, or use wrapper script for complex logic

```xml
<command detect_errors="exit_code"><![CDATA[
    python '$script_file'
]]></command>

<configfiles>
    <configfile name="script_file"><![CDATA[
import mytool
import pandas as pd

data = mytool.load('$input_file')
result = mytool.process(data, param='$param_value')
result.save('$output_file')
    ]]></configfile>
</configfiles>
```

**Key characteristics:**
- Python libraries often lack CLI (like R packages)
- Choose between configfiles (simple) or separate .py script (complex)
- Logging to stderr, not stdout
- Use sys.stderr for print statements during processing

**When to use separate .py wrapper script:**
- Per-item error handling with partial results
- Complex multi-step orchestration
- File format conversions
- API tools (with fixture bypass for testing)

See Section 6 (configfiles) and Section 7 (wrapper scripts) for detailed implementation.

## Key References

- [IUC Best Practices](https://galaxy-iuc-standards.readthedocs.io/en/latest/best_practices.html) — the canonical standards document
- [Galaxy Tool XSD Schema](https://github.com/galaxyproject/galaxy/blob/dev/lib/galaxy/tool_util/xsd/galaxy.xsd) — validate XML against this
- [Galaxy Core Test Tools](https://github.com/galaxyproject/galaxy/tree/dev/test/functional/tools) — reference implementations and edge cases
- [Planemo Documentation](https://planemo.readthedocs.io/) — lint, test, serve, shed workflows
- `references/testing.md` — standalone planemo testing reference (also used by other skills)
- `references/tool-placement.md` — where to create tools decision guide
- `tool-selection-diagram/SKILL.md` — generate tool selection flowchart diagrams for multi-tool suites

---

## 1. Directory Structure

All tools in a suite live in **one flat directory** under `tools/<tool_name>/`. No subdirectories for individual tools.

```
tools/mytool/
├── macros.xml                    # Shared tokens, macros, citations
├── mytool_align.xml              # Tool wrapper A
├── mytool_filter.xml             # Tool wrapper B
├── .shed.yml                     # Tool Shed metadata
├── static/
│   └── images/
│       └── mytool_tool_selection.png   # Optional: tool selection diagram
└── test-data/
    ├── input.fastq.gz            # Shared test inputs
    ├── reference.fasta
    ├── expected_align.bam         # Golden file outputs
    └── expected_filter.bed
```

Add `.py` wrapper scripts only when the upstream CLI can't produce the output Galaxy needs (format conversion, multi-step pipelines, etc.) — most tools don't need them.

**Key rules:**
- Tool IDs use underscores: `mytool_align`, not hyphens
- Test data goes in a single shared `test-data/` directory
- One `macros.xml` per tool suite, not per tool
- One `.shed.yml` per suite

---

## 2. XML Wrapper Structure

### Element Order (Strict)

Galaxy XML elements must appear in this order. `planemo lint` enforces this.

```xml
<tool id="..." name="..." version="..." profile="...">
    <description>...</description>
    <macros>
        <import>macros.xml</import>
    </macros>
    <expand macro="requirements"/>

    <version_command>echo @TOOL_VERSION@</version_command>

    <command detect_errors="aggressive"><![CDATA[
        ...
    ]]></command>

    <inputs>
        ...
    </inputs>

    <outputs>
        ...
    </outputs>

    <tests>
        ...
    </tests>

    <help format="markdown"><![CDATA[
        ...
    ]]></help>

    <expand macro="citations"/>
</tool>
```

### Tool Element Attributes

```xml
<tool id="mytool_function"
      name="MyTool Function"
      version="@TOOL_VERSION@+galaxy@VERSION_SUFFIX@"
      profile="@PROFILE@">
```

- `id`: lowercase, `[a-z0-9_-]` only. Should be meaningful in a larger context — prefix with suite name for multi-tool suites (e.g., `bedtools_intersect`).
- `name`: Human-readable, title case. How users and admins find the tool — be specific, not generic.
- `version`: Always use `@TOOL_VERSION@+galaxy@VERSION_SUFFIX@` from macros
- `profile`: Use `@PROFILE@` token — must be recent (not older than ~1 year). Currently `25.0` for new tools.

### bio.tools Cross-References

Link to the upstream tool's bio.tools entry with `<xrefs>`. Create the bio.tools entry if none exists (needs at least one EDAM Topic and Operation). Pick specific EDAM terms, not root terms like "Topic" or "Operation".

```xml
<xrefs>
    <xref type="bio.tools">mytool</xref>
</xrefs>
```

### Command Block

Use `detect_errors="aggressive"` for CLI tools (catches non-zero exit codes and "error:"/"exception:" on stderr) and CDATA wrapping. Chain multiple commands with `&&` for proper error propagation. Most tools call the upstream binary directly:

```xml
<command detect_errors="aggressive"><![CDATA[
    mytool align
        --input '$input_fastq'
        --reference '$reference'
        --output '$output_bam'
        --threads \${GALAXY_SLOTS:-1}
        #if str($min_quality):
            --min-quality $min_quality
        #end if
        @CMD_OPTIONAL_FLAG@
]]></command>
```

**Script-based wrappers (Python/R via configfiles):** prefer `detect_errors="exit_code"`. `aggressive` fails the job on any stderr line matching "error:"/"exception:"/"traceback", and Python libraries routinely write benign warnings to stderr (docrep `SyntaxWarning`s, tqdm progress bars, deprecation notices). If a job legitimately fails it will exit non-zero anyway, so `exit_code` is sufficient and avoids false failures:

```xml
<command detect_errors="exit_code"><![CDATA[
    python '$__tool_directory__/script.py' --input '$input' --output '$output'
]]></command>
```

For multi-step commands, chain with `&&`:

```xml
<command detect_errors="aggressive"><![CDATA[
    ln -s '$input_fasta' input.fa &&
    mytool index input.fa &&
    mytool align input.fa --output '$output_bam'
]]></command>
```

### File Staging and Directory Setup

Many tools require specific directory structures or file naming. Use `mkdir` and `ln -s` to stage inputs:

```xml
<command detect_errors="aggressive"><![CDATA[
    mkdir -p 'input' 'output' &&
    ln -s '$input_data' 'input/data.csv' &&
    ln -s '$metadata' 'input/metadata.tsv' &&
    mytool process --input-dir 'input' --output-dir 'output'
]]></command>
```

**Pattern for multiple input files:**

```xml
<command detect_errors="aggressive"><![CDATA[
    #import re
    mkdir 'input' &&
    #for $file in $input_files:
        #set escaped_id = re.sub('[^\w\-]', '_', str($file.element_identifier))
        ln -s '$file' 'input/${escaped_id}.${file.ext}' &&
    #end for
    mytool process --input-dir 'input' --output '$output_file'
]]></command>
```

### Handling Compressed Archives (zip, tar.gz)

For tools that work with archived inputs:

```xml
<command detect_errors="aggressive"><![CDATA[
    mkdir -p 'input' &&
    unzip -q '$input_archive' -d 'input' &&

    ## Rename directory if needed
    dir_name=\$(ls -d input/*/ | head -1 | xargs basename) &&
    if [ -n "\$dir_name" ] && [ "\$dir_name" != "expected_name" ]; then
        mv "input/\$dir_name" input/expected_name
    fi &&

    mytool process input/expected_name --output '$output'
]]></command>
```

**For tar.gz:**

```bash
tar -xzf '$input_archive' -C 'input' &&
```

**Creating zip outputs:**

```bash
cd output && zip -r ../result.zip data_dir/ && cd ..
```

### Environment Variables

Common environment variables available in Galaxy:

| Variable | Meaning | Example Usage |
|----------|---------|---------------|
| `\${GALAXY_SLOTS:-1}` | CPU cores allocated | `--threads \${GALAXY_SLOTS:-1}` |
| `\${GALAXY_MEMORY_MB:-4096}` | Total memory (MB) | `--memory \${GALAXY_MEMORY_MB}` |
| `\${GALAXY_MEMORY_MB_PER_SLOT:-4096}` | Memory per core | Memory-per-thread calculations |
| `$__tool_directory__` | Tool installation dir | `python '$__tool_directory__/script.py'` |
| `${on_string}` | Dataset display string | Output labels |

**Setting environment variables for tools:**

```xml
<command detect_errors="aggressive"><![CDATA[
    export NUMBA_NUM_THREADS="\${GALAXY_SLOTS:-4}" &&
    export OMP_NUM_THREADS="\${GALAXY_SLOTS:-1}" &&
    mytool process '$input' '$output'
]]></command>
```

**Tool-specific environment:**

```xml
<environment_variables>
    <environment_variable name="TOOL_CONFIG">$__tool_directory__/config.yaml</environment_variable>
    <environment_variable name="TEMP_DIR">\$_GALAXY_JOB_TMP_DIR</environment_variable>
</environment_variables>
```

When the CLI can't produce the output Galaxy needs (format conversion, multi-step pipelines), use a Python wrapper script:

```xml
<command detect_errors="aggressive"><![CDATA[
    python '$__tool_directory__/mytool_convert.py'
        --input '$input_file'
        --output '$output_file'
]]></command>
```

**Parameter parity rule:** Every param in `<inputs>` must appear in `<command>`, and every flag in `<command>` must trace back to an `<inputs>` param or a macro token. Orphaned params are a lint warning and a review flag.

**Index generation:** When a tool needs to index input files, create symlinks to the inputs in the working directory — don't try to write indices next to the (read-only) input files.

### Output Paths and `from_work_dir`

When a CLI tool writes to a fixed filename or prefix, use a staging directory so Galaxy can find the output predictably:

```xml
<command detect_errors="aggressive"><![CDATA[
    mkdir -p staging &&
    mytool --output-prefix staging/result '$input_file' &&
    mv staging/result.tsv '$output_file'
]]></command>
```

Or use `from_work_dir` on the output:

```xml
<outputs>
    <data name="output_file" format="tabular" from_work_dir="result.tsv"
          label="${tool.name} on ${on_string}"/>
</outputs>
```

### Conditional Outputs (Filters)

Use `<filter>` to create outputs only when certain params are set:

```xml
<outputs>
    <data name="output_log" format="txt" label="${tool.name} log">
        <filter>output_log == True</filter>
    </data>
</outputs>
```

Set `expect_num_outputs` to the number of outputs actually produced by each test case. Outputs whose `<filter>` evaluates to False are not produced and should not be counted.

### Dynamic Output Discovery

For tools producing variable numbers of output files, use `discover_datasets`:

```xml
<collection name="split_output" type="list" label="Split files">
    <discover_datasets pattern="__name_and_ext__" directory="output_dir"/>
</collection>
```

**Multiple collections from the same directory:**

```xml
<collection name="results_tsv" type="list" label="${tool.name} on ${on_string}: TSV Results">
    <discover_datasets pattern="(?P<name>.+)\.tsv$" format="tabular" directory="output"/>
</collection>

<collection name="results_logs" type="list" label="${tool.name} on ${on_string}: Logs">
    <discover_datasets pattern="(?P<name>.+)\.txt$" format="txt" directory="output"/>
</collection>
```

The regex pattern captures the filename (without extension) as the element name. Use `<name>` capturing group to define how elements are named in the collection.

**Always anchor patterns with `$`.** An unanchored pattern can match part of a compound filename and produce mis-split collection elements — e.g. with files named `sccellfie_output_X_reactions.h5ad`, the pattern `(?P<name>.+)_reactions` (no `$`) also matches intermediate names. Anchor on the extension:

```xml
<!-- GOOD: anchored — captures only the full name before the extension -->
<discover_datasets pattern="(?P<designation>.+)\.h5ad$" format="h5ad" directory="output"/>

<!-- BAD: unanchored — can match prefixes of longer filenames -->
<discover_datasets pattern="(?P<name>.+)\.tsv" format="tabular" directory="output"/>
```

**Testing collection outputs:**

```xml
<test expect_num_outputs="2">  <!-- Two collections -->
    <param name="input_file" value="test_input.fasta"/>
    <output_collection name="results_tsv" type="list" count="3">  <!-- 3 files expected -->
        <element name="summary" file="expected_summary.tsv" ftype="tabular"/>
        <element name="details" file="expected_details.tsv" ftype="tabular"/>
    </output_collection>
</test>
```

### Help Section

Use `format="markdown"` for new tools (preferred over RST). Structure with bold `**headers**`, horizontal rules `-----` between sections, double backticks for code references, and end with a citation block. Keep it concise and actionable.

---

## 3. macros.xml Patterns

### Tokens vs XML Macros

This is the single most common IUC review comment. Get it right from the start.

**`<token>`** — For simple text substitution and Cheetah snippets. Expanded inline with `@NAME@` syntax. Use for version strings, Cheetah command fragments.

**`<xml>`** — For structured XML element trees. Expanded with `<expand macro="name"/>`. Use for parameters, requirements, citations.

**The rule:** If it contains Cheetah template logic (`#if`, `#for`), it MUST be a `<token>`, never an `<xml>`. Cheetah inside `<xml>` macros does not work correctly.

```xml
<macros>
    <!-- TOKENS: version strings and Cheetah snippets -->
    <token name="@TOOL_VERSION@">1.2.3</token>
    <token name="@VERSION_SUFFIX@">0</token>
    <token name="@PROFILE@">25.0</token>

    <!-- GOOD: Cheetah snippet as token -->
    <token name="@CMD_OPTIONAL_FLAG@"><![CDATA[
        #if str($optional_param).strip()
            --optional-flag '$optional_param'
        #end if
    ]]></token>

    <!-- BAD: Cheetah in xml macro — WILL NOT WORK -->
    <xml name="cmd_optional_flag">
        #if str($optional_param).strip()
            --optional-flag '$optional_param'
        #end if
    </xml>

    <!-- XML MACROS: structured element trees -->
    <xml name="requirements">
        <requirements>
            <requirement type="package" version="@TOOL_VERSION@">mytool</requirement>
            <yield/>  <!-- tools can inject additional requirements -->
        </requirements>
    </xml>

    <xml name="organism_param">
        <param name="organism" type="select" label="Organism">
            <option value="human" selected="true">Human (hg38)</option>
            <option value="mouse">Mouse (mm10)</option>
        </param>
    </xml>

    <xml name="citations">
        <citations>
            <citation type="doi">10.1234/example</citation>
        </citations>
    </xml>
</macros>
```

### Named Yields and Token Parameterization

For complex macros, use **named yields** to inject content into specific slots:

```xml
<!-- In macros.xml -->
<xml name="complex_inputs">
    <param name="shared_param" type="text" label="Common input"/>
    <yield name="extra_params"/>
    <param name="shared_flag" type="boolean" label="Common flag"/>
</xml>

<!-- In tool XML — content goes into the named yield slot -->
<expand macro="complex_inputs">
    <yield name="extra_params">
        <param name="special_option" type="select" label="Tool-specific"/>
    </yield>
</expand>
```

Use **token parameterization** on xml macros to pass values into the macro at expansion time. Token parameters are replaced with the value passed at expansion — use them for attribute values like labels, defaults, and formats:

```xml
<!-- In macros.xml -->
<xml name="score_param" tokens="default_score,score_help">
    <param argument="--min-score" type="float" value="@DEFAULT_SCORE@" min="0.0" max="1.0"
           label="Minimum score" help="@SCORE_HELP@"/>
</xml>

<!-- In tool XML — each tool can set its own default and help text -->
<expand macro="score_param" default_score="0.5" score_help="Filter results below this threshold"/>
```

### Common Parameter Macros

Create reusable parameter macros for frequently used inputs:

```xml
<!-- Shared input pattern -->
<xml name="common_input">
    <param name="input_images" type="data" format="tiff" multiple="true" label="Input images"/>
    <param name="metadata_file" type="data" format="csv" label="Metadata file"/>
</xml>

<!-- Radius parameter (common in spatial tools) -->
<xml name="radius_param">
    <param argument="--radius" type="integer" min="0" value="50"
           label="Radius" help="Distance considered for neighborhood interactions"/>
</xml>

<!-- Key column selector (common in single-cell tools) -->
<xml name="param_cluster_key" token_optional="false">
    <param argument="--cluster_key" type="text" optional="@OPTIONAL@"
           label="Cluster key" help="Column in obs containing cluster labels">
        <expand macro="sanitize_query"/>
    </param>
</xml>
```

**Select options with yields** — define base options, let tools add more:

```xml
<xml name="channel_options_basic">
    <yield/>
    <option value="Cellbound1">Cellbound1</option>
    <option value="Cellbound2">Cellbound2</option>
    <option value="Cellbound3">Cellbound3</option>
</xml>

<xml name="channel_options_extended">
    <expand macro="channel_options_basic">
        <option value="None" selected="true">None</option>
        <option value="DAPI">DAPI</option>
        <option value="PolyT">PolyT</option>
    </expand>
</xml>
```

Then use in params:

```xml
<param name="red_channel" type="select" label="Red channel stain">
    <expand macro="channel_options_extended"/>
</param>
```

### Docker Containers in Requirements

For tools with complex dependency stacks or when reproducibility requires a specific container, use `<container>` instead of individual conda packages:

```xml
<xml name="requirements">
    <requirements>
        <container type="docker">quay.io/biocontainers/squidpy:v1.8.1-1</container>
    </requirements>
</xml>
```

**When to use containers:**
- Complex Python environments with conflicting dependencies
- Tools requiring specific system libraries
- When the upstream project provides official containers
- Multi-language stacks (e.g., Python + R + CLI tools)

**When to use conda packages:**
- Simple single-package tools
- When package is well-maintained in bioconda/conda-forge
- When you want Galaxy admins to have more control over dependencies

You can also mix both approaches with `<yield/>` to let individual tools add extra requirements to a container base:

```xml
<xml name="requirements">
    <requirements>
        <container type="docker">quay.io/galaxy/vpt:1.3.0-3-py312</container>
        <yield/>
    </requirements>
</xml>
```

### Creators and EDAM Metadata Macros

**Creators macro** — Structured authorship information for proper attribution:

```xml
<xml name="creators">
    <creator>
        <person givenName="FirstName" familyName="LastName" email="email@example.com"/>
        <organization name="European Galaxy Team" url="https://usegalaxy-eu.github.io/people"/>
    </creator>
</xml>
```

Expand with `<expand macro="creators"/>` after requirements.

**EDAM ontology macro** — Separate macro for EDAM topics and operations when you have multiple tools sharing the same domain:

```xml
<xml name="edam">
    <edam_topics>
        <edam_topic>topic_3308</edam_topic>  <!-- Transcriptomics -->
    </edam_topics>
    <edam_operations>
        <edam_operation>operation_3223</edam_operation>  <!-- Differential expression -->
    </edam_operations>
</xml>
```

Expand with `<expand macro="edam"/>` after description. Search [EDAM ontology browser](https://edamontology.org/page) for specific topic/operation IDs.

### Sanitizer Macros for Reusable Input Validation

Create reusable sanitizer macros for consistent input validation across parameters:

```xml
<!-- Basic alphanumeric + common chars -->
<xml name="sanitize_query" token_validinitial="string.letters,string.digits">
    <sanitizer>
        <valid initial="@VALIDINITIAL@">
            <add value="_"/>
            <add value="-"/>
            <add value="."/>
        </valid>
    </sanitizer>
</xml>

<!-- Numeric with delimiters -->
<xml name="sanitize_digits">
    <sanitizer invalid_char="">
        <valid initial="string.digits">
            <add value="."/>
            <add value=","/>
            <add value="-"/>
            <yield/>  <!-- Tools can inject additional valid chars -->
        </valid>
    </sanitizer>
</xml>
```

Use in params:

```xml
<param argument="--spatial_key" type="text" value="spatial" label="Spatial coordinates key">
    <expand macro="sanitize_query"/>
</param>

<param name="z_layers" type="text" value="3" label="Z-layer indices (comma-separated)">
    <expand macro="sanitize_digits"/>
</param>
```

### API Tool Macros

The following macros are only needed when wrapping external APIs (not CLI tools).

**Credentials** — Galaxy's vault-backed secrets system. Place `<credentials>` inside `<requirements>` in the macro, not as a separate macro:

```xml
<xml name="requirements">
    <requirements>
        <requirement type="package" version="@TOOL_VERSION@">mytool</requirement>
        <credentials name="mytool" version="1.0" label="MyTool API" description="API key for MyTool service">
            <secret name="api_key" inject_as_env="MYTOOL_API_KEY" label="API Key" description="Your MyTool API key"/>
        </credentials>
    </requirements>
</xml>
```

Tools then just use `<expand macro="requirements"/>` — no yield or separate credentials expand needed.

**Test fixture param** — hidden param for fixture-based CI testing (bypasses API calls):

```xml
<xml name="test_fixture_param">
    <param name="test_fixture" type="hidden" value=""/>
</xml>

<token name="@CMD_TEST_FIXTURE@"><![CDATA[
    #if $test_fixture
        --test-fixture '$__tool_directory__/$test_fixture'
    #end if
]]></token>
```

### Common Setup Tokens

For tools that repeat the same setup commands (directory creation, file staging), use command tokens:

```xml
<token name="@CMD_SETUP@"><![CDATA[
    mkdir -p 'input/region/images' 'output/' &&
    #for $image in $input_images:
        ln -s '$image' 'input/region/images/${image.element_identifier}.tif' &&
    #end for
    ln -s '$micron_to_mosaic' 'input/region/images/micron_to_mosaic_pixel_transform.csv' &&
]]></token>

<token name="@CMD_COMMON_ARGS@"><![CDATA[
    --threads \${GALAXY_SLOTS:-1}
    --log-file 'output/log.txt'
]]></token>
```

In tool command blocks:

```xml
<command detect_errors="aggressive"><![CDATA[
    @CMD_SETUP@
    mytool process
        @CMD_COMMON_ARGS@
        --input 'input/data.csv'
        --output 'output/result.tsv'
]]></command>
```

---

## 4. Cheetah Templating

### Dollar Sign Escaping

This causes more bugs than anything else in Galaxy XML. The rules:

| Context | Syntax | Example |
|---------|--------|---------|
| Galaxy parameter | `'$param'` | `--input '$input_file'` |
| Galaxy parameter (no quotes needed) | `$param` | `--count $max_count` |
| Shell environment variable | `\${VAR}` | `--workers \${GALAXY_SLOTS:-1}` |
| Cheetah loop variable | `'$item'` | `'$item'` inside `#for` |
| Literal dollar in shell | `\$` | `awk '{print \$1}'` |

**Critical:** Galaxy parameters are single-quoted (`'$param'`). Environment variables use backslash-escaped dollar with braces (`\${VAR:-default}`).

### Conditional Parameters

For text params, always use `str()` and `.strip()` — never test the raw param directly:

```
#if str($optional_text).strip()
    --flag '$optional_text'
#end if
```

For select params, use string comparison:

```
#if str($mode) == "advanced"
    --advanced-flag
#end if
```

### Boolean Parameters

Galaxy booleans render as lowercase strings `"true"` or `"false"`. Use string equality, not Pythonic truthiness:

```
## BAD: Pythonic boolean test — unreliable in Cheetah
#if $my_flag
#if $my_flag is True

## GOOD: string comparison
#if str($my_flag) == "true"
    --enable-feature
#end if
```

### Select Params Used as Pseudo-Booleans

When a select param (with values like `True`/`False`) or an `output_selector` gates behavior, remember that **any non-empty string is truthy in Cheetah** — even `"False"`. `#if $param:` is always true for selects. Use string comparison, and match the exact value casing used in `<option value="...">` / `truevalue`:

```cheetah
## BAD: always true — the value is the string "False", which is truthy
#if $reporting.report:
    ...
#end if

## GOOD: string comparison with exact casing
#if str($reporting.report) == 'True':
    ...
#end if
```

This applies in both `<command>` blocks and `<configfiles>`. Note the casing convention: select options typically use capitalized `True`/`False` (matching `truevalue="True"`), while boolean params render lowercase `"true"`/`"false"`.

### Splitting Comma-Separated List Params

Text params holding comma-separated lists (e.g. `HK1,HK2`) are common. Users may leave a **trailing comma**, which produces an empty string in a naive split — filter it:

```cheetah
## BAD: "HK1,HK2," yields ['HK1', 'HK2', '']
#set var_names_list = [str(x.strip()) for x in str($var_names).split(',')]

## GOOD: filter empty entries
#set var_names_list = [str(x.strip()) for x in str($var_names).split(',') if x.strip()]
```

### Numeric Zero Gotcha

Integer and float params: `0` is a valid value but falsy in Cheetah/Python. Use `str()` to avoid skipping zero:

```
## BAD: skips the flag when value is 0
#if $min_score
    --min-score $min_score
#end if

## GOOD: treats 0 as a valid value
#if str($min_score):
    --min-score $min_score
#end if
```

### For Loops (Multi-Select Parameters)

```
--output-types
#for $fmt in $output_types
    '$fmt'
#end for
```

### Element Identifier Sanitization

When creating files from user data, sanitize `element_identifier` to ensure valid filenames:

```
#import re
#for $file in $input_files
    #set escaped_id = re.sub('[^\w\-]', '_', str($file.element_identifier))
    ln -s '$file' 'input/${escaped_id}.${file.ext}' &&
#end for
```

The regex `[^\w\-]` matches anything that isn't alphanumeric, underscore, or hyphen, replacing with underscore. This prevents issues with spaces, special characters, or path separators in identifiers.

**For collection elements:**

```
#for $item in $input_collection
    --name '${re.sub('[^\w\-_]', '_', $item.element_identifier)}'
    --file '$item'
#end for
```

### Conditionals (Tool Sections)

```xml
<conditional name="output_mode">
    <param name="mode" type="select" label="Output mode">
        <option value="summary" selected="true">Summary</option>
        <option value="binned">Binned</option>
    </param>
    <when value="summary"/>
    <when value="binned">
        <param name="bin_size" type="integer" value="128" min="1" max="4096"
               label="Bin size (bp)"/>
    </when>
</conditional>
```

In the command block:

```
--output-mode '$output_mode.mode'
#if str($output_mode.mode) == "binned"
    --bin-size $output_mode.bin_size
#end if
```

---

## 5. Input Parameter Conventions

### The `argument=` Attribute

Prefer `argument="--flag"` over bare `name="flag"`. This auto-generates the `name` attribute (stripping leading dashes, replacing `-` with `_`) and displays the flag in the help text. Always use the long form (`--output` not `-o`).

```xml
<!-- GOOD: argument auto-generates name="min_score" and shows --min-score in help -->
<param argument="--min-score" type="float" value="0.5" min="0.0" max="1.0"
       label="Minimum score" help="Filter results below this threshold"/>

<!-- Also fine when there's no direct CLI flag mapping -->
<param name="organism" type="select" label="Organism">
```

When using `argument=`, the param `name` is derived automatically (e.g., `argument="--min-score"` creates `name="min_score"`). You still need to include the flag in the command block — `argument=` does not inject it for you:

```
--min-score $min_score
```

**IUC standard attribute order:** `name, argument, type, format, min|truevalue, max|falsevalue, value|checked, optional, label, help`.

### Grouping with `<section>`

Group related parameters into logical sections for complex tools:

```xml
<inputs>
    <param argument="--input" type="data" format="vcf" label="Input VCF"/>

    <section name="filtering" title="Filtering options" expanded="false">
        <param argument="--min-score" type="float" value="0.5" .../>
        <param argument="--max-pvalue" type="float" value="0.05" .../>
    </section>

    <section name="output_options" title="Output options" expanded="false">
        <param argument="--format" type="select" .../>
    </section>
</inputs>
```

**Advanced output selection pattern** — Let users choose which optional outputs to generate:

```xml
<section name="output" title="Output Options">
    <param name="output_selector" type="select" multiple="true" optional="true"
           display="checkboxes" label="Additional outputs">
        <option value="rds">RDS file (R object)</option>
        <option value="rscript">Generated R script</option>
        <option value="log">Processing log</option>
        <option value="plots">Diagnostic plots (PDF)</option>
    </param>
</section>
```

Then filter outputs:

```xml
<outputs>
    <data name="result_rds" format="rds" from_work_dir="output.rds"
          label="${tool.name} on ${on_string}: RDS">
        <filter>output['output_selector'] and 'rds' in output['output_selector']</filter>
    </data>
    <data name="log_file" format="txt" from_work_dir="process.log"
          label="${tool.name} on ${on_string}: Log">
        <filter>output['output_selector'] and 'log' in output['output_selector']</filter>
    </data>
</outputs>
```

**Note:** Use nested dictionary access for sections: `output['output_selector']`, not `$output.output_selector`.

### Validation

Use `<validator>` for constraining values. Use `min`/`max` attributes on integer/float params. Never use `optional="true"` when a default is appropriate — just set the default. For parameters like `random_state`/`seed`, prefer an explicit numeric default (e.g. `value="0"`) over `optional="true"` with no default: it makes runs reproducible and avoids downstream `None`-handling in the wrapper.

```xml
<!-- Multi-select: require at least one selection -->
<param name="items" type="select" multiple="true" label="Items">
    <option value="A" selected="true">A</option>
    <option value="B">B</option>
    <validator type="no_options" message="Select at least one item"/>
</param>

<!-- Text with regex validation -->
<param name="terms" type="text" value="" label="Terms (optional)"
    help="Comma-separated terms, e.g. UBERON:0002107">
    <validator type="regex" message="Only alphanumeric, colons, commas, spaces">[A-Za-z0-9:, ]*</validator>
</param>

<!-- Integer with range -->
<param name="max_count" type="integer" value="100" min="1" max="10000"
       label="Maximum items" help="Start small to verify results"/>

<!-- Text param that must not be empty -->
<param name="required_text" type="text" label="Required parameter">
    <validator type="empty_field" message="This field is required"/>
</param>
```

**Common validators:**
- `type="empty_field"` — Field must not be empty
- `type="no_options"` — At least one option must be selected (multi-select)
- `type="regex"` — Must match the pattern
- `type="in_range"` — Numeric value must be in range (use `min`/`max` instead)
- `type="length"` — String length constraints
- `type="dataset_ok_validator"` — Dataset format validation (usually automatic)
- `type="metadata"` — Check metadata presence

### Boolean Parameters

Put the CLI flag in `truevalue`/`falsevalue`. Don't use booleans as conditionals — use `select` instead when other params depend on the choice.

```xml
<!-- GOOD: flag in truevalue -->
<param argument="--gzip" type="boolean" truevalue="--gzip" falsevalue=""
       checked="false" label="Compress output"/>

<!-- BAD: boolean controlling other params — use select + conditional instead -->
<param name="advanced" type="boolean" label="Show advanced options"/>
```

When a select param with `True`/`False` values is tested in Cheetah, string-compare with exact casing (`#if str($param) == 'True':`) — see *Select Params Used as Pseudo-Booleans* in the Cheetah section.

### Compressed Datatype Support

When the underlying tool accepts compressed input natively (or you add decompression in the command section), accept both compressed and uncompressed formats:

```xml
<param name="input" type="data" format="fasta,fasta.gz" label="Input sequences"/>
<param name="reads" type="data" format="fastqsanger,fastqsanger.gz,fastqsanger.bz2" label="Reads"/>
```

If you accept compressed formats, include tests with both compressed and uncompressed inputs to verify both paths work.

### Multiple Inputs vs Repeat Parameters

For multiple files of the same type, use `multiple="true"` on the data param:

```xml
<param name="inputs" type="data" format="bam" multiple="true" label="BAM files"/>
```

Use `<repeat>` for variable-length groups of mixed parameters (e.g., a dataset + options per entry):

```xml
<repeat name="samples" title="Sample">
    <param name="input" type="data" format="bam" label="BAM file"/>
    <param name="label" type="text" label="Sample label"/>
</repeat>
```

In command: `#for $s in $samples# --sample '$s.input' --label '$s.label' #end for#`

### Data Collections

For paired-end data and multi-sample workflows:

```xml
<!-- Accept paired collection -->
<param name="paired_input" type="data_collection" collection_type="paired"
       format="fastqsanger,fastqsanger.gz" label="Paired reads"/>

<!-- Accept multiple datasets (also accepts collections) -->
<param name="inputs" type="data" format="bam" multiple="true" label="BAM files"/>
```

Access paired ends: `$paired_input.forward` / `$paired_input.reverse`

Preserve element identifiers in loops:

```
#for $input in $inputs
--name '${re.sub('[^\w\-_]', '_', $input.element_identifier)}'
#end for
```

### 10x Matrix Format Handling

When accepting 10x-style matrix inputs (common in single-cell tools), provide options for both formats:

```xml
<conditional name="input_mat">
    <param name="format" type="select" label="Input format">
        <option value="h5ad" selected="true">AnnData (h5ad)</option>
        <option value="mtx">10x Matrix (mtx + genes + barcodes)</option>
    </param>
    <when value="h5ad">
        <param name="raw_h5ad" type="data" format="h5ad" label="AnnData file"/>
    </when>
    <when value="mtx">
        <param name="mtx" type="data" format="txt" label="Matrix file (matrix.mtx)"/>
        <param name="mtx_genes" type="data" format="tsv" label="Genes file (genes.tsv)"/>
        <param name="mtx_barcodes" type="data" format="tsv" label="Barcodes file (barcodes.tsv)"/>
    </when>
</conditional>
```

In the command block, stage 10x files with the required names:

```xml
<command detect_errors="exit_code"><![CDATA[
#if str($input_mat.format) == "mtx":
    mkdir matrix_10x &&
    ln -s '$input_mat.mtx' matrix_10x/matrix.mtx &&
    ln -s '$input_mat.mtx_genes' matrix_10x/genes.tsv &&
    ln -s '$input_mat.mtx_barcodes' matrix_10x/barcodes.tsv &&
#end if
]]></command>
```

In configfiles (R example):

```r
#if str($input_mat.format) == "mtx":
library(Seurat)
mtx = Read10X("matrix_10x/")
#else:
mtx = '$input_mat.raw_h5ad'
#end if
```

### Subcommand Strategy

Tools with subcommands (e.g., `samtools view`, `samtools sort`) should be separate tool wrappers when the subcommands need different resource allocations. Use a conditional only when they're closely related and share the same resource profile.

### IUC-Specific Rules

See [IUC Best Practices](https://galaxy-iuc-standards.readthedocs.io/en/latest/best_practices.html) for the canonical standards.

- **No `display="checkboxes"`** on multi-select params. Reviewers will flag it. Let Galaxy decide the widget.
- **Mark defaults with `selected="true"`** on the `<option>` element.
- **Unit notation in labels:** Use SI-style lowercase: "kb" not "KB", "Mb" not "MB". The option values can use uppercase (e.g., `value="1MB"`) but display text should read "1 Mb".
- **Help text:** Keep it actionable and short. "Start small to verify results" is good. When referencing other tools, use their exact **tool id** (e.g. "the scCellFie analysis tool" for `sccellfie_analysis`), not a loose description — users should be able to find the referenced tool in the panel. If help says a tool's output can be used as input, make sure that output actually exists (e.g. a volcano plot mode should emit the same significant-features table as the beeswarm mode, via a shared output `<filter>` like `method['method'] in ['volcano', 'beeswarm']`).
- **No apostrophes in param defaults or labels:** Galaxy sanitizers strip quotes from user values. A default like `Cohen's d` silently becomes `Cohens_d`. Use quote-free defaults (or sanitized names) so the default and user-visible value match.
- **Minimal dependencies:** Only list packages the wrapper actually uses. Reviewers flag unused requirements (plotting libraries only needed for optional features, pins on transitive deps). Pin a transitive dependency only when there is a known version conflict, and add a comment explaining why.
- **Citations:** Prefer `type="doi"` over `type="bibtex"` when a DOI is available. Search the upstream repo/paper for the correct DOI.
- **4-space indentation** throughout XML and Cheetah code. Run `planemo format` before submitting to ensure consistent indentation matching Galaxy Language Server style.
- **Profile version:** Use `@PROFILE@` token. For new tools, use profile `25.0` or newer (not older than ~1 year).
- **Version suffix:** Start at `0` for new tools. Increment when making Galaxy-side changes without upstream version bump.

---

## 6. configfiles: Dynamic R and Python Script Generation

When tools need complex R or Python logic that's too cumbersome for command-line flags, use `<configfiles>` to generate scripts dynamically. This is the standard pattern for R package wrappers and Python tools with conditional logic.

### When to Use configfiles

- **R package wrappers** — R tools typically need a full script, not CLI flags
- **Python tools with complex conditionals** — When tool behavior varies significantly based on parameters
- **Multi-step workflows** — Orchestrating multiple function calls in sequence
- **API tools** — Building request parameters programmatically

### Basic Pattern

```xml
<command detect_errors="exit_code"><![CDATA[
    Rscript '$rscript'
]]></command>

<configfiles>
    <configfile name="rscript"><![CDATA[
# Load library
library('mytool')

# Load input data
data <- read.table('$input_file', header = TRUE, sep = '\t')

#if str($normalize) == "true":
data <- normalize_data(data)
#end if

# Run analysis
result <- mytool_function(
    data = data,
    param1 = $param1,
    #if str($optional_param):
    param2 = '$optional_param',
    #end if
    threads = as.numeric(Sys.getenv("GALAXY_SLOTS", "1"))
)

# Save output
write.table(result, file = '$output_file', sep = '\t', quote = FALSE)
    ]]></configfile>
</configfiles>
```

### R Script Best Practices

**Threading:**
```r
num_threads = as.numeric(Sys.getenv("GALAXY_SLOTS"))
if (is.na(num_threads) || nchar(num_threads) == 0) {
    num_threads = 1
}
```

**Cheetah string escaping in R:**
```r
# String param from Galaxy
file_path = '$input_file'  # Single quotes, Cheetah interpolates

# R string literals
delim = "\t"  # Backslash-escaped tab

# Conditional R strings
#if str($method) == "advanced":
method_name = "$method"  # Cheetah param
#else:
method_name = "basic"  # R literal
#end if
```

**Named lists (R equivalent to dicts):**
```r
#if str($cell_types).strip():
cell_types = c($cell_types)  # Galaxy param expands to "type1", "type2"
#end if
```

### Python Script Pattern

```xml
<command detect_errors="exit_code"><![CDATA[
    python '$script_file'
]]></command>

<configfiles>
    <configfile name="script_file"><![CDATA[
import sys
import logging
import pandas as pd

# Setup logging to stderr
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stderr)]
)

# Load data
data = pd.read_csv('$input_file', sep='\t')
logging.info(f"Loaded {len(data)} rows")

#if str($filter_column).strip():
data = data[data['$filter_column'] > $threshold]
logging.info(f"Filtered to {len(data)} rows")
#end if

# Process
result = process_data(
    data,
    method='$method',
    #if str($optional_param).strip():
    optional='$optional_param',
    #end if
)

# Save
result.to_csv('$output_file', sep='\t', index=False)
logging.info("Processing complete")
    ]]></configfile>
</configfiles>
```

### Advanced: Conditional Script Generation

For tools with distinct operation modes, generate different script sections:

```xml
<configfile name="analysis_script"><![CDATA[
import analysis_tool

data = analysis_tool.load('$input_data')

#if $operation.mode == "spatial_neighbors":
analysis_tool.compute_neighbors(
    data,
    n_neighbors=$operation.n_neighs,
    radius=$operation.radius
)

#elif $operation.mode == "enrichment":
analysis_tool.neighborhood_enrichment(
    data,
    cluster_key='$operation.cluster_key'
)

#elif $operation.mode == "autocorr":
results = analysis_tool.spatial_autocorr(
    data,
    genes=$operation.genes
)
results.to_csv('$output_table', sep='\t')
#end if

data.write('$output_data')
]]></configfile>
```

### Common Patterns

**Directory staging:**
```xml
<command><![CDATA[
    mkdir -p 'inputs' 'results' &&
    ln -s '$input1' 'inputs/data.csv' &&
    Rscript '$rscript'
]]></command>
```

**Debug: Echo script before running (remove in production):**
```xml
<command><![CDATA[
    cat '$script_file' &&
    python '$script_file'
]]></command>
```

**Saving the generated script for user inspection:**
```xml
<outputs>
    <data name="rscript_out" format="txt" from_work_dir="results/script.R" label="Generated R script">
        <filter>'rscript' in output_selector</filter>
    </data>
</outputs>
```

And in the command block:
```xml
touch 'results/script.R' &&
cat '$rscript' > 'results/script.R' &&
Rscript '$rscript'
```

---

## 7. Python Wrapper Scripts (When Needed)

Add a wrapper script only when:

- The CLI output format doesn't match what Galaxy expects (needs conversion)
- You need multi-step pipelines that are too complex for shell in the command block
- The tool wraps an API rather than a CLI binary
- You need per-item error handling with partial results

### When You Do Need a Script

Key rules for Galaxy wrapper scripts:

- **All logging to stderr** — stdout is reserved for Galaxy output capture
- **`__version__`** must match `@TOOL_VERSION@` in macros.xml
- **Per-item error handling** — `try/except` inside the loop, continue on failure, exit 1 only if ALL items failed
- **No user-facing `--verbose`** — control via Galaxy's logging, not user params
- **Declare auxiliary scripts** in the tool XML with [`<required_files>`](https://docs.galaxyproject.org/en/latest/dev/schema.html#tool-required-files-include) so Galaxy includes them at runtime:
  ```xml
  <required_files>
      <include path="mytool_convert.py"/>
  </required_files>
  ```
- **Add a python requirement** when using wrapper scripts:
  ```xml
  <requirement type="package">python</requirement>
  ```
- **Document non-obvious transformations.** If the wrapper mutates user data (e.g. `adata.X = scipy.sparse.csr_matrix(adata.X)` converts a dense matrix to sparse), add a short comment explaining *why* it's needed — ideally referencing the upstream function that requires it (`## compute_local_colocalization_scores calls .toarray(), which requires a sparse matrix`). When possible, convert only when needed (`if not scipy.sparse.issparse(adata.X): ...`) so users get back an object shaped like the one they put in.

```python
#!/usr/bin/env python
"""MyTool converter for Galaxy — transforms native output to tabular."""

import argparse
import logging
import sys

__version__ = "1.2.3"  # Must match @TOOL_VERSION@


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[logging.StreamHandler(sys.stderr)],
    )

    # Process input, write output...
    logging.info("Processed %s -> %s", args.input, args.output)


if __name__ == "__main__":
    main()
```

### API Tool Scripts

For tools wrapping external APIs (not the common case), the script also handles:
- **Fixture bypass** — `--test-fixture` loads JSON instead of calling the API
- **Credentials** — read API key from environment (`os.environ.get("MYTOOL_API_KEY")`)

---

## 8. Tool Data Tables: Reference Data Management

Tool data tables let Galaxy admins provide pre-downloaded reference data (genomes, model files, databases) that tools can access via dropdown menus. Use this for large reference files that shouldn't be uploaded per-analysis.

### When to Use Tool Data Tables

- Pre-trained ML models (e.g., cell type classifiers, protein structure predictors)
- Reference genomes and annotations
- Database files (BLAST databases, kraken indices)
- Any reference data >50 MB that's reused across analyses

### Structure

```
tools/mytool/
├── tool-data/
│   └── mytool_models.loc            # Example data (for testing)
├── tool_data_table_conf.xml.sample   # Table schema
└── mytool.xml
```

### Defining the Table Schema

`tool_data_table_conf.xml.sample`:

```xml
<tables>
    <table name="mytool_models" comment_char="#" allow_duplicate_entries="False">
        <columns>value, name, date, path</columns>
        <file path="tool-data/mytool_models.loc" />
    </table>
</tables>
```

- `name`: Unique table identifier used in tool XML
- `columns`: Column names in the .loc file (first column is the value returned to the tool)
- `comment_char`: Lines starting with this are ignored
- `allow_duplicate_entries`: Whether the same `value` can appear multiple times

### Creating the .loc File

`tool-data/mytool_models.loc`:

```
# value	name	date	path
model_v1	MyTool v1.0 (Human)	2024-01-15	/path/to/models/mytool_v1.0.pkl
model_v2	MyTool v2.0 (Human + Mouse)	2024-06-01	/path/to/models/mytool_v2.0.pkl
```

**Column conventions:**
- `value`: Machine-readable ID (used in tool parameters)
- `name`: Human-readable display name
- `date`: Optional metadata (modification date, version date)
- `path`: Absolute path to the data file

You can define any columns that make sense for your data. Common patterns: `value, name, path` or `value, name, version, path`.

### Using in Tool XML

```xml
<conditional name="model_source">
    <param type="select" name="source" label="Select model from">
        <option value="cached" selected="true">Cached</option>
        <option value="history">History</option>
    </param>
    <when value="cached">
        <param type="select" name="cached_model" label="Choose model">
            <options from_data_table="mytool_models">
                <!-- Optionally customize display -->
                <column name="value" index="0"/>
                <column name="name" index="1"/>
                <filter type="sort_by" column="1"/>
            </options>
        </param>
    </when>
    <when value="history">
        <param type="data" format="binary" name="history_model" label="Select model from history"/>
    </when>
</conditional>
```

### Accessing in configfiles

```xml
<configfile name="script_file"><![CDATA[
import mytool

#if $model_source.source == "cached":
model = mytool.load_model('$model_source.cached_model.fields.path')
#else:
model = mytool.load_model('$model_source.history_model')
#end if

result = mytool.predict(model, '$input_data')
result.save('$output_file')
]]></configfile>
```

Access columns via `.fields.<column_name>`. The most common is `.fields.path`.

### Admin Installation

When the tool is installed, Galaxy copies `tool_data_table_conf.xml.sample` to the config directory and creates an empty `mytool_models.loc` file. Admins then populate it with actual data paths.

**Example admin workflow:**
```bash
# Download models
mkdir -p /data/galaxy/tool-data/mytool/
wget https://example.com/model_v1.pkl -O /data/galaxy/tool-data/mytool/model_v1.pkl

# Add to .loc file
echo -e "model_v1\tMyTool v1.0\t2024-01-15\t/data/galaxy/tool-data/mytool/model_v1.pkl" \
    >> /data/galaxy/tool-data/mytool_models.loc
```

### Testing with Tool Data Tables

Include a minimal example in the repo's `tool-data/` directory. Tests will use this local path:

```xml
<test expect_num_outputs="1">
    <conditional name="model_source">
        <param name="source" value="cached"/>
        <param name="cached_model" value="model_v1"/>
    </conditional>
    <param name="input_data" value="test_input.h5ad"/>
    <output name="output_file" file="expected_output.h5ad" ftype="h5ad"/>
</test>
```

### Testing Mode

Provide `tool_data_table_conf.xml.test` alongside `.sample` for testing. Planemo automatically uses the `.test` version:

```xml
<!-- tool_data_table_conf.xml.test -->
<tables>
    <table name="mytool_models" comment_char="#">
        <columns>value, name, date, path</columns>
        <file path="${__HERE__}/tool-data/mytool_models.loc" />
    </table>
</tables>
```

`${__HERE__}` resolves to the tool directory during testing.

---

## 9. Resource Management

### General Principle

Do not expose `--verbose`, `--memory`, `--threads`, or similar operational flags as user-facing inputs. Set sensible defaults or derive them from Galaxy's system variables in the command block. Users control what to compute, admins control how.

### Parallelism (GALAXY_SLOTS)

Use Galaxy's `GALAXY_SLOTS` environment variable for thread/process count. This is admin-controlled, not user-facing.

Available environment variables:

| Variable | Meaning |
|----------|---------|
| `\${GALAXY_SLOTS:-1}` | Allocated CPU cores |
| `\${GALAXY_MEMORY_MB:-4096}` | Total memory in MB |
| `\${GALAXY_MEMORY_MB_PER_SLOT:-4096}` | Memory per core in MB |

In the command block:

```
--threads \${GALAXY_SLOTS:-1}
```

### Memory

If the upstream CLI has no hard memory limit, surface the parameter that proxies it best (chunk size, hash table size, block size) and set conservative defaults. Don't expose raw memory flags.

```xml
<!-- GOOD: proxy for memory usage, meaningful to the user -->
<param argument="--chunk-size" type="integer" value="10000" min="1000" max="1000000"
       label="Chunk size" help="Larger values use more memory but process faster"/>

<!-- BAD: raw memory flag, meaningless to most users -->
<param argument="--memory" type="integer" value="4" label="Memory (GB)"/>
```

---

## 10. Test Infrastructure

See `references/testing.md` for the full assertion reference, collection testing, compressed output testing, repeat element tests, and failure analysis. Also see the [Galaxy Tool XSD Schema](https://docs.galaxyproject.org/en/latest/dev/schema.html) for the complete assertion specification.

### Test XML Structure

```xml
<tests>
    <test expect_num_outputs="1">
        <param name="input_fastq" value="test_input.fastq.gz"/>
        <param name="min_quality" value="20"/>
        <output name="output_bam" file="expected_output.bam" ftype="bam" compare="sim_size" delta="100"/>
    </test>
    <test expect_num_outputs="1">
        <!-- Second test: different code path -->
        <param name="input_fastq" value="test_input.fastq.gz"/>
        <param name="min_quality" value="0"/>
        <output name="output_bam">
            <assert_contents>
                <has_size min="100"/>
            </assert_contents>
        </output>
    </test>
</tests>
```

### Test Structure Rules

- Give each test a **unique purpose** (e.g., "defaults", "compression on", "filtering active")
- **Always include a defaults-only test.** A test that runs with just the required inputs and default parameters catches template errors (bad Cheetah conditionals, missing defaults, output filters that never fire) before a user hits them — it has caught real bugs where a `#if $select_param:` conditional crashed the job at startup.
- Point expected files to unique golden files — no duplicate outputs for different logic paths
- Always include `expect_num_outputs` — count only outputs actually produced (filters that evaluate to False don't produce output)
- **Test data under 1 MB.** Use assertions (`<has_text>`, `<has_size>`) instead of golden files for larger outputs.
- Include tests for output filters to verify filtering actually occurs
- Include tests for error conditions with expected failure

### Assert Patterns

Use `<assert_contents>` with `<has_text>` for key content verification. Check header lines, known output values, and identifiers from the input data:

```xml
<output name="output_tsv">
    <assert_contents>
        <has_text text="chrom"/>           <!-- column header -->
        <has_text text="mean_signal"/>     <!-- column header -->
        <has_text text="sample_1"/>        <!-- from input -->
    </assert_contents>
</output>
```

For wide matrix outputs (e.g. gene × task tables where the number of columns depends on the upstream model), assert the exact column count plus a couple of known header values rather than golden-file comparing the whole matrix:

```xml
<output name="ablation_impact">
    <assert_contents>
        <has_n_columns n="100"/>
        <has_text_matching expression="^gene_id\ttask_1"/>
    </assert_contents>
</output>
```

For tabular outputs in general, `has_n_lines` / `has_n_columns` / `has_text_matching` are the workhorses when exact golden comparison is too brittle (non-deterministic floats, ordering).

For the full assertion catalog (file comparison modes, stream/command assertions, compressed output testing), see [`references/testing.md`](references/testing.md).

Test conditionals and sections with explicit nesting (not pipe syntax):

```xml
<!-- BAD: pipe syntax -->
<param name="filtering|min_score" value="0.5"/>

<!-- GOOD: explicit nesting -->
<section name="filtering">
    <param name="min_score" value="0.5"/>
</section>
```

### Running Tests

Run `planemo test --biocontainers` to execute tests. See **Reference: Useful Planemo Commands** at the end of this document for the full command set.

### Generating Expected Output Files

The standard approach for CLI-wrapping tools. Run the tool once via planemo and let it update the expected output files in place:

```bash
planemo test --biocontainers --update_test_data tools/mytool/mytool_align.xml
```

### URL-Based Test Data for Large Files

For test data >1 MB or complex datasets (image stacks, spatial transcriptomics), host files on Zenodo and reference by URL:

```xml
<test expect_num_outputs="1">
    <param name="input_images" location="https://zenodo.org/records/15319018/files/image_z0.tif,https://zenodo.org/records/15319018/files/image_z1.tif,https://zenodo.org/records/15319018/files/image_z2.tif"/>
    <param name="transform_csv" location="https://zenodo.org/records/15319018/files/transform.csv"/>
    <output name="result_image" location="https://zenodo.org/records/15319018/files/expected_output.png" ftype="png" compare="image_diff"/>
</test>
```

**Zenodo workflow:**
1. Create a Zenodo record for your test dataset
2. Upload all test inputs and expected outputs
3. Use the persistent DOI URLs in tests
4. Document the dataset structure in the tool's README

**When to use URL-based test data:**
- Test files exceed 1 MB (IUC guideline)
- Binary formats that don't compress well (images, HDF5)
- Multiple large files needed per test
- Shared test data across multiple tools

**Local vs URL testing:**
```bash
# URL-based tests download on first run, cache locally
planemo test tools/mytool/

# Use --update_test_data to regenerate local test files (doesn't affect URLs)
planemo test --update_test_data tools/mytool/
```

### Fixture-Based Testing (API Tools Only)

For the uncommon case of tools calling external APIs: record real responses as JSON fixtures and replay them in tests. This lets `planemo test` run without API keys. See the `test_fixture_param` macro in the macros.xml Patterns section above.

```bash
# Fixture-based tests (no container needed, no API key)
planemo test tools/mytool/
```

---

## 11. .shed.yml

```yaml
categories:
- Relevant Category
- Another Category
description: Short one-line description
long_description: |
  Multi-line description of the tool suite.
  What it does, what API/library it wraps.
name: mytool
owner: iuc
homepage_url: https://github.com/original/project
remote_repository_url: https://github.com/galaxyproject/tools-iuc/tree/main/tools/mytool
type: unrestricted
auto_tool_repositories:
  name_template: "{{ tool_id }}"
  description_template: "Wrapper for MyTool application: {{ tool_name }}."
suite:
  name: "suite_mytool"
  description: "A suite of Galaxy tools for MyTool."
  type: repository_suite_definition
```

**Key points:**
- `auto_tool_repositories` creates one Tool Shed repo per tool XML automatically
- `suite` groups all tools under a single installable suite
- `owner: iuc` for tools-iuc submissions
- `remote_repository_url` must use `tree/main` (tools-iuc's default branch is `main`, not `master`): `https://github.com/galaxyproject/tools-iuc/tree/main/tools/mytool`
- The suite `description` should be a copy of the top-level tool description — not generic boilerplate ("A suite of Galaxy tools for MyTool.")

### Dependencies & Versioning

- Requirements must be available in **conda-forge** or **bioconda** channels. Use the latest stable versions.
- When bumping the upstream tool version, check the changelog for new or deprecated parameters.
- When bumping `@TOOL_VERSION@`, reset `@VERSION_SUFFIX@` to `0`.
- If a `.lint_skip` file exists in the tool directory, try to fix the underlying issues and remove the skip entries rather than adding to them.
- Run `planemo lint` after every change. It catches element ordering, missing attributes, and parameter mismatches.

---

## 12. IUC PR Review Checklist

### Will Definitely Be Flagged

| Issue | What Reviewers Say | Fix |
|-------|-------------------|-----|
| Cheetah snippet in `<xml>` macro | "This should be a `<token>`, not `<xml>`" | Move to `<token name="@CMD_...@">` with CDATA |
| `display="checkboxes"` on multi-select | "Remove display attribute" | Delete it; let Galaxy pick the widget |
| Missing `detect_errors` | "Add error detection" | Add to `<command>` element. Use `aggressive` for CLI tools, `exit_code` for Python/R script-based wrappers (libraries write benign warnings to stderr that trip `aggressive`) |
| Version not from macro | "Use @TOOL_VERSION@ token" | Replace hardcoded version strings |
| `KB` / `MB` in display text | "Use kb / Mb (SI lowercase)" | Fix option labels to lowercase units |
| Missing `expect_num_outputs` on test | "Add expect_num_outputs" | Add `expect_num_outputs="1"` to `<test>` |
| Test data outside `test-data/` | "Move to test-data directory" | Move files, update paths |
| Missing help section | "Add help text" | Add `<help>` with CDATA |
| Missing citation | "Add citation DOI" | Add `<citations>` macro |
| `optional="true"` with a default | "Just use the default, remove optional" | Remove `optional`, set `value` |
| stdout used for logging | "Use stderr for logging" | `logging.StreamHandler(sys.stderr)` |
| Missing `argument=` on params | "Use argument= instead of bare name=" | `<param argument="--flag" .../>` |
| Bare `name=` duplicating `argument=` | "argument= auto-generates the name" | Remove redundant `name=`, keep `argument=` (flag still needed in command) |
| Param not used in command | "Orphaned parameter" | Remove param or wire it into command |
| Test data over 1 MB | "Test data must be under 1 MB" | Use smaller inputs or assert_contents instead of golden files |
| Boolean used as conditional | "Use select + conditional" | Replace boolean with select param when other params depend on choice |
| Missing compressed format support | "Accept fasta.gz too" | `format="fasta,fasta.gz"` |
| Missing bio.tools xref | "Add bio.tools cross-reference" | Add `<xrefs><xref type="bio.tools">id</xref></xrefs>` |
| `#if $select_param:` for True/False select | "Always true — value is the string 'False'" | `#if str($param) == 'True':` (string comparison, exact casing) |
| Comma-split list without empty-entry filter | "Trailing comma yields empty string" | `[str(x.strip()) for x in str($param).split(',') if x.strip()]` |
| Unanchored `discover_datasets` pattern | "Anchor the pattern" | End regex with `$` (e.g. `(?P<name>.+)\.tsv$`) |
| Undocumented data mutation in wrapper | "Why is .X converted here?" | Comment the why (upstream function requirement); convert only when needed |
| Missing defaults-only test | "Add a test with default parameters" | One test per tool running with required inputs + defaults only |
| Optional param with no default where default fits | "Set an explicit default" | e.g. `random_state` → `value="0"` (reproducibility), drop `optional` |
| Apostrophe in param default/label | "Sanitizer strips quotes" | Quote-free defaults (e.g. `Cohens_d`, not `Cohen's d`) |
| Unused requirements / unjustified pins | "Is this dependency used?" | Remove unused packages; pin transitive deps only with a comment explaining the conflict |
| Help references wrong tool name | "That's not the tool id" | Reference other tools by exact tool id |

### Commonly Requested Improvements

| Improvement | Typical Comment | Resolution |
|-------------|----------------|------------|
| Validator on multi-select | "Add no_options validator" | `<validator type="no_options" message="..."/>` |
| Help text structure | "Use horizontal rules between sections" | Add `-----` between help sections |
| Help format | "Use format=markdown" | `<help format="markdown">` |
| Regex validator on text input | "Validate user input format" | Add `<validator type="regex">` |
| Consistent output labels | "Use standard label pattern" | `${tool.name} on ${on_string}` |
| Test assert_contents | "Add content assertions, not just expect_num_outputs" | Add `<has_text>` checks |
| Error handling in script | "What happens if one item fails?" | Per-item try/except with continue (wrapper scripts) |
| API key handling (API tools) | "Use Galaxy credentials" | `<credentials>` macro with vault-backed secrets |
| Fixture-based tests (API tools) | "Tests shouldn't need network" | Add `--test-fixture` hidden param pattern |
| Section grouping | "Group related params" | Use `<section name="..." title="...">` |
| Pipe syntax in tests | "Use explicit nesting" | Replace `section\|param` with nested XML |
| `planemo tool_init` scaffold | "Use tool_init for boilerplate" | `planemo tool_init --id ... --requirement ...` |
| Test output `lines_diff` | "Use lines_diff for non-deterministic outputs" | `<output ... lines_diff="2"/>` |
| Missing stderr/stdout assertions | "Assert on expected warnings" | `<assert_stderr><has_text .../></assert_stderr>` |
| Docker container not in quay.io | "Use quay.io/biocontainers or quay.io/galaxy" | Host containers in approved registries |
| Tool data table without .test | "Add tool_data_table_conf.xml.test" | Create test version for planemo |
| Missing element identifier sanitization | "Unsafe filename from element_identifier" | Use `re.sub('[^\w\-]', '_', ...)` pattern |
| Configfiles script not saved for debugging | "Save generated script for users" | Add optional output with `from_work_dir` |
| Missing display=\"checkboxes\" removal | "Remove display attribute" | Delete `display="checkboxes"` from multi-select |

---

## 13. Updating Existing Tools

When updating a tool to a new upstream version, follow this workflow.

### Research Upstream Changes

Before touching the XML, check what changed:

1. **Check release notes** — GitHub releases, CHANGELOG.md, migration guides
2. **Compare --help output** between old and new versions (run the container if available)
3. **Search for breaking changes** — renamed/removed flags, changed defaults, output format changes

```bash
docker run quay.io/biocontainers/<package>:<new_version> <command> --help
```

| Change Type | Impact | Action |
|-------------|--------|--------|
| Flag renamed | Tool breaks | Update command section |
| Flag removed | Tool breaks | Remove from XML or make conditional |
| New required flag | Tool breaks | Add to command section |
| New optional flag | None | Consider adding to inputs |
| Default changed | Output changes | Update tests, maybe document |
| Output format changed | Tests break | Update golden files and assertions |

### Version Bump Procedure

1. Update `@TOOL_VERSION@` in `macros.xml`
2. Reset `@VERSION_SUFFIX@` to `0`
3. Review command section for deprecated/renamed flags
4. Review output filters for correctness
5. Update help section if upstream added significant features
6. Run `planemo lint` and `planemo test`
7. Fix test failures — update golden files, adjust assertions
8. Commit with descriptive message

### Common Update Bugs

**Repeat element access** — the most common bug found during updates:

```cheetah
## WRONG: accesses outer scope, not loop variable
#for item in $filters.search:
    --search '$filters.search_term'
#end for

## CORRECT: access param through loop variable
#for item in $filters.search:
    --search '$item.search_term'
#end for
```

**Wrong filter value** — output filters checking the wrong condition:

```xml
<!-- BUG: 3' UTR output filtering on 5p-utr -->
<data name="threep_utr" format="fasta">
    <filter>"5p-utr" in file_choices['include']</filter>
</data>

<!-- CORRECT -->
<data name="threep_utr" format="fasta">
    <filter>"3p-utr" in file_choices['include']</filter>
</data>
```

**Missing .strip() on text params** — whitespace-only input incorrectly treated as non-empty:

```cheetah
## BAD: empty or whitespace-only input passes the test
#if str($optional_param):
    --flag '$optional_param'
#end if

## GOOD: only non-empty, non-whitespace input passes
#if str($optional_param).strip():
    --flag '$optional_param'
#end if
```

---

## 14. Step-by-Step Workflow: Creating a New Tool

### Step 0: Check for Existing Wrappers

Before writing anything, search the Main Tool Shed and Test Tool Shed for existing wrappers:

Search the [Main Tool Shed](https://toolshed.g2.bx.psu.edu/) and [Test Tool Shed](https://testtoolshed.g2.bx.psu.edu/) web UIs, and search `tools-iuc`, `tools-devteam`, and other IUC-maintained repos on GitHub for existing wrappers.

Also check `bioconda` and `conda-forge` for an existing recipe — if none exists, you may need to create one first.

### Step 1: Inspect the Upstream Tool

```bash
docker run quay.io/biocontainers/<package>:<version> <command> --help
```

Identify: required inputs, outputs, key parameters, threading flags, version string.

### Step 2: Set Up Structure

Use `planemo tool_init` for the initial scaffold, then refine:

```bash
planemo tool_init --id mytool_function --name "MyTool Function" \
    --description "Brief description" \
    --requirement mytool@1.2.3 \
    --example_command "mytool function --input input.fa --output output.tsv" \
    --example_input input.fa --example_output output.tsv \
    --doi "10.1234/example" \
    tools/mytool/
```

Or manually:

```bash
mkdir -p tools/mytool/test-data
touch tools/mytool/macros.xml
touch tools/mytool/.shed.yml
```

### Step 3: Write macros.xml

Start with version tokens, requirements (from bioconda/conda-forge), shared params, and citations. Use the macros.xml template from the macros.xml Patterns section above.

### Step 4: Write the Tool XML

Follow element order from Section 2:
- `<tool>` with macro-based version and `profile="@PROFILE@"`
- `<macros>` import
- `<expand macro="requirements">`
- `<version_command>` — use `<tool_binary> --version` or `echo @TOOL_VERSION@`
- `<command>` with CDATA, `detect_errors` (`aggressive` for CLI tools, `exit_code` for script-based wrappers), and direct CLI call
- `<inputs>` — use `argument=` for CLI flags, group with `<section>`, add validators
- `<outputs>` with `${tool.name} on ${on_string}` labels, `from_work_dir` if needed
- `<tests>` — at least one test per code path, with `expect_num_outputs` and `assert_contents`
- `<help format="markdown">` with structured sections
- `<expand macro="citations"/>`

### Step 5: Create Test Data and Golden Files

- Create minimal input files that exercise the tool
- Run `planemo test --biocontainers --update_test_data` to generate expected output files in place

### Step 6: Write .shed.yml

Use `auto_tool_repositories` and `suite` for multi-tool packages.

### Step 7: Format, Lint, and Test

```bash
planemo format tools/mytool/
planemo lint tools/mytool/
planemo test --biocontainers tools/mytool/
```

### Step 8: Pre-PR Checklist

Run through the tables in Section 10 before opening the PR.

---

## 15. Quick Reference — Galaxy XML Element Ordering

For `planemo lint` compliance, elements must appear in this order:

```
tool
├── description
├── macros
├── edam_topics (optional)
├── edam_operations (optional)
├── xrefs (optional)
├── requirements (via expand)
├── version_command
├── command
├── environment_variables (optional)
├── configfiles (optional)
├── inputs
├── outputs
├── tests
├── help
└── citations (via expand)
```

---

## Reference: Useful Planemo Commands

```bash
# Format XML files (consistent indentation, matches Galaxy Language Server)
planemo format tools/mytool/

# Format with preview (show diff without writing)
planemo format --dry-run tools/mytool/

# Lint a tool directory
planemo lint tools/mytool/

# Test with biocontainers (standard for CLI tools)
planemo test --biocontainers tools/mytool/

# Test a single tool
planemo test --biocontainers tools/mytool/mytool_align.xml

# Test without containers (API tools with fixtures)
planemo test tools/mytool/

# Serve locally for manual testing
planemo serve tools/mytool/
```