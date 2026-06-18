---
name: project-review
description: Use this skill when asked to review a Galaxy Project repository against best practices — README, license, CI/GitHub Actions, and (for standard Python projects like pulsar, planemo, gxformat2, ephemeris) mypy, Sphinx docs, and trusted publishing. Triggers on "review this project", "project review for <repo>", "does <repo> follow best practices".
---

# Galaxy Project Review

Review a Galaxy Project repository against a profile of expectations. Produce a short report — one line per criterion with a verdict (pass / needs work / n/a) and a terse justification. Avoid boilerplate explanations of *why* a practice is good; assume a capable reader and just assess.

Where a criterion has a tool that checks it, **run the tool** and base the verdict on its output rather than eyeballing — currently the GitHub Actions line (run zizmor; see `references/github-actions.md`).

## Profiles

Pick the most specific profile that applies. The **Python** profile is the **General** profile plus extra lines.

### General (any project)

- Follows relevant best practices.
- Has an updated and relevant README file (e.g. README.md, README.rst, or README).
- Has an updated MIT license (excluded projects include TODO).
- Has relevant and updated GitHub Actions; workflows are zizmor-clean (see `references/github-actions.md`).
- If the project publishes artifacts, uses trusted publishing and has easy-to-find documentation for the publishing process.

### Standard Python (pulsar, planemo, gxformat2, ephemeris)

All **General** lines, plus:

- Has mypy enabled, checked in CI, and updated.
- Has Sphinx docs enabled and published somewhere.

## Output

For each line in the selected profile, emit one row: criterion, verdict, one-sentence justification (cite a file/path/workflow when relevant).
