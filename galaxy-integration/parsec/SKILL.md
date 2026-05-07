---
name: parsec
description: >
  Use when the user needs to interact with a Galaxy server via the shell:
  listing/running workflows, uploading/downloading datasets, managing histories,
  inspecting tools, or any Galaxy API operation that should produce a reusable
  shell command or script. Prefer parsec over Galaxy MCP when: scripting or
  automating batch operations, piping JSON output through jq, no MCP runtime is
  available, or the user wants a reproducible command they can save/share.
  Prefer Galaxy MCP over parsec for conversational one-off lookups when the MCP
  server is already connected. Prefer galaxy_tool_checker.py for
  large-scale tool validation across many tools.
user_invocable: true
---

# Parsec — Galaxy CLI Skill

`parsec` is a BioBlend-backed CLI for driving Galaxy servers from the shell.
It emits JSON and composes naturally with `jq`.

## When to use parsec vs siblings

| Need | Use |
|------|-----|
| Interactive exploration, one-off query | Galaxy MCP (`../mcp-reference/SKILL.md`) |
| Bulk tool validation across many tools | `galaxy_tool_checker.py` (`../scripts/`) |
| Scripted workflow/dataset ops, CI, jq pipelines | **parsec** (this skill) |
| JupyterLite notebooks interacting with Galaxy | `jupyterlite-galaxy` (`../jupyterlite/SKILL.md`) |

## Quick start

```bash
# Configure a Galaxy instance (creates ~/.parsec.yml)
parsec init --url https://usegalaxy.org --api_key <KEY>

# Override instance per command
parsec -g myserver histories get_histories | jq '.[].name'

# Config file location
cat ~/.parsec.yml
```

Invocation pattern: `parsec [-g INSTANCE] <group> <command> [ARGS] [OPTIONS]`

All commands output JSON. Pipe through `jq` to filter:
```bash
parsec workflows get_workflows | jq '.[] | {id, name}'
parsec histories get_histories | jq '.[] | select(.name == "My History") | .id'
```

## Agent safety protocol

Before any write/destructive action:
1. **Inspect first** — run `get_*` / `show_*` / `list_*` to enumerate targets
2. **Summarize IDs** — echo back to the user what will be affected
3. **Confirm** — ask the user before running `delete_*`, `purge_*`, or admin commands

Example pattern:
```bash
# 1. Inspect
parsec histories get_histories | jq '.[] | {id, name}'
# 2. (report to user: "Found history 'Old Run' with id abc123")
# 3. (wait for confirmation)
parsec histories delete_history abc123
```

## Command index

Safety tags: **R** = read-only, **W** = write/create, **D** = destructive, **A** = admin-only

