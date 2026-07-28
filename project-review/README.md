# Project Review Skill

Agent skill for reviewing or hardening Galaxy Project repositories against a profile of
best-practice expectations.

## Quick Start

Point an agent at a repository: *"Review planemo against project best practices"*,
*"project review for galaxyproject/gxformat2"*, or *"harden these GitHub Actions"*.

The agent inventories the project, runs available checks, reviews trust boundaries, and emits
one row per criterion with a verdict and cited evidence. When implementation is requested, it
makes the smallest coherent change and validates the result.

## Profiles

- **General** — any project. README, license, CI coverage, GitHub Actions (zizmor plus manual
  trust-boundary review), and trusted publishing for projects that publish artifacts.
- **Standard Python** — General plus mypy-in-CI and Sphinx docs. Applies to `pulsar`, `planemo`, `gxformat2`, `ephemeris`.

The Python profile is a superset of General; pick the most specific one that fits.

## Files

- `SKILL.md` — the profiles and review criteria.
- `references/github-actions.md` — how to combine
  [zizmor](https://docs.zizmor.sh/) with action-ref policy, least privilege, job-boundary,
  trigger, credential, maintenance, and publishing review. It incorporates lessons from
  `galaxyproject/galaxy#22827` and `galaxyproject/gxformat2#223`.

## Installation

```bash
# Personal skills (all projects)
ln -s /path/to/project-review ~/.claude/skills/project-review

# Project skills (shared via git)
ln -s /path/to/project-review .claude/skills/project-review
```
