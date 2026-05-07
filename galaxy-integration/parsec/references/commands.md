# Parsec Command Index

Safety tags: **R** = read-only, **W** = write/create, **D** = destructive, **A** = admin-only

<!-- AUTO-GENERATED:START -->
### Read-only commands

| Group | Command | Description |
|-------|---------|-------------|
| config | get_config | Get a list of attributes about the Galaxy instance. More attributes will be pres |
| config | get_version | Get the current version of the Galaxy instance |
| dataset_collections | download_dataset_collection | Download a history dataset collection as an archive |
| dataset_collections | show_dataset_collection | Get details of a given dataset collection of the current user |
| dataset_collections | wait_for_dataset_collection | Wait until all or a specified proportion of elements of a dataset collection are |
| datasets | download_dataset | Download a dataset to file or in memory. If the dataset state is not 'ok', a ``D |
| datasets | get_datasets | Get the latest datasets, or select another subset by specifying optional argumen |
| datasets | show_dataset | Get details about a given dataset. This can be a history or a library dataset |
| datasets | wait_for_dataset | Wait until a dataset is in a terminal state |
| datatypes | get_datatypes | Get the list of all installed datatypes |
| datatypes | get_sniffers | Get the list of all installed sniffers |
| folders | get_permissions | Get the permissions of a folder |
| folders | show_folder | Display information about a folder |
| forms | get_forms | Get the list of all forms |
| forms | show_form | Get details of a given form |
| ftpfiles | get_ftp_files | Get a list of local files |
| genomes | get_genomes | Returns a list of installed genomes |
| genomes | show_genome | Returns information about build <id> |
| histories | download_history | Download a history export archive.  Use :meth:`export_history` to create an expo |
| histories | export_history | Start a job to create an export archive for the given history |
| histories | get_histories | Get all histories, or select a subset by specifying optional arguments for filte |
| histories | get_most_recently_used_history | Returns the current user's most recently used history (not deleted) |
| histories | get_published_histories | Get all published histories (by any user), or select a subset by specifying opti |
| histories | get_status | Returns the state of this history |
| histories | show_dataset | Get details about a given history dataset |
| histories | show_dataset_collection | Get details about a given history dataset collection |
| histories | show_dataset_provenance | Get details related to how dataset was created (``id``, ``job_id``, ``tool_id``, |
| histories | show_history | Get details of a given history. By default, just get the history meta informatio |
| histories | show_matching_datasets | Get dataset details for matching datasets within a history |
| invocations | get_invocation_biocompute_object | Get a BioCompute object for an invocation |
| invocations | get_invocation_report | Get a Markdown report for an invocation |
| invocations | get_invocation_report_pdf | Get a PDF report for an invocation |
| invocations | get_invocation_step_jobs_summary | Get a detailed summary of an invocation, listing all jobs with their job IDs and |
| invocations | get_invocation_summary | Get a summary of an invocation, stating the number of jobs which succeed, which  |
| invocations | get_invocations | Get all workflow invocations, or select a subset by specifying optional argument |
| invocations | show_invocation | Get a workflow invocation dictionary representing the scheduling of a workflow.  |
| invocations | show_invocation_step | See the details of a particular workflow invocation step |
| invocations | wait_for_invocation | Wait until an invocation is in a terminal state |
| jobs | get_common_problems | Query inputs and jobs for common potential problems that might have resulted in  |
| jobs | get_destination_params | Get destination parameters for a job, describing the environment and location wh |
| jobs | get_inputs | Get dataset inputs used by a job |
| jobs | get_jobs | Get all jobs, or select a subset by specifying optional arguments for filtering  |
| jobs | get_metrics | Return job metrics for a given job |
| jobs | get_outputs | Get dataset outputs produced by a job |
| jobs | get_state | Display the current state for a given job of the current user |
| jobs | search_jobs | Return jobs matching input parameters |
| jobs | show_job | Get details of a given job of the current user |
| jobs | show_job_lock | Show whether the job lock is active or not. If it is active, no jobs will dispat |
| jobs | wait_for_job | Wait until a job is in a terminal state |
| libraries | get_dataset_permissions | Get the permissions for a dataset |
| libraries | get_folders | Get all the folders in a library, or select a subset by specifying a folder name |
| libraries | get_libraries | Get all libraries, or select a subset by specifying optional arguments for filte |
| libraries | get_library_permissions | Get the permissions for a library |
| libraries | show_dataset | Get details about a given library dataset. The required ``library_id`` can be ob |
| libraries | show_folder | Get details about a given folder. The required ``folder_id`` can be obtained fro |
| libraries | show_library | Get information about a library |
| libraries | wait_for_dataset | Wait until the library dataset state is terminal ('ok', 'empty', 'error', 'disca |
| tool_data | get_data_tables | Get the list of all data tables |
| tool_data | show_data_table | Get details of a given data table |
| toolshed_categories | get_categories | Returns a list of dictionaries that contain descriptions of the repository categ |
| toolshed_categories | show_category | Get details of a given category |
| toolshed | get_repositories | Get the list of all installed Tool Shed repositories on this Galaxy instance |
| toolshed | show_repository | Get details of a given Tool Shed repository as it is installed on this Galaxy in |
| toolShed | get_repositories | Get the list of all installed Tool Shed repositories on this Galaxy instance |
| toolShed | show_repository | Get details of a given Tool Shed repository as it is installed on this Galaxy in |
| toolshed_repositories | get_ordered_installable_revisions | Returns the ordered list of changeset revision hash strings that are associated  |
| toolshed_repositories | get_repositories | Get a list of all the repositories in a Galaxy Tool Shed |
| toolshed_repositories | get_repository_revision_install_info | Return a list of dictionaries of metadata about a certain changeset revision for |
| toolshed_repositories | search_repositories | Search for repositories in a Galaxy Tool Shed |
| toolshed_repositories | show_repository | Display information of a repository from Tool Shed |
| toolshed_repositories | show_repository_revision | Returns a dictionary that includes information about a specified repository revi |
| toolshed_tools | search_tools | Search for tools in a Galaxy Tool Shed |
| tools | get_citations | Get BibTeX citations for a given tool ID |
| tools | get_tool_panel | Get a list of available tool elements in Galaxy's configured toolbox |
| tools | get_tools | Get all tools, or select a subset by specifying optional arguments for filtering |
| tools | show_tool | Get details of a given tool |
| users | get_current_user | Display information about the user associated with this Galaxy connection |
| users | get_user_apikey | Get the current API key for a given user |
| visual | get_visualizations | Get the list of all visualizations |
| visual | show_visualization | Get details of a given visualization |
| workflows | export_workflow_dict | Exports a workflow |
| workflows | export_workflow_to_local_path | Exports a workflow in JSON format to a given local path |
| workflows | get_invocations | Get a list containing all the workflow invocations corresponding to the specifie |
| workflows | get_workflow_inputs | Get a list of workflow input IDs that match the given label. If no input matches |
| workflows | get_workflows | Get all workflows, or select a subset by specifying optional arguments for filte |
| workflows | show_invocation | Get a workflow invocation object representing the scheduling of a workflow. This |
| workflows | show_invocation_step | See the details of a particular workflow invocation step |
| workflows | show_versions | Get versions for a workflow |
| workflows | show_workflow | Display information needed to run a workflow |

### Write/create commands

| Group | Command | Description |
|-------|---------|-------------|
| datasets | publish_dataset | Make a dataset publicly available or private. For more fine-grained control (ass |
| datasets | update_permissions | Set access, manage or modify permissions for a dataset to a list of roles |
| folders | create_folder | Create a folder |
| folders | set_permissions | Set the permissions of a folder |
| folders | update_folder | Update folder information |
| forms | create_form | Create a new form |
| genomes | install_genome | Download and/or index a genome |
| histories | copy_content | Copy existing content (e.g. a dataset) to a history |
| histories | copy_dataset | Copy a dataset to a history |
| histories | create_dataset_collection | Create a new dataset collection |
| histories | create_history | Create a new history, optionally setting the ``name`` |
| histories | create_history_tag | Create history tag |
| histories | import_history | Import a history from an archive on disk or a URL |
| histories | open_history | Open Galaxy in a new tab of the default web browser and switch to the specified  |
| histories | undelete_history | Undelete a history |
| histories | update_dataset | Update history dataset metadata. Some of the attributes that can be modified are |
| histories | update_dataset_collection | Update history dataset collection metadata. Some of the attributes that can be m |
| histories | update_history | Update history metadata information. Some of the attributes that can be modified |
| histories | upload_dataset_from_library | Upload a dataset into the history from a library. Requires the library dataset I |
| init | init | Help initialize global configuration (in home directory) |
| invocations | rerun_invocation | Rerun a workflow invocation. For more extensive documentation of all parameters, |
| invocations | run_invocation_step_action | nature of this action and what is expected will vary based on the the type of wo |
| jobs | report_error | Report an error for a given job and dataset to the server administrators |
| jobs | rerun_job | Rerun a job |
| jobs | resume_job | Resume a job if it is paused |
| libraries | copy_from_dataset | Copy a Galaxy dataset into a library |
| libraries | create_folder | Create a folder in a library |
| libraries | create_library | Create a data library with the properties defined in the arguments |
| libraries | set_dataset_permissions | Set the permissions for a dataset. Note: it will override all security for this  |
| libraries | set_library_permissions | Set the permissions for a library. Note: it will override all security for this  |
| libraries | update_library_dataset | Update library dataset metadata. Some of the attributes that can be modified are |
| libraries | upload_file_contents | Upload pasted_content to a data library as a new file |
| libraries | upload_file_from_local_path | Read local file contents from file_local_path and upload data to a library |
| libraries | upload_file_from_server | Upload all files in the specified subdirectory of the Galaxy library import dire |
| libraries | upload_file_from_url | Upload a file to a library from a URL |
| libraries | upload_from_galaxy_filesystem | Upload a set of files already present on the filesystem of the Galaxy server to  |
| tool_data | reload_data_table | Reload a data table |
| tool_dependencies | summarize_toolbox | Summarize requirements across toolbox (for Tool Management grid) |
| toolshed | install_repository_revision | Install a specified repository revision from a specified Tool Shed into this Gal |
| toolShed | install_repository_revision | Install a specified repository revision from a specified Tool Shed into this Gal |
| toolshed_repositories | create_repository | Create a new repository in a Tool Shed |
| toolshed_repositories | repository_revisions | Returns a (possibly filtered) list of dictionaries that include information abou |
| toolshed_repositories | update_repository | Update the contents of a Tool Shed repository with specified tar ball |
| tools | install_dependencies | Install dependencies for a given tool via a resolver. This works only for Conda  |
| tools | paste_content | Upload a string to a new dataset in the history specified by ``history_id`` |
| tools | put_url | Upload a string to a new dataset in the history specified by ``history_id`` |
| tools | requirements | Return the resolver status for a specific tool. This functionality is available  |
| tools | run_tool | Runs tool specified by ``tool_id`` in history indicated by ``history_id`` with i |
| tools | upload_file | Upload the file specified by ``path`` to the history specified by ``history_id`` |
| tools | upload_from_ftp | Upload the file specified by ``path`` from the user's FTP directory to the histo |
| workflows | extract_workflow_from_history | Extract a workflow from a history |
| workflows | import_shared_workflow | Imports a new workflow from the shared published workflows |
| workflows | import_workflow_dict | Imports a new workflow given a dictionary representing a previously exported wor |
| workflows | import_workflow_from_local_path | Imports a new workflow given the path to a file containing a previously exported |
| workflows | invoke_workflow | Invoke the workflow identified by ``workflow_id``. This will cause a workflow to |
| workflows | refactor_workflow | Refactor workflow with given actions |
| workflows | run_invocation_step_action | nature of this action and what is expected will vary based on the the type of wo |
| workflows | run_workflow | Run the workflow identified by ``workflow_id`` |
| workflows | update_workflow | Update a given workflow |

### Destructive commands

| Group | Command | Description |
|-------|---------|-------------|
| folders | delete_folder | Marks the folder with the given ``id`` as `deleted` (or removes the `deleted` ma |
| histories | delete_dataset | Mark corresponding dataset as deleted |
| histories | delete_dataset_collection | Mark corresponding dataset collection as deleted |
| histories | delete_history | Delete a history |
| invocations | cancel_invocation | Cancel the scheduling of a workflow |
| jobs | cancel_job | Cancel a job, deleting output datasets |
| libraries | delete_library | Delete a data library |
| libraries | delete_library_dataset | Delete a library dataset in a data library |
| tool_data | delete_data_table | Delete an item from a data table |
| toolshed | uninstall_repository_revision | Uninstalls a specified repository revision from this Galaxy instance |
| toolShed | uninstall_repository_revision | Uninstalls a specified repository revision from this Galaxy instance |
| tools | uninstall_dependencies | Uninstall dependencies for a given tool via a resolver. This works only for Cond |
| workflows | cancel_invocation | Cancel the scheduling of a workflow |
| workflows | delete_workflow | Delete a workflow identified by `workflow_id` |

### Admin-only commands

| Group | Command | Description |
|-------|---------|-------------|
| groups | add_group_role | Add a role to the given group |
| groups | add_group_user | Add a user to the given group |
| groups | create_group | Create a new group |
| groups | delete_group_role | Remove a role from the given group |
| groups | delete_group_user | Remove a user from the given group |
| groups | get_group_roles | Get the list of roles associated to the given group |
| groups | get_group_users | Get the list of users associated to the given group |
| groups | get_groups | Get all (not deleted) groups |
| groups | show_group | Get details of a given group |
| groups | update_group | Update a group |
| jobs | update_job_lock | Update the job lock status by setting ``active`` to either ``True`` or ``False`` |
| quotas | create_quota | Create a new quota |
| quotas | delete_quota | Delete a quota |
| quotas | get_quotas | Get a list of quotas |
| quotas | show_quota | Display information on a quota |
| quotas | undelete_quota | Undelete a quota |
| quotas | update_quota | Update an existing quota |
| roles | create_role | Create a new role |
| roles | get_roles | Displays a collection (list) of roles |
| roles | show_role | Display information on a single role |
| users | create_local_user | Create a new Galaxy local user |
| users | create_remote_user | Create a new Galaxy remote user |
| users | create_user_apikey | Create a new API key for a given user |
| users | delete_user | Delete a user |
| users | get_users | Get a list of all registered users. If ``deleted`` is set to ``True``, get a lis |
| users | show_user | Display information about a user |
| users | update_user | Update user information. Some of the attributes that can be modified are documen |
<!-- AUTO-GENERATED:END -->
