# Researching Upstream Changes

## Purpose
Before updating a Galaxy tool, research what changed in the upstream CLI tool to identify breaking changes.

## Steps

### 1. Find Latest Version
Check conda-forge:
```
https://anaconda.org/conda-forge/{package_name}
```

### 2. Check Release Notes
GitHub releases:
```
https://github.com/{org}/{repo}/releases
```

Look for:
- CHANGELOG.md
- Release notes
- Migration guides

### 3. Compare CLI Help
If you have both versions available:
```bash
# Old version
tool_old --help > help_old.txt

# New version
tool_new --help > help_new.txt

diff help_old.txt help_new.txt
```

### 4. Search for Breaking Changes
Web search:
```
"{tool_name}" breaking changes {old_version} {new_version}
"{tool_name}" migration guide
"{tool_name}" deprecated flags
```

### 5. Check Issues
GitHub issues often document problems:
```
https://github.com/{org}/{repo}/issues?q=is:issue+breaking
```

## What to Look For

### Flag Changes
| Change Type | Impact | Action |
|------------|--------|--------|
| Renamed | Tool breaks | Update command section |
| Removed | Tool breaks | Remove from XML or make conditional |
| New required | Tool breaks | Add to command section |
| New optional | None | Consider adding to inputs |
| Default changed | Output changes | Update tests, maybe document |

### Output Changes
- Different file formats
- Changed column names in tabular output
- Different directory structure

### Behavior Changes
- Different error messages
- Changed exit codes
- Rate limiting changes

## Example: NCBI Datasets 18.5.1 → 18.13.0

Research performed:
1. Checked GitHub releases - sparse notes, mostly bug fixes
2. Checked conda-forge - confirmed 18.13.0 available
3. Compared documentation - all flags still valid
4. Found no breaking changes documented

Result: Safe to update, existing flags unchanged.
