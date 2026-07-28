# GitHub Actions review and hardening

Use [zizmor](https://docs.zizmor.sh/) as a security checker, then perform a manual
trust-boundary review. Passing zizmor is necessary evidence, not the design goal.

Zizmor audits workflows, local action definitions, and related configuration. It does not know
whether a write token is held longer than necessary, whether a deploy action can accept an
artifact from an unprivileged build job, or whether an opaque SHA is reviewable under the
project's maintenance policy.

## Establish the baseline

Run the checkout before editing:

```bash
uvx zizmor .
```

Offline audits need no credentials. Online audits such as `known-vulnerable-actions` and
`impostor-commit` need a GitHub token:

```bash
GH_TOKEN="$(gh auth token)" uvx zizmor .
```

If online checks are unavailable, report that limit. Record findings before changing files so
the final report can distinguish fixed findings from policy suppressions.

## Review decisions zizmor cannot make

### Action references are a repository policy

Do not automatically replace tags with commit hashes. Galaxy projects may choose the
`ref-pin` policy:

```yaml
rules:
  unpinned-uses:
    config:
      policies:
        '*': ref-pin
```

This accepts release or major-version refs and keeps updates reviewable. A bare SHA can point
to a commit from a non-merged fork, so a careful reviewer must verify that it is the commit
behind the claimed upstream tag. If a repository requires SHA pins, verify that mapping and
retain the release tag in a comment. Otherwise follow the repository's accepted ref policy
and use Dependabot to keep refs current.

Before selecting a new action major, inspect its official `action.yml` and release notes.
Check `runs.using`, required permissions, input changes, and whether the chosen ref is an
official upstream release. For a composite action, recursively inspect its nested `uses:`
steps: the composite itself has no JavaScript runtime, but a nested action may still run on a
deprecated Node.js version.

### Scope token lifetime to the privileged job

Start workflows with:

```yaml
permissions: {}
```

Grant only the permissions a job needs. More importantly, keep write and OIDC permissions out
of build and test steps. When a deploy or publish action needs write access:

1. build and validate in an unprivileged job;
2. upload the exact artifact;
3. download it in a dependent deploy/publish job; and
4. grant write or `id-token: write` only to that job.

Do not widen a combined build-and-deploy job merely to satisfy its final step. Preserve
artifact names, paths, retention needs, and release semantics when splitting jobs.

### Do not persist checkout credentials by default

Set `persist-credentials: false` when later steps do not need the checkout token. A deploy
action may authenticate with its own token and still permit this setting. Keep credentials
only when a verified step must use the configured Git remote, and document that reason.

### Keep untrusted values out of shell source

Do not interpolate event or matrix expressions directly into `run:` scripts when their value
can be attacker-controlled. Pass values through `env`, quote shell expansions, and prefer
action inputs over generated shell. Suppress `template-injection` only after tracing the value
to a trusted source.

### Treat dangerous triggers as a threat model

Review `pull_request_target`, `workflow_run`, issue events, and reusable workflow inputs
manually. Confirm that untrusted pull-request code is never checked out and executed with
write permissions or secrets. An inline suppression must state why the trigger is safe.

### Maintain action dependencies without review noise

Configure GitHub Actions updates in `.github/dependabot.yml` with:

- a weekly schedule;
- one grouped `actions` update using `patterns: ['*']`; and
- a cooldown, commonly seven days.

Grouping keeps mutually compatible action updates together and reduces repetitive review.

## Wire zizmor into CI

Add a dedicated workflow only after the baseline is understood. It should:

- run on pull requests and pushes when workflow, local-action, Dependabot, or zizmor config
  files change;
- allow manual dispatch when useful;
- start with `permissions: {}`;
- grant `contents: read` and `security-events: write` only to the zizmor job when its action
  uploads SARIF;
- checkout with `persist-credentials: false`; and
- use an action ref accepted by the repository's pin policy.

Do not trigger an Actions-only linter on every source or documentation change. Include all
paths the linter actually evaluates, not only `.github/workflows/*`.

## Suppressions

Use `# zizmor: ignore[rule]` only for a confirmed false positive or accepted risk. Put the
reason next to the suppression and report it. Never add a blanket suppression merely to
produce a clean exit status.

## Completion evidence

Rerun offline and, when possible, online zizmor. Also validate YAML, inspect the diff for
permission changes, and exercise affected build/deploy commands. A clean result means:

- zizmor reports no unexplained findings;
- unprivileged and privileged phases have explicit boundaries;
- action refs follow a documented, reviewable policy;
- future action updates are maintained;
- the zizmor workflow covers every relevant configuration path; and
- publishing uses OIDC trusted publishing where the registry supports it.

The reviewer-derived examples are
[galaxyproject/galaxy#22827](https://github.com/galaxyproject/galaxy/pull/22827) and the
follow-up review in
[galaxyproject/gxformat2#223](https://github.com/galaxyproject/gxformat2/pull/223).
