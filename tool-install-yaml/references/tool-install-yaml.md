<!--
SYNCED DOCUMENT — do not hand-edit.
Source: https://github.com/jmchilton/galaxy-brain/blob/main/vault/research/Component%20-%20Tool%20Install%20YAML.md
Raw:    https://raw.githubusercontent.com/jmchilton/galaxy-brain/main/vault/research/Component%20-%20Tool%20Install%20YAML.md
To update: run `make -C tool-install-yaml sync` (re-pulls the raw source below this comment).
-->


# Galaxy Tool-Install YAML Files: A White Paper

> Scope note: This document describes the **tool *installation request* YAML** format — the
> declarative files that tell a Galaxy instance *which Tool Shed repositories to install and where
> to put them in the tool panel*. This is a different artifact from a tool's own `<tool>` **wrapper
> XML** (the file that defines a single tool's inputs/command/outputs) and from `tool_conf.xml`
> (the server-side panel config). The install YAML is consumed primarily by
> [**ephemeris**](https://github.com/galaxyproject/ephemeris) (`shed-tools`) and the
> [**ansible-galaxy-tools**](https://github.com/galaxyproject/ansible-galaxy-tools) role, and it is
> the curation format used at scale by
> [**usegalaxy-tools**](https://github.com/galaxyproject/usegalaxy-tools).

---

## 1. What problem does this format solve?

Galaxy tools are distributed through the **Galaxy Tool Shed** (`https://toolshed.g2.bx.psu.edu`).
An administrator does not check tool code into their Galaxy server; instead they *install a Tool
Shed repository at a specific changeset revision*. Doing this by hand through the admin UI is
fine for one tool, but production servers install thousands of tools and need the operation to be:

- **declarative** — the desired tool set is a file in version control, not clicks in a UI;
- **reproducible** — installing the same file on a fresh server yields the same tools at the same
  revisions;
- **idempotent** — re-running skips already-installed tools.

The tool-install YAML is that declarative file. The ephemeris module docstring states its purpose
directly:

> "A tool to automate installation of tool repositories from a Galaxy Tool Shed into an instance of
> Galaxy."
> — [`ephemeris/shed_tools.py`](https://github.com/galaxyproject/ephemeris/blob/main/src/ephemeris/shed_tools.py)

The admin training tutorial frames the same point:

> See [*Galaxy Tool Management with Ephemeris*](https://training.galaxyproject.org/training-material/topics/admin/tutorials/tool-management/tutorial.html)
> (Galaxy Training Network, `admin/tool-management`).

---

## 2. The canonical schema

The authoritative human-readable reference is the sample shipped with the ansible role,
[`files/tool_list.yaml.sample`](https://github.com/galaxyproject/ansible-galaxy-tools/blob/master/files/tool_list.yaml.sample).
Reproduced **verbatim**:

```yaml
---
# This is a sample file to be used as a reference for populating a list of
# tools that you wish to install into Galaxy from a Tool Shed via the
# `install_tool_shed_tools.py` script.
#
# For each tool you want to install, you must provide the following keys:
#  * name: this is is the name of the tool to install
#  * owner: owner of the Tool Shed repository from where the tools is being
#           installed
# Further, you need to provide **one** of the following two keys:
#  * tool_panel_section_id: ID of the tool panel section where you want the
#                           tool to be installed. The section ID can be found
#                           in Galaxy's `shed_tool_conf.xml` config file. Note
#                           that the specified section must exist in this file.
#                           Otherwise, the tool will be installed outside any
#                           section.
#  * tool_panel_section_label: Display label of a tool panel section where
#                              you want the tool to be installed. If it does not
#                              exist, this section will be created on the target
#                              Galaxy instance (note that this is different than
#                              when using the ID).
#                              Multi-word labels need to be placed in quotes.
#                              Each label will have a corresponding ID created;
#                              the ID will be an all lowercase version of the
#                              label, with multiple words joined with
#                              underscores (e.g., 'BED tools' -> 'bed_tools').
#
# You can also specify the following optional keys to further define the
# installation properties:
#  * tool_shed_url: the URL of the Tool Shed from where the tool should be
#                   installed. (default: https://toolshed.g2.bx.psu.edu)
#  * revisions: a list of revisions of the tool, all of which will attempt to
#               be installed. (default: latest)
#  * install_tool_dependencies: True or False - whether to install classic galaxy 
#                               Tool Shed dependencies or not. (default: True)
#  * install_repository_dependencies: True or False - whether to install classic
#                               Galaxy Tool Shed repo dependencies or not. 
#                               (default: True)
#  * install_resolver_dependencies: True or False - whether to install dependencies
#                                through a resolver (e.g Conda). (default: False)

api_key: <Admin user API key from galaxy_instance>
galaxy_instance: <Galaxy instance IP>
tools:
- name: fastqc
  owner: devteam
  tool_panel_section_id: cshl_library_information
  tool_shed_url: https://toolshed.g2.bx.psu.edu
  revisions:
  - '8c650f7f76e9'  # v0.62
  - 'd2cf2c0c8a11'  # v0.63
- name: bedtools
  owner: iuc
  tool_panel_section_label: 'BED tools'
  revisions:
  - 2cd7e321d259
- name: data_manager_fetch_genome_dbkeys_all_fasta
  owner: devteam
  tool_shed_url: https://toolshed.g2.bx.psu.edu
  revisions:
  - b1bc53e9bbc5
```

### 2.1 Top-level keys

| Key | Type | Meaning |
|---|---|---|
| `api_key` | str | Admin user's API key on the target Galaxy. Optional in the file; usually passed on the CLI instead. |
| `galaxy_instance` | str | Target Galaxy base URL. Optional in the file; usually passed on the CLI as `-g`. |
| `tools` | list | The list of repositories to install (see below). |

The same three install-policy flags may *also* appear at the top level to set defaults for every
entry — this is exactly what the generated lock files do (§5).

### 2.2 Per-tool keys

This is encoded precisely in ephemeris's Pydantic model
[`RepositoryInstallTarget`](https://github.com/galaxyproject/ephemeris/blob/main/src/ephemeris/_config_models.py):

```python
class RepositoryInstallTarget(BaseModel):
    name: str
    owner: str
    tool_shed_url: str | None = None
    tool_panel_section_id: str | None = None
    tool_panel_section_label: str | None = None
    revisions: list[str] | None = None
    install_tool_dependencies: bool | None = None
    install_repository_dependencies: bool | None = None
    install_resolver_dependencies: bool | None = None


class RepositoryInstallTargets(BaseModel):
    api_key: str | None = None
    galaxy_instance: str | None = None
    tools: list[RepositoryInstallTarget]
```

| Key | Required? | Notes |
|---|---|---|
| `name` | **yes** | Tool Shed *repository* name (not the inner tool id). |
| `owner` | **yes** | Tool Shed namespace, e.g. `iuc`, `devteam`, `bgruening`. |
| `tool_panel_section_id` **or** `tool_panel_section_label` | one of them (recommended) | Where the tool lands in the panel. `_id` must **already exist**; `_label` is created if missing. See §4. |
| `tool_shed_url` | no | Default `https://toolshed.g2.bx.psu.edu`. |
| `revisions` | no | List of changeset hashes. Default = latest installable. Multiple → multiple versions installed side-by-side. |
| `install_tool_dependencies` | no | Classic Tool Shed (tool_dependencies.xml) deps. Sample default `True`. |
| `install_repository_dependencies` | no | Classic repository_dependencies.xml deps. Sample default `True`. |
| `install_resolver_dependencies` | no | Resolve deps (Conda/containers) via Galaxy's dependency resolvers. Sample default `False`. |

> **`name` is the repository, not the tool.** A single Tool Shed repository can ship several tools.
> You request the repository; Galaxy exposes whatever tools it contains. The inner per-tool id used
> elsewhere in Galaxy (e.g. `toolshed.g2.bx.psu.edu/repos/iuc/bedtools/bedtools_intersect/2.30.0`)
> is derived, not something you put in this file. (See [[Component - Tool Shed Search and Indexing]]
> for how the Tool Shed assembles this GUID from `<host>/repos/<owner>/<name>/<tool_id>/<version>`.)

### 2.3 Three ways to supply the same data

ephemeris accepts the identical key set through three channels, in precedence order
([`shed_tools.py` docstring](https://github.com/galaxyproject/ephemeris/blob/main/src/ephemeris/shed_tools.py)):

> 1. "In the YAML format via dedicated files (a sample can be found
>    [here](https://github.com/galaxyproject/ansible-galaxy-tools/blob/master/files/tool_list.yaml.sample))."
> 2. "On the command line as dedicated script options (see the usage help)."
> 3. "As a single composite parameter to the script. The parameter must be a single,
>    YAML-formatted string with the keys corresponding to the keys available for use in the YAML
>    formatted file (for example: `--yaml_tool "{'owner': 'kellrott', 'tool_shed_url':
>    'https://testtoolshed.g2.bx.psu.edu', 'tool_panel_section_id': 'peak_calling', 'name':
>    'synapse_interface'}"`)."
>
> "Only one of the methods can be used with each invocation of the script but if more than one are
> provided […] precedence will correspond to order of the items in the list above."

---

## 3. The tooling that consumes the YAML: ephemeris `shed-tools`

[ephemeris](https://github.com/galaxyproject/ephemeris) is the Galaxy Project's library of admin
automation scripts. The relevant entry point is `shed-tools`, which the docstring summarizes:

> "Shed-tools has three commands: update, test and install.
> Update simply updates all the tools in a Galaxy given connection details on the command line.
> Test tests the specified tools in the Galaxy Instance.
> Install allows installation of tools in multiple ways."
> — [`shed_tools.py`](https://github.com/galaxyproject/ephemeris/blob/main/src/ephemeris/shed_tools.py)

### 3.1 Install from a file

```bash
shed-tools install -g https://galaxy.example.org -a <api-key> -t tool_list.yaml
```

(`-t/--toolsfile` is the install YAML; `-g` the Galaxy URL; `-a` the admin API key.) Installation
is idempotent — already-installed repository revisions are filtered out (see `FilterResults` /
`already_installed_repos` in `shed_tools.py`) and skipped.

### 3.2 Install a single tool from CLI options

```bash
shed-tools install -g https://galaxy.example.org -a <api-key> --name bwa --owner devteam --section_label Mapping
```

### 3.3 Test installed tools

```bash
shed-tools test -g https://galaxy.example.org -a <api-key> --name bamtools_filter --owner devteam
```

ephemeris drives this through Galaxy's own test interactor
([`galaxy.tool_util.verify.interactor`](https://github.com/galaxyproject/ephemeris/blob/main/src/ephemeris/shed_tools.py)
imports `GalaxyInteractorApi`, `verify_tool`), so the same machinery that runs a tool's
functional tests in CI verifies the freshly installed tool.

### 3.4 Round-tripping: export an existing server's tools

The reverse direction — turning a live Galaxy into a YAML file — is `get-tool-list`:

```bash
get-tool-list -g "https://usegalaxy.eu" -o "eu_tool_list.yaml"
```

Implemented by
[`get_tool_list_from_galaxy.py`](https://github.com/galaxyproject/ephemeris/blob/main/src/ephemeris/get_tool_list_from_galaxy.py),
whose `GiToToolYaml` class walks the live tool panel (`get_tool_panel`) and emits the same schema.
This is how an admin clones one server's tool set onto another, and how `usegalaxy-*` operators
audit drift. Note the panel walk distinguishes `model_class == "Tool"` from `"ToolSection"`,
recursing into sections — so the exported YAML preserves panel placement.

### 3.5 Generating a YAML from a workflow

Because a Galaxy `.ga` workflow records every tool (repository + revision) it uses, ephemeris can
extract the install list directly from a workflow file — closing the loop between "I have a
workflow" and "install everything it needs":

```bash
workflow-to-tools -w mapping.ga -o tools/workflow_tools.yml -l Mapping
```

(`-l` sets the `tool_panel_section_label` for all extracted tools.) Implemented by
[`generate_tool_list_from_ga_workflow_files.py`](https://github.com/galaxyproject/ephemeris/blob/main/src/ephemeris/generate_tool_list_from_ga_workflow_files.py).
The tutorial presents this as the recommended way to make a workflow portable across Galaxy
servers. (The `.ga` step `tool_shed_repository` records that supply these hashes are described in
[[Component - Workflow Format (.ga)]].)

---

## 4. Tool-panel placement semantics (the part admins get wrong)

The single most error-prone field pair is `tool_panel_section_id` vs `tool_panel_section_label`.
The sample comments and the `shed_tools.py` docstring together pin down the exact rules:

- **`tool_panel_section_id`** — must **already exist** in the server's `shed_tool_conf.xml`. From
  the docstring:
  > "When installing tools, Galaxy expects any `tool_panel_section_id` provided when installing a
  > tool to already exist in the configuration. If the section does not exist, the tool will be
  > installed outside any section."
  Silent mis-placement (tool ends up section-less) is the failure mode here.

- **`tool_panel_section_label`** — created on demand if absent. The label→id normalization is
  deterministic, from the sample:
  > "Each label will have a corresponding ID created; the ID will be an all lowercase version of
  > the label, with multiple words joined with underscores (e.g., 'BED tools' -> 'bed_tools')."

- **Multi-word labels must be quoted** in YAML (`tool_panel_section_label: 'BED tools'`).

Practical guidance: on a server you control end-to-end, prefer `tool_panel_section_label` so
sections self-create. When matching an existing curated panel (the usegalaxy case), the `.yml`
carries the `_label` and the generated `.yml.lock` carries the derived `_id` as well (§5).

---

## 5. Production curation at scale: `usegalaxy-tools`

[`galaxyproject/usegalaxy-tools`](https://github.com/galaxyproject/usegalaxy-tools) is the live,
public curation repo that drives tool installation on UseGalaxy.org (and `test.galaxyproject.org`,
`cloud`). It demonstrates the format's intended production pattern and adds a crucial second file
type: **lock files**.

### 5.1 Repository layout

Top-level git tree (verbatim from the GitHub API):

```
.ci/            .github/        .gitignore
.schema.yml     CODEOWNERS      LICENSE
Makefile        README.md       requirements.txt
cloud/          scripts/        test.galaxyproject.org/   usegalaxy.org/
```

Each *toolset* directory (`usegalaxy.org/`, `test.galaxyproject.org/`, `cloud/`) holds one
`.yml`/`.yml.lock` **pair per tool-panel section**. The naming pattern is
`{server_name}/{section_id}.yml`. Excerpt of `usegalaxy.org/`:

```
annotation.yml      annotation.yml.lock
assembly.yml        assembly.yml.lock
bed.yml             bed.yml.lock
chip_seq.yml        chip_seq.yml.lock
data_managers.yml   data_managers.yml.lock
deeptools.yml       deeptools.yml.lock
mapping.yml         mapping.yml.lock
rna_seq.yml         rna_seq.yml.lock
variant_calling.yml variant_calling.yml.lock
...
```

### 5.2 `.yml` (hand-curated) vs `.yml.lock` (machine-generated)

The README states the distinction explicitly:

> - "`yaml` files contain the names of Tool Shed tools/repositories to install and are **manually**
>   curated."
> - "`yaml.lock` files are **automatically** generated and contain the list of revisions (read
>   'tool versions') to include."

This is the classic *manifest vs lock file* split (think `package.json` vs `package-lock.json`).
A human edits the short request file; tooling resolves it to exact pinned revisions.

**The request file** [`usegalaxy.org/bed.yml`](https://github.com/galaxyproject/usegalaxy-tools/blob/master/usegalaxy.org/bed.yml)
— minimal, no revisions, no dependency flags:

```yaml
tool_panel_section_label: BED
tools:
- name: bedtools
  owner: iuc
- name: bedops_sortbed
  owner: iuc
```

**The generated lock** [`usegalaxy.org/bed.yml.lock`](https://github.com/galaxyproject/usegalaxy-tools/blob/master/usegalaxy.org/bed.yml.lock)
— every installable revision pinned, dependency policy made explicit, and the derived
`tool_panel_section_id` (`bed`) filled in:

```yaml
install_repository_dependencies: false
install_resolver_dependencies: false
install_tool_dependencies: false
tool_panel_section_label: BED
tools:
- name: bedtools
  owner: iuc
  revisions:
  - 07e8b80f278c
  - 0a5c785ac6db
  - 2892111d91f8
  - 64e2edfe7a2c
  - 7ab85ac5f64b
  - a1a923cd89e8
  - a68aa6c1204a
  - b28e0cfa7ba1
  - ce3c7f062223
  - fe5b4cb8356c
  tool_panel_section_id: bed
  tool_panel_section_label: BED
- name: bedops_sortbed
  owner: iuc
  revisions:
  - 3f847205cf8f
  - baeee32175e8
  tool_panel_section_id: bed
  tool_panel_section_label: BED
```

Three things to notice in the lock that are *absent* from the request:
1. **All historical installable revisions are listed**, not just the latest — usegalaxy keeps old
   tool versions installed so old histories/workflows remain reproducible.
2. **Dependency flags are pinned to `false`** — UseGalaxy resolves dependencies via
   BioContainers/Conda out-of-band (CVMFS), not via the Tool Shed's classic dependency mechanism.
3. **`tool_panel_section_id: bed`** is the auto-derived lowercase of label `BED`.

### 5.3 Schema validation

The repo ships a [pykwalify](https://pykwalify.readthedocs.io/) schema,
[`.schema.yml`](https://github.com/galaxyproject/usegalaxy-tools/blob/master/.schema.yml), used in
CI to validate every request file (verbatim):

```yaml
---
type: map
mapping:
    "tool_panel_section_id":
        type: str

    "tool_panel_section_label":
        type: str

    "tools":
        type: seq
        sequence:
            - type: map
              mapping:
                "name":
                    type: str
                    required: true
                "owner":
                    type: str
                    required: true
                "tool_shed_url":
                    type: str
                    required: false
```

(This validates the *request* file surface — `name` and `owner` required, everything else
optional — which is why the curated `.yml` can be so terse.)

### 5.4 The Makefile: how requests become locks

The [`Makefile`](https://github.com/galaxyproject/usegalaxy-tools/blob/master/Makefile) is the
operator interface. Key targets (verbatim):

```make
GALAXY_SERVER := https://usegalaxy.*
TOOLSET := usegalaxy.org

lint: ## Lint all yaml files
	find ./$(TOOLSET) -name '*.yml' ! -path .//.schema.yml | grep '^\./[^/]*/' | xargs -n 1 -P 8 python scripts/fix_lockfile.py
	find ./$(TOOLSET) -name '*.yml' ! -path .//.schema.yml | grep '^\./[^/]*/' | xargs -n 1 -P 8 -I{} pykwalify -d '{}' -s .schema.yml

fix: ## Fix all lockfiles and add any missing revisions
	@# Generates the lockfile or updates it if it is missing tools
	find ./$(TOOLSET) -name '*.yml' ! -path .//.schema.yml | grep '^\./[^/]*/' | xargs -n 1 -P 8 python scripts/fix_lockfile.py
	@# --without says only add those hashes for those missing hashes (zB new tools)
	find ./$(TOOLSET) -name '*.yml' ! -path .//.schema.yml | grep '^\./[^/]*/' | xargs -n 1 -P 8 python scripts/update_tool.py --without

fix-no-deps:
	find ./$(TOOLSET) -name '*.yml' ! -path .//.schema.yml  | grep '^\./[^/]*/' | xargs -n 1 -P 8 python scripts/fix_lockfile.py --no-install-repository-dependencies --no-install-resolver-dependencies
	find ./$(TOOLSET) -name '*.yml' ! -path .//.schema.yml | grep '^\./[^/]*/' | xargs -n 1 -P 8 python scripts/update_tool.py --without

update-trusted: ## Run the update script for a subset of repos
	find ./$(TOOLSET) -name '*.yml' ! -path .//.schema.yml | grep '^\./[^/]*/' | xargs -n 1 -P 8 python scripts/update_tool.py --owner $(OWNER)

update-all: ## Run the update script for all repos
	find ./$(TOOLSET) -name '*.yml' ! -path .//.schema.yml | grep '^\./[^/]*/' | xargs -n 1 -P 8 python scripts/update_tool.py
```

Reading the targets:
- **`fix`** = regenerate locks (`fix_lockfile.py`) + add only *missing* revisions
  (`update_tool.py --without`). This is what a contributor runs after adding a tool — it pins the
  new tool's current revision without bumping every other tool.
- **`fix-no-deps`** = same, but writes `install_repository_dependencies: false` /
  `install_resolver_dependencies: false` into the lock (the usegalaxy default, matching §5.2).
- **`update-all` / `update-trusted`** = *no* `--without`, so they bump **every** (or a single
  owner's) tool to the latest revision — the periodic "update all tools" job.
- **`lint`** = regenerate locks *and* pykwalify-validate against `.schema.yml`.

### 5.5 Contributor workflow (from the README)

> 1. Fork and clone the repository, then set up a Python virtualenv (`pip install -r requirements.txt`).
> 2. If needed, create a new section file: "Create `{server_name}/<section_id>.yml` setting
>    `tool_panel_section_label` from the section label."
> 3. "Add the entry for the new tool to the section yml (only the yml, not the yml.lock)."
> 4. Run `make TOOLSET={server_name} fix` (latest versions) or
>    `make TOOLSET={server_name} fix-no-deps` (specific versions / no deps).
> 5. Run `make TOOLSET={server_name} lint` to validate.
> 6. Commit and open a PR against `master`.
> 7. After merge/deploy, test the tool to verify functionality.

Important documented constraints:
- "Tools can only be installed on one 'toolset' (Galaxy instance) at a time" — one toolset per PR.
- "Suites cannot be installed using their `suite_` repo. Each repo in the suite must be added
  individually." (You expand a suite into its component repositories rather than requesting the
  meta-repo.)
- BioContainers are required for Test and Main deployments (dependencies are resolved via
  containers, not classic Tool Shed deps — hence the `false` flags in the locks).

### 5.6 The deployment loop (bot-driven CI/CD)

usegalaxy-tools is not just storage; it's a CI/CD pipeline. From the README, the lifecycle after a
PR is opened:

- Comment **`@galaxybot test this`** → Jenkins installs the tools onto a staging server; the
  contributor verifies the diff to `config/shed_tool_conf.xml` and the `shed_tools/` directories.
- Comment **`galaxybot deploy this`** → tools are published to **CVMFS** (the CernVM File System
  that distributes the UseGalaxy tool/dependency tree to worker nodes).
- The PR is merged only after the Jenkins console confirms a successful CVMFS publish.

The actual install step under the hood is still `shed-tools` (note the commented-out `install`
target in the Makefile: `shed-tools install --toolsfile $< --galaxy $(GALAXY_SERVER) --api_key
$(GALAXY_API_KEY)`); the bot infrastructure wraps it with staging, CVMFS publishing, and gating.

---

## 6. Worked example: making a workflow portable (the tutorial's arc)

The [GTN tool-management tutorial](https://training.galaxyproject.org/training-material/topics/admin/tutorials/tool-management/tutorial.html)
ties the pieces together as a single admin story:

1. **Extract** the tool requirements from a workflow:
   ```bash
   workflow-to-tools -w mapping.ga -o tools/workflow_tools.yml -l Mapping
   ```
   yielding (shape shown in the tutorial):
   ```yaml
   install_tool_dependencies: True
   install_repository_dependencies: True
   install_resolver_dependencies: True
   tools:
   - name: fastqc
     owner: devteam
     revisions:
     - e7b2202befea
     tool_panel_section_label: Mapping
     tool_shed_url: https://toolshed.g2.bx.psu.edu/
   ```
2. **Install** it on the target server:
   ```bash
   shed-tools install -g https://galaxy.example.org -a <api-key> -t workflow_tools.yml
   ```
3. **(Optionally) export** a reference server's full tool set to compare/seed:
   ```bash
   get-tool-list -g "https://usegalaxy.eu" -o "eu_tool_list.yaml"
   ```

The tutorial closes the loop the usegalaxy way: real production servers keep these YAMLs in git and
"lock files [are] automatically generated from these with the latest revision," installed by CI
(Jenkins) with sequential, gated installs.

---

## 7. Relationship to neighbouring artifacts (disambiguation)

Galaxy has several YAML/XML files with "tool" in the name. They are distinct:

| Artifact | Purpose | Who writes it |
|---|---|---|
| **Tool-install YAML** (this paper) | *Request* to install Tool Shed repositories at revisions, with panel placement & dependency policy | Admins / curators (e.g. usegalaxy-tools) |
| **`*.yml.lock`** | Machine-pinned resolution of the request | `scripts/fix_lockfile.py` / `update_tool.py` |
| **Tool wrapper `<tool>` XML** | Defines one tool's interface (inputs, command, outputs, tests) | Tool developers; lives in the Tool Shed repo |
| **`tool_conf.xml` / `shed_tool_conf.xml`** | Server-side tool *panel* config; `shed_tool_conf.xml` is where installed-from-shed tools register and where section ids live | Galaxy server / install process |
| **`data_managers.yml`** (ephemeris/IDC) | Maps reference-data indexers to data-manager tools (different model: `DataManager`, `Genome` in `_config_models.py`) | Reference-data curators |

A useful mental model: the install YAML is to a Galaxy server what a `requirements.txt`/lockfile is
to a Python virtualenv — it names *what to install and at which version*, not *what each thing does*.

---

## 8. Field reference quick card

```yaml
# Top level
api_key: <admin API key>            # optional in file; usually CLI -a
galaxy_instance: <galaxy base URL>  # optional in file; usually CLI -g
# (lock files also set these three as global defaults:)
install_tool_dependencies: false
install_repository_dependencies: false
install_resolver_dependencies: false

tools:
- name: <repository name>           # REQUIRED
  owner: <toolshed owner>           # REQUIRED
  tool_shed_url: https://toolshed.g2.bx.psu.edu   # default
  # choose ONE of:
  tool_panel_section_id: <existing id>            # must pre-exist, else section-less
  tool_panel_section_label: 'Human Label'         # auto-created; quote multi-word
  revisions:                        # default = latest; list installs multiple versions
  - <changeset_revision>
  install_tool_dependencies: true                 # classic deps (sample default True)
  install_repository_dependencies: true           # classic repo deps (sample default True)
  install_resolver_dependencies: false            # Conda/containers (sample default False)
```

---

## Related notes

- [[Component - Tool Shed Search and Indexing]] — how the Tool Shed stores repositories, computes
  installable changeset revisions, and assembles the `<host>/repos/<owner>/<name>/<tool_id>/<version>`
  GUID that this format's `name`/`owner`/`revisions` ultimately resolve against.
- [[Component - Workflow Format (.ga)]] — the `.ga` workflow's per-step `tool_shed_repository`
  records are the source `workflow-to-tools` reads to emit an install YAML (§3.5, §6).

---

## Sources

- **ephemeris** — Galaxy admin automation library (`shed-tools`, `get-tool-list`, `workflow-to-tools`):
  - Repo: https://github.com/galaxyproject/ephemeris
  - `src/ephemeris/shed_tools.py` (install/update/test, schema docstring, three-input precedence)
  - `src/ephemeris/_config_models.py` (`RepositoryInstallTarget` / `RepositoryInstallTargets` Pydantic models)
  - `src/ephemeris/get_tool_list_from_galaxy.py` (`GiToToolYaml`, panel walk → YAML)
  - `src/ephemeris/generate_tool_list_from_ga_workflow_files.py` (`workflow-to-tools`)
  - Docs: https://ephemeris.readthedocs.io/
- **Canonical sample** — `ansible-galaxy-tools` role:
  - https://github.com/galaxyproject/ansible-galaxy-tools/blob/master/files/tool_list.yaml.sample
- **GTN training tutorial** — *Galaxy Tool Management with Ephemeris*:
  - https://training.galaxyproject.org/training-material/topics/admin/tutorials/tool-management/tutorial.html
- **usegalaxy-tools** — production curation repo (locks, schema, Makefile, bot CI/CD):
  - Repo & README: https://github.com/galaxyproject/usegalaxy-tools
  - `.schema.yml`: https://github.com/galaxyproject/usegalaxy-tools/blob/master/.schema.yml
  - `Makefile`: https://github.com/galaxyproject/usegalaxy-tools/blob/master/Makefile
  - Example pair: `usegalaxy.org/bed.yml` & `usegalaxy.org/bed.yml.lock`
- **Galaxy Tool Shed** — `https://toolshed.g2.bx.psu.edu` (default `tool_shed_url`).

*Compiled from upstream artifacts retrieved 2026-06-12. Verbatim quotes link to their `master`/`main`
source; revision hashes and exact file contents may drift as the repos update.*
