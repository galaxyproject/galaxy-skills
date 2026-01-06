# Commit Message Templates

## Version Update
```
Update {tool_name} to {new_version}

- Update version {old_version} → {new_version}
- {Any bug fixes}
- {Any other changes}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Version Update with Bug Fixes
```
Update {tool_name} to {new_version}, fix bugs

- Update version {old_version} → {new_version}
- Fix {bug 1 description}
- Fix {bug 2 description}
- Improve help section

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Bug Fix Only
```
Fix {brief description} in {tool_name}

- {Detailed fix description}
- {Impact or reason}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Documentation Update
```
Improve {tool_name} help documentation

- Expand help section with detailed usage
- Add examples
- Document all options

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Test Updates
```
Update {tool_name} tests for reliability

- Use flexible assertions for variable upstream data
- Add test for {new feature}
- Fix flaky test {description}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Example: NCBI Datasets Update
```
Update ncbi-datasets-cli to 18.13.0, fix bugs, improve help

- Update version 18.5.1 → 18.13.0
- Fix --search flag: access $search_term.search inside repeat
- Fix 3' UTR filter: was incorrectly checking for 5p-utr
- Fix typo: "amnio acid" → "amino acid"
- Expand help sections with detailed documentation
- Add test for --search parameter
- Use flexible assertions (min) for NCBI data that changes

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Git Commands

### Stage and Commit
```bash
git add tools/{tool_name}/
git commit -m "$(cat <<'EOF'
Update {tool_name} to {version}

- Change 1
- Change 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### Push
```bash
git push origin {branch_name}
```

### Create PR (GitHub CLI)
```bash
gh pr create --title "Update {tool_name} to {version}" --body "$(cat <<'EOF'
## Summary
- Update to version X.Y.Z
- Fix bugs
- Improve documentation

## Test plan
- [ ] planemo test passes
- [ ] Manual testing on Galaxy instance

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```
