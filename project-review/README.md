# Project Review Skill

Claude Code skill for reviewing Galaxy Project repositories against a profile of best-practice expectations and producing a short, one-line-per-criterion report.

## Quick Start

Point Claude at a repo: *"Review planemo against project best practices"* or *"project review for galaxyproject/gxformat2"*.

Claude picks a profile, assesses each criterion, and emits one row per line — verdict (pass / needs work / n/a) plus a terse justification citing the relevant file or workflow.

## Profiles

- **General** — any project. README, MIT license, GitHub Actions (zizmor-clean), and trusted publishing for projects that publish artifacts.
- **Standard Python** — General plus mypy-in-CI and Sphinx docs. Applies to `pulsar`, `planemo`, `gxformat2`, `ephemeris`.

The Python profile is a superset of General; pick the most specific one that fits.

## Files

- `SKILL.md` — the profiles and review criteria.
- `references/github-actions.md` — how the GitHub Actions line is checked with [zizmor](https://docs.zizmor.sh/), with `galaxyproject/galaxy#22827` as the exemplar.

## Installation

```bash
# Personal skills (all projects)
ln -s /path/to/project-review ~/.claude/skills/project-review

# Project skills (shared via git)
ln -s /path/to/project-review .claude/skills/project-review
```