<!-- AUTO-GENERATED:START -->
| Group | Command | Tag | Description |
|-------|---------|-----|-------------|
| config | get_config | R | Get a list of attributes about the Galaxy instance. More attributes will be pres |
| config | get_version | R | Get the current version of the Galaxy instance |
| dataset_collections | download_dataset_collection | R | Download a history dataset collection as an archive |
| dataset_collections | show_dataset_collection | R | Get details of a given dataset collection of the current user |
| dataset_collections | wait_for_dataset_collection | R | Wait until all or a specified proportion of elements of a dataset collection are |
| datasets | download_dataset | R | Download a dataset to file or in memory. If the dataset state is not 'ok', a ``D |
| datasets | get_datasets | R | Get the latest datasets, or select another subset by specifying optional argumen |
| datasets | publish_dataset | W | Make a dataset publicly available or private. For more fine-grained control (ass |
| datasets | show_dataset | R | Get details about a given dataset. This can be a history or a library dataset |
| datasets | update_permissions | W | Set access, manage or modify permissions for a dataset to a list of roles |
| datasets | wait_for_dataset | R | Wait until a dataset is in a terminal state |
| datatypes | get_datatypes | R | Get the list of all installed datatypes |
| datatypes | get_sniffers | R | Get the list of all installed sniffers |
| folders | create_folder | W | Create a folder |
| folders | delete_folder | D | Marks the folder with the given ``id`` as `deleted` (or removes the `deleted` ma |
| folders | get_permissions | R | Get the permissions of a folder |
| folders | set_permissions | W | Set the permissions of a folder |
| folders | show_folder | R | Display information about a folder |
| folders | update_folder | W | Update folder information |
| forms | create_form | W | Create a new form |
| forms | get_forms | R | Get the list of all forms |
| forms | show_form | R | Get details of a given form |
| ftpfiles | get_ftp_files | R | Get a list of local files |
| genomes | get_genomes | R | Returns a list of installed genomes |
| genomes | install_genome | W | Download and/or index a genome |
| genomes | show_genome | R | Returns information about build <id> |
| groups | add_group_role | A | Add a role to the given group |
| groups | add_group_user | A | Add a user to the given group |
| groups | create_group | A | Create a new group |
| groups | delete_group_role | A | Remove a role from the given group |
| groups | delete_group_user | A | Remove a user from the given group |
| groups | get_group_roles | A | Get the list of roles associated to the given group |
| groups | get_group_users | A | Get the list of users associated to the given group |
| groups | get_groups | A | Get all (not deleted) groups |
| groups | show_group | A | Get details of a given group |
| groups | update_group | A | Update a group |
| histories | copy_content | W | Copy existing content (e.g. a dataset) to a history |
| histories | copy_dataset | W | Copy a dataset to a history |
| histories | create_dataset_collection | W | Create a new dataset collection |
| histories | create_history | W | Create a new history, optionally setting the ``name`` |
| histories | create_history_tag | W | Create history tag |
| histories | delete_dataset | D | Mark corresponding dataset as deleted |
| histories | delete_dataset_collection | D | Mark corresponding dataset collection as deleted |
| histories | delete_history | D | Delete a history |
| histories | download_history | R | Download a history export archive.  Use :meth:`export_history` to create an expo |
| histories | export_history | R | Start a job to create an export archive for the given history |
| histories | get_histories | R | Get all histories, or select a subset by specifying optional arguments for filte |
| histories | get_most_recently_used_history | R | Returns the current user's most recently used history (not deleted) |
| histories | get_published_histories | R | Get all published histories (by any user), or select a subset by specifying opti |
| histories | get_status | R | Returns the state of this history |
| histories | import_history | W | Import a history from an archive on disk or a URL |
| histories | open_history | W | Open Galaxy in a new tab of the default web browser and switch to the specified  |
| histories | show_dataset | R | Get details about a given history dataset |
| histories | show_dataset_collection | R | Get details about a given history dataset collection |
| histories | show_dataset_provenance | R | Get details related to how dataset was created (``id``, ``job_id``, ``tool_id``, |
| histories | show_history | R | Get details of a given history. By default, just get the history meta informatio |
| histories | show_matching_datasets | R | Get dataset details for matching datasets within a history |
| histories | undelete_history | W | Undelete a history |
| histories | update_dataset | W | Update history dataset metadata. Some of the attributes that can be modified are |
| histories | update_dataset_collection | W | Update history dataset collection metadata. Some of the attributes that can be m |
| histories | update_history | W | Update history metadata information. Some of the attributes that can be modified |
| histories | upload_dataset_from_library | W | Upload a dataset into the history from a library. Requires the library dataset I |
| init | init | W | Help initialize global configuration (in home directory) |
| invocations | cancel_invocation | D | Cancel the scheduling of a workflow |
| invocations | get_invocation_biocompute_object | R | Get a BioCompute object for an invocation |
| invocations | get_invocation_report | R | Get a Markdown report for an invocation |
| invocations | get_invocation_report_pdf | R | Get a PDF report for an invocation |
| invocations | get_invocation_step_jobs_summary | R | Get a detailed summary of an invocation, listing all jobs with their job IDs and |
| invocations | get_invocation_summary | R | Get a summary of an invocation, stating the number of jobs which succeed, which  |
| invocations | get_invocations | R | Get all workflow invocations, or select a subset by specifying optional argument |
| invocations | rerun_invocation | W | Rerun a workflow invocation. For more extensive documentation of all parameters, |
| invocations | run_invocation_step_action | W | nature of this action and what is expected will vary based on the the type of wo |
| invocations | show_invocation | R | Get a workflow invocation dictionary representing the scheduling of a workflow.  |
| invocations | show_invocation_step | R | See the details of a particular workflow invocation step |
| invocations | wait_for_invocation | R | Wait until an invocation is in a terminal state |
| jobs | cancel_job | D | Cancel a job, deleting output datasets |
| jobs | get_common_problems | R | Query inputs and jobs for common potential problems that might have resulted in  |
| jobs | get_destination_params | R | Get destination parameters for a job, describing the environment and location wh |
| jobs | get_inputs | R | Get dataset inputs used by a job |
| jobs | get_jobs | R | Get all jobs, or select a subset by specifying optional arguments for filtering  |
| jobs | get_metrics | R | Return job metrics for a given job |
| jobs | get_outputs | R | Get dataset outputs produced by a job |
| jobs | get_state | R | Display the current state for a given job of the current user |
| jobs | report_error | W | Report an error for a given job and dataset to the server administrators |
| jobs | rerun_job | W | Rerun a job |
| jobs | resume_job | W | Resume a job if it is paused |
| jobs | search_jobs | R | Return jobs matching input parameters |
| jobs | show_job | R | Get details of a given job of the current user |
| jobs | show_job_lock | R | Show whether the job lock is active or not. If it is active, no jobs will dispat |
| jobs | update_job_lock | A | Update the job lock status by setting ``active`` to either ``True`` or ``False`` |
| jobs | wait_for_job | R | Wait until a job is in a terminal state |
| libraries | copy_from_dataset | W | Copy a Galaxy dataset into a library |
| libraries | create_folder | W | Create a folder in a library |
| libraries | create_library | W | Create a data library with the properties defined in the arguments |
| libraries | delete_library | D | Delete a data library |
| libraries | delete_library_dataset | D | Delete a library dataset in a data library |
| libraries | get_dataset_permissions | R | Get the permissions for a dataset |
| libraries | get_folders | R | Get all the folders in a library, or select a subset by specifying a folder name |
| libraries | get_libraries | R | Get all libraries, or select a subset by specifying optional arguments for filte |
| libraries | get_library_permissions | R | Get the permissions for a library |
| libraries | set_dataset_permissions | W | Set the permissions for a dataset. Note: it will override all security for this  |
| libraries | set_library_permissions | W | Set the permissions for a library. Note: it will override all security for this  |
| libraries | show_dataset | R | Get details about a given library dataset. The required ``library_id`` can be ob |
| libraries | show_folder | R | Get details about a given folder. The required ``folder_id`` can be obtained fro |
| libraries | show_library | R | Get information about a library |
| libraries | update_library_dataset | W | Update library dataset metadata. Some of the attributes that can be modified are |
| libraries | upload_file_contents | W | Upload pasted_content to a data library as a new file |
| libraries | upload_file_from_local_path | W | Read local file contents from file_local_path and upload data to a library |
| libraries | upload_file_from_server | W | Upload all files in the specified subdirectory of the Galaxy library import dire |
| libraries | upload_file_from_url | W | Upload a file to a library from a URL |
| libraries | upload_from_galaxy_filesystem | W | Upload a set of files already present on the filesystem of the Galaxy server to  |
| libraries | wait_for_dataset | R | Wait until the library dataset state is terminal ('ok', 'empty', 'error', 'disca |
| quotas | create_quota | A | Create a new quota |
| quotas | delete_quota | A | Delete a quota |
| quotas | get_quotas | A | Get a list of quotas |
| quotas | show_quota | A | Display information on a quota |
| quotas | undelete_quota | A | Undelete a quota |
| quotas | update_quota | A | Update an existing quota |
| roles | create_role | A | Create a new role |
| roles | get_roles | A | Displays a collection (list) of roles |
| roles | show_role | A | Display information on a single role |
| tool_data | delete_data_table | D | Delete an item from a data table |
| tool_data | get_data_tables | R | Get the list of all data tables |
| tool_data | reload_data_table | W | Reload a data table |
| tool_data | show_data_table | R | Get details of a given data table |
| tool_dependencies | summarize_toolbox | W | Summarize requirements across toolbox (for Tool Management grid) |
| toolshed_categories | get_categories | R | Returns a list of dictionaries that contain descriptions of the repository categ |
| toolshed_categories | show_category | R | Get details of a given category |
| toolshed | get_repositories | R | Get the list of all installed Tool Shed repositories on this Galaxy instance |
| toolshed | install_repository_revision | W | Install a specified repository revision from a specified Tool Shed into this Gal |
| toolshed | show_repository | R | Get details of a given Tool Shed repository as it is installed on this Galaxy in |
| toolshed | uninstall_repository_revision | D | Uninstalls a specified repository revision from this Galaxy instance |
| toolShed | get_repositories | R | Get the list of all installed Tool Shed repositories on this Galaxy instance |
| toolShed | install_repository_revision | W | Install a specified repository revision from a specified Tool Shed into this Gal |
| toolShed | show_repository | R | Get details of a given Tool Shed repository as it is installed on this Galaxy in |
| toolShed | uninstall_repository_revision | D | Uninstalls a specified repository revision from this Galaxy instance |
| toolshed_repositories | create_repository | W | Create a new repository in a Tool Shed |
| toolshed_repositories | get_ordered_installable_revisions | R | Returns the ordered list of changeset revision hash strings that are associated  |
| toolshed_repositories | get_repositories | R | Get a list of all the repositories in a Galaxy Tool Shed |
| toolshed_repositories | get_repository_revision_install_info | R | Return a list of dictionaries of metadata about a certain changeset revision for |
| toolshed_repositories | repository_revisions | W | Returns a (possibly filtered) list of dictionaries that include information abou |
| toolshed_repositories | search_repositories | R | Search for repositories in a Galaxy Tool Shed |
| toolshed_repositories | show_repository | R | Display information of a repository from Tool Shed |
| toolshed_repositories | show_repository_revision | R | Returns a dictionary that includes information about a specified repository revi |
| toolshed_repositories | update_repository | W | Update the contents of a Tool Shed repository with specified tar ball |
| toolshed_tools | search_tools | R | Search for tools in a Galaxy Tool Shed |
| tools | get_citations | R | Get BibTeX citations for a given tool ID |
| tools | get_tool_panel | R | Get a list of available tool elements in Galaxy's configured toolbox |
| tools | get_tools | R | Get all tools, or select a subset by specifying optional arguments for filtering |
| tools | install_dependencies | W | Install dependencies for a given tool via a resolver. This works only for Conda  |
| tools | paste_content | W | Upload a string to a new dataset in the history specified by ``history_id`` |
| tools | put_url | W | Upload a string to a new dataset in the history specified by ``history_id`` |
| tools | requirements | W | Return the resolver status for a specific tool. This functionality is available  |
| tools | run_tool | W | Runs tool specified by ``tool_id`` in history indicated by ``history_id`` with i |
| tools | show_tool | R | Get details of a given tool |
| tools | uninstall_dependencies | D | Uninstall dependencies for a given tool via a resolver. This works only for Cond |
| tools | upload_file | W | Upload the file specified by ``path`` to the history specified by ``history_id`` |
| tools | upload_from_ftp | W | Upload the file specified by ``path`` from the user's FTP directory to the histo |
| users | create_local_user | A | Create a new Galaxy local user |
| users | create_remote_user | A | Create a new Galaxy remote user |
| users | create_user_apikey | A | Create a new API key for a given user |
| users | delete_user | A | Delete a user |
| users | get_current_user | R | Display information about the user associated with this Galaxy connection |
| users | get_user_apikey | R | Get the current API key for a given user |
| users | get_users | A | Get a list of all registered users. If ``deleted`` is set to ``True``, get a lis |
| users | show_user | A | Display information about a user |
| users | update_user | A | Update user information. Some of the attributes that can be modified are documen |
| visual | get_visualizations | R | Get the list of all visualizations |
| visual | show_visualization | R | Get details of a given visualization |
| workflows | cancel_invocation | D | Cancel the scheduling of a workflow |
| workflows | delete_workflow | D | Delete a workflow identified by `workflow_id` |
| workflows | export_workflow_dict | R | Exports a workflow |
| workflows | export_workflow_to_local_path | R | Exports a workflow in JSON format to a given local path |
| workflows | extract_workflow_from_history | W | Extract a workflow from a history |
| workflows | get_invocations | R | Get a list containing all the workflow invocations corresponding to the specifie |
| workflows | get_workflow_inputs | R | Get a list of workflow input IDs that match the given label. If no input matches |
| workflows | get_workflows | R | Get all workflows, or select a subset by specifying optional arguments for filte |
| workflows | import_shared_workflow | W | Imports a new workflow from the shared published workflows |
| workflows | import_workflow_dict | W | Imports a new workflow given a dictionary representing a previously exported wor |
| workflows | import_workflow_from_local_path | W | Imports a new workflow given the path to a file containing a previously exported |
| workflows | invoke_workflow | W | Invoke the workflow identified by ``workflow_id``. This will cause a workflow to |
| workflows | refactor_workflow | W | Refactor workflow with given actions |
| workflows | run_invocation_step_action | W | nature of this action and what is expected will vary based on the the type of wo |
| workflows | run_workflow | W | Run the workflow identified by ``workflow_id`` |
| workflows | show_invocation | R | Get a workflow invocation object representing the scheduling of a workflow. This |
| workflows | show_invocation_step | R | See the details of a particular workflow invocation step |
| workflows | show_versions | R | Get versions for a workflow |
| workflows | show_workflow | R | Display information needed to run a workflow |
| workflows | update_workflow | W | Update a given workflow |
<!-- AUTO-GENERATED:END -->

## Common patterns

### Discover and run a tool

```bash
# Find tool by name
parsec tools get_tools --name "trimmomatic" | jq '.[] | {id, name}'

# Inspect tool inputs
parsec tools show_tool <TOOL_ID> | jq '.inputs[] | {name, type}'

# Create a history and run the tool
HID=$(parsec histories create_history --name "My Run" | jq -r '.id')
parsec tools upload_file --history_id $HID mydata.fastq
DID=$(parsec histories get_histories | jq -r '.[0].id')
parsec tools run_tool $HID <TOOL_ID> '{"input|src": "hda", "input|id": "'$DID'"}'

# Wait for job to finish
JID=$(parsec jobs get_jobs | jq -r '.[0].id')
parsec jobs wait_for_job $JID
```

### Invoke a workflow

```bash
# Find workflow
WID=$(parsec workflows get_workflows | jq -r '.[] | select(.name=="My WF") | .id')

# Inspect expected inputs
parsec workflows show_workflow $WID | jq '.inputs'

# Create target history and upload input
HID=$(parsec histories create_history --name "WF Output" | jq -r '.id')
parsec tools upload_file --history_id $HID input.fastq
DID=$(parsec histories show_history $HID | jq -r '.state_ids.ok[0]')

# Invoke (--inputs maps step index → dataset)
INVID=$(parsec workflows invoke_workflow $WID \
  --history_id $HID \
  --inputs '{"0": {"id": "'$DID'", "src": "hda"}}' | jq -r '.id')

# Monitor
parsec invocations wait_for_invocation $INVID
parsec invocations get_invocation_summary $INVID | jq '.states'
```

### Dataset upload and download

```bash
# Upload local file
parsec tools upload_file --history_id $HID myfile.txt | jq '.outputs[0].id'

# Upload from URL
parsec tools put_url --history_id $HID "https://example.com/data.gz"

# Download dataset
parsec datasets download_dataset $DID --file_path ./output.txt

# Inspect dataset (size, state, type)
parsec datasets show_dataset $DID | jq '{name, state, file_size, file_ext}'
```

## Error handling

| Error | Cause | Fix |
|-------|-------|-----|
| `401 Unauthorized` | API key invalid or expired | Re-run `parsec init` with a fresh key |
| `404 Not Found` | Wrong ID | Verify with `get_*` / `show_*` first |
| `Problem loading command utils` | Missing submodule | Run `pip install -e .` in parsec repo root |
| Empty result `[]` | Wrong instance or filter | Check `-g INSTANCE` and filter params |

## ID encoding

Galaxy uses encoded (opaque) IDs everywhere — never construct them manually.
Always retrieve IDs from `get_*` / `show_*` output and pass them to subsequent commands.
