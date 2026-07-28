---
name: project-review
description: Review or harden a Galaxy Project repository against project best practices, including README, license, CI and GitHub Actions security, publishing, and—where applicable—Python typing and documentation. Use for requests such as "review this project", "project review for a repository", "does this repository follow best practices", "run or add zizmor", or "harden these GitHub Actions".
---

# Galaxy Project Review

Review a repository against the most specific profile below. Inspect the repository's actual
build, deploy, and publishing flows before judging individual files.

Run available checkers and report their output, but do not treat a clean linter result as proof
of sound design or translate findings mechanically into edits. For GitHub Actions, read
`references/github-actions.md` before assessing or changing workflows.

## Profiles

Pick the most specific profile that applies. The **Standard Python** profile adds to
**General**.

### General (any project)

- README is current and relevant.
- License is current and consistent with repository policy.
- CI covers the project's actual format, lint, type, test, build, and package risks.
- GitHub Actions pass zizmor and a manual trust-boundary review.
- Published artifacts use trusted publishing where supported and document the release path.

### Standard Python (pulsar, planemo, gxformat2, ephemeris)

Apply all **General** criteria, plus:

- mypy is current, meaningful, and checked in CI.
- Sphinx documentation builds in CI and is published.

## Review workflow

1. Inventory languages, package managers, published artifacts, default branch, workflows,
   reusable workflows, composite actions, Dependabot configuration, and repository-local
   instructions.
2. Identify the commands contributors use locally. Check that CI invokes the same commands
   with locked or reproducible dependencies.
3. Run available repository checks. For Actions, run zizmor offline and online when
   credentials permit.
4. Trace privileged operations—publishing, Pages deployment, release creation, package
   upload—from untrusted inputs to the step holding write or OIDC permissions.
5. Distinguish:
   - tool finding;
   - confirmed security or maintenance defect;
   - repository-policy choice;
   - justified suppression; and
   - unverified assumption.
6. If asked only to review, stop with a report and focused recommendations.
7. If asked to implement, make the smallest coherent change, preserve working release
   semantics, run the affected workflows locally where possible, and rerun zizmor.

## Output

Emit one row per profile criterion:

- **pass** — verified by file, command, or workflow evidence;
- **needs work** — concrete defect with a focused correction;
- **partial** — useful mechanism exists but misses a named risk;
- **n/a** — criterion does not apply; or
- **unverified** — external setting, secret, or online audit could not be checked.

Cite paths, workflows, commands, or settings. For Actions, summarize both zizmor results and
the manual trust-boundary review. When implementing, list behavior-preserving decisions and
any repository settings that still require a maintainer.
