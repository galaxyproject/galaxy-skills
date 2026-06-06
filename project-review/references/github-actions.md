# GitHub Actions review

The General-profile line *"Has relevant and updated GitHub Actions; workflows are zizmor-clean"* is checked with [zizmor](https://docs.zizmor.sh/), a static-analysis security linter for GitHub Actions workflows.

Language-agnostic: zizmor is a Rust tool that audits `.github/workflows/*`, action definitions, and `dependabot.yml`. It does not parse application source, so it applies to every Galaxy Project repo regardless of language (Python, JS/TS, Rust, docs-only).

## Running it

Running zizmor against the checkout **is part of the review** — base the verdict on its findings, not a visual scan of the YAML.

```bash
# one-off, no install (PyPI is just a distribution channel)
uvx zizmor .
```

Notes:
- Offline (default) audits need no credentials. Some audits are online (e.g. `known-vulnerable-actions`, `impostor-commit`) and need a GitHub token — `GH_TOKEN=$(gh auth token) uvx zizmor .` to include them. If no token is available, say so and report only the offline result.
- A separate concern from the per-repo lint is whether the repo *wires zizmor into its own CI* so workflow changes are linted on every push/PR. The exemplar is **galaxyproject/galaxy#22827**, which adds `.github/workflows/zizmor.yaml` and a root `zizmor.yml` config, then fixes everything it flagged. A fully clean verdict means both: zizmor passes *and* it runs in the project's CI.

## What a clean result looks like

The hardening zizmor pushes toward (all generic, not Galaxy-specific):

- Third-party actions pinned to a commit SHA with a `# vX.Y.Z` comment.
- Top-level `permissions: {}` (least-privilege token), widened only per-job where needed.
- `persist-credentials: false` on `actions/checkout` steps that don't need the token.
- No template injection of `${{ ... }}` into `run:` shell bodies.
- Dependabot cooldown configured.
- Genuine false positives suppressed inline with `# zizmor: ignore[<rule>]` (and ideally a reason).

## Ties into the publishing line

zizmor's `use-trusted-publishing` audit flags publish workflows that use manual API tokens where OIDC trusted publishing is available — so a clean zizmor run also gives evidence for the General publishing line, not just this one.
