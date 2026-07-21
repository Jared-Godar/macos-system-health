# Changelog

All notable changes follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and releases use semantic versioning.

## [Unreleased]

### Added

- Governance: three agent-orchestration failures from 2026-07-21 are answered by
  standing rules on the surfaces that reach every session, and two artifact-timing
  collisions with the PR-only workflow are resolved (#76, #85, #92). `AGENTS.md`
  § Standing commitments gains four agent-safety commitments: **isolate agents; do
  not instruct them** (contain a subagent/workflow structurally with a `/tmp` clone or
  `isolation: 'worktree'`, never a prompt instruction; a clone suffices for review;
  stop-and-verify the surface if agents are already live; agent-authored commits carry
  a `Co-Authored-By: Claude <model>` trailer so a stray one is attributable — enforcing
  that is #89), **bounded fan-out, or do not launch** (integer ceiling + code-enforced
  cap + countable denominator, all known before launch; the agent type — not a script's
  cardinality — decides whether a ceiling exists, since `general-purpose`/`claude` carry
  the `Agent` tool; an unverifiable ceiling is reported as unbounded; review fleets
  default to a non-spawning agent type, named with its spawn capability at launch),
  **commit before launching agents** (including read-only runs), and **isolation must
  self-verify** (the first agent echoes its absolute working path; an unset target is a
  hard abort, never a fallback). All four are mirrored verbatim into the root
  `CLAUDE.md` safety net; both files' hard-coded non-negotiable counts are **deleted
  rather than bumped** (a number that cannot desync beats one kept in sync by hand), and
  the `AGENTS.md` enumeration names the four new rules. For #92, the continuity
  walkthrough's *awaiting-merge* refresh is redefined to **before the final commit on
  the branch**, so a filled walkthrough — not a blank form — lands on `main`; a
  deliberately-left-slot convention (`⟨… — resolved post-merge, deliberately left⟩`)
  distinguishes blank-on-purpose from abandoned, and the rule states the accepted trade
  (the PR number and CI check context stay unresolved rather than force-pushing a green
  branch and voiding its required-check receipt). The session-handoff destination
  contradiction is resolved by widening the PM authoring lane: the PM may now author
  under `artifacts/session-handoffs/` and `artifacts/walkthroughs/` as well as
  `artifacts/specs/` — untracked, committed by the next executor PR, `.gitignore`
  unchanged — so the handoff's named path is reachable without breaking the lane.
  Deferred and named: #95 (the wider `CLAUDE.md` mirroring gap, deliberately
  unscheduled), #89 (attribution enforcement), #74 (the independent contract review,
  unblocked by the fan-out rule and run after it), #93.
- Governance: "correctly labeled" becomes a checkable property instead of a
  judgment call (#54, #51). `.github/label-policy.json` is now the authoritative,
  machine-readable required-label matrix — AREA, PRIORITY, TYPE, EFFORT, STATUS
  always required, RISK additionally required for `type:feature`/`type:bug`,
  CONFIDENCE/HOUSEKEEPING optional — and a new `scripts/check-label-policy`
  evaluates a label set against it. Its policy logic is **pure and offline**
  (`--labels "type:feature,area:governance,…"`, no network, jq only), separated
  from a thin `--pr <n>` path that fetches a PR's labels (bounded retry, external
  failures reported as connectivity conditions, not policy defects) and feeds the
  same evaluator — the split is what lets the negative tests run without a token.
  `.github/workflows/label-policy-gate.yml` runs the gate on every PR
  (`opened`, `edited`, `synchronize`, `labeled`, `unlabeled`, `ready_for_review`),
  itemizing each missing category with its valid labels on failure and listing the
  satisfied categories on success. Four smoke tests bound the policy — the
  load-bearing one asserts a `type:feature` set with no `risk:*` **fails** (the
  exact class that slipped through before), plus `type:docs` without RISK passing,
  a missing always-required category naming itself, and a full feature set passing.
  `risk:low` (`Minimal or easily reversible impact`) is added to
  `.github/labels.json` and created on the live repository so a genuinely low-risk
  feature has a truthful label instead of an inflated `risk:medium`, ending `risk`
  as the schema's only two-valued ordinal. `scripts/check-label-policy` is added to
  the `scripts/check` executable-mode/lint set, and `CONTRIBUTING.md` gains a
  one-paragraph pointer to the policy file as the source of truth. Deliberately
  out of scope: relabeling the 7 currently-violating issues (#53), the human-facing
  selection guide (#52 → #78), deleting the 8 unschemed stock labels (#93), and
  adding the gate to branch protection (owed until one PR is observed green under it).
- Governance: `AGENTS.md` gains seven session-conduct standing commitments that
  previously lived only in PM agent memory and were unreachable by executor,
  cold-start, or cloud sessions — **answer the question asked**, **keep progress
  visible and name the blocker** (reconciled with the existing HOLD/GREEN LIGHT
  merge-signal wording rather than duplicating it), **quantify estimates and
  caveats**, **estimates are the maintainer's decision inputs, not arguments for
  a preference**, **never touch in-flight executor work**, **propose lane
  deviations and await approval** (with both the no-permission-needed and
  propose-and-wait lists), and **the lane fails in both directions** (#77). The
  same seven are mirrored verbatim into the root `CLAUDE.md` safety net
  alongside its four existing non-negotiables (eleven total), since none are
  repo-specific and redundancy across surfaces is the explicit design goal —
  `CLAUDE.md`'s opening paragraph is rewritten to say "eleven" instead of the
  stale "three," and both files now state which one is authoritative if they
  ever appear to disagree (`AGENTS.md`). `AGENTS.md`'s own cross-reference to
  `CLAUDE.md` under "How these rules reach every session" is updated to match.
- Governance: resolved a standing contradiction in `AGENTS.md`'s "Roles and the
  four gated actions" — the PM thread bullet both granted "verification work…
  is expected of the PM" and stated the PM "never commits, pushes, or edits
  code," and both readings had been relied on in practice. Replaced the single
  bullet with three: what the PM may do without asking (issue/label/milestone/
  board/comment work, authoring specs, agent memory, and **read-only**
  verification against **committed or pushed** state only), what it may never do
  without the maintainer's explicit per-instance approval (editing repo files
  outside `artifacts/specs/`, running tests/gates/`scripts/check`, any
  state-changing git command, launching agents or workflows, or touching an
  executor's **uncommitted** working state), and the grey area named explicitly
  — verifying committed/pushed state is core PM work, verifying uncommitted
  state never is (#77).
- Governance: a `.githooks/pre-push` guard makes a stale gate receipt impossible to
  push. It refuses a dirty working tree (so `scripts/check --all` reflects the
  committed state, not an uncommitted mix), runs the full gate on that committed
  state, and whitespace-checks every commit in the pushed range — not just the tip,
  which is all `git show --check HEAD` covers, so the `043163a`-red/`22c5c39`-green
  range that slipped through in PR #72 would now be refused. A missing required
  tool (`scripts/check` exit 69) or bad invocation (64) is refused as a
  setup/toolchain condition with its install remediation, not misreported as a
  code defect. `--no-verify` bypasses
  it for genuine emergencies, and `scripts/install-hooks` installs it alongside the
  existing `pre-commit` hook (the new hook is added to the `scripts/check` lint set).
  `AGENTS.md` gains the matching **"Receipts expire on the next mutation"** standing
  commitment — mutate → stage → commit → **then** gate → report — including the
  corollary that claims about another session's state are verified this turn, not
  carried forward (#73).
- Governance: restored `AGENTS.md` to full strength — the operating contract grew from
  9,130 bytes / 6 standing commitments to ~20,000 bytes / 14, porting every applicable
  standing rule from the `ecg_anomaly_detection` and `github-portfolio-modernization`
  baselines (do-what-is-written, session-handoff continuity, proactive walkthrough,
  outside-sandbox permission check, multi-surface promise persistence, governance-docs-
  negotiable, repository visibility & deletion hard rule, engineering discipline, and a
  cluster of PM-thread/operational memory rules), resolved the self-contradictory PM lane
  into one unambiguous statement, and documented the timestamped `artifacts/specs/` spec
  path as the immutability mechanism with `prompts/` frozen as the historical record.
  `artifacts/` is now tracked (removed from `.gitignore`) so specs/walkthroughs/handoffs
  are visible, the spec-immutability `PreToolUse` hook moved from gitignored
  `.claude/settings.local.json` into tracked `.claude/settings.json`, and root `CLAUDE.md`
  gained specs-are-immutable-after-handoff as a fourth non-negotiable (#70, #69, #68).
  A `.gitattributes` rule (`artifacts/** -whitespace`) exempts the now-tracked session
  artifacts from the whitespace check, since their markdown hard-line-breaks (trailing
  double-spaces) are intentional and would otherwise trip `git show --check` (#70, #69).
  The one-copy-paste-block rule in `AGENTS.md` was broadened from extracts/seeds to **every**
  executor relay (seeds, handoff extracts, mid-flight redirects, addenda), with self-detecting
  state headers and do-not lines first (#71).
- Governance: backward-facing audit of closed v1.0 work (`docs/audits/2026-07-21-closed-work-audit.md`)
  — reconstructs each in-scope closed issue's definition-of-done and verifies delivered work with
  pasted command receipts; verdicts (Satisfied/Partial) with follow-up issues #60 (#7 dry-run does
  not suppress brew/conda maintenance mutations), #61 (#11 timeout fires ~10x early and never reports
  the timed_out state), #62 (#23 branch protection strict flag), and #64 (smoke-test intermediate
  assertions are non-enforcing) for the confirmed gaps (#59).
- Governance: layered operating contract for agent sessions — a lean, authoritative
  `AGENTS.md` (standing commitments, roles and the four gated actions, canonical
  flow, model/effort sizing, definition of done, local environment) plus a thin
  auto-loaded root `CLAUDE.md` mirroring the three non-negotiables; the stale
  `docs/GOVERNANCE.md` was folded in and removed, `docs/PM-WORKFLOW.md` and
  `docs/README.md` now point to `AGENTS.md` as authoritative (#55).
- Docs: v1.0 acceptance criteria document with platform matrix and success metrics (#6).
- A recurring `full-history-scan.yml` CI workflow: runs the same
  `scripts/check --all` command (including the `gitleaks git` history scan)
  on a weekly schedule and via `workflow_dispatch`, independent of pushes or
  pull requests, so a newly published Gitleaks rule or a secret predating
  the current ruleset is caught on a recurring cadence rather than only on
  the next code change (#20).
- Log retention: configurable age/count-based cleanup via `SYSTEM_HEALTH_LOG_RETENTION_DAYS` and `SYSTEM_HEALTH_LOG_RETENTION_COUNT` environment variables in maintenance mode (#7).
- Backup snapshot retention: configurable age/count-based cleanup for `Brewfile-*` and `conda-base-*.yml` files via `SYSTEM_HEALTH_BACKUP_RETENTION_DAYS` and `SYSTEM_HEALTH_BACKUP_RETENTION_COUNT` in maintenance mode (#24).
- Dry-run mode for maintenance operations via `SYSTEM_HEALTH_DRY_RUN` environment variable; previews planned deletions without executing them (#7).
- Governance: GitHub Actions workflow to auto-add PRs to "macOS System Health Roadmap" project when they link tracked issues (#34).
- Docs: Project tracking workflow documentation in CONTRIBUTING.md (#35).
- Docs: Project tracking verification checklist in PR template (#36).
- Docs: Architecture Decision Record (ADR 0001) documenting report and maintenance boundaries (#9).
- Docs: PM workflow & governance documentation in `docs/PM-WORKFLOW.md` — artifact lifecycle, durable contracts, seed prompt pattern, and phase 1 lessons learned.
- Governance: Goldilocks label schema for GitHub Projects dashboarding and filtering — 28 labels across area, priority, type, effort, status, risk, confidence, and housekeeping categories; complete durable schema in `.github/labels.json` (#45).
- Per-tool enable/disable controls for Homebrew, Conda, and pip checks via configuration file at `~/.config/system-health/config.yaml` (#11).
- Configurable command timeout (default: 30 seconds) to prevent scheduled runs from hanging indefinitely; timed-out commands report clear state separate from other failures (#11).
- Four distinct command execution states: Skipped (tool disabled in config), Timed out (exceeded timeout), Warning (command succeeded with warnings), Failure (command failed) (#11).
- JSON output format via `--format json` flag in report mode; schema versioning (v1.0) enables future evolution; structured checks, warnings, and issues arrays with tool-level metadata; all private paths redacted; text output remains default and unchanged (#10).

### Changed

- Governance: Enable branch protection on main; require status checks before merge (#23).

### Fixed

- Governance/CI: the `quality` gate again verifies the committed executable bit of every file
  a user runs directly, and the repository is no longer half-pinned (#83, #84). **(1) Mode
  coverage (#83):** #81's interpreter pinning (`/bin/bash scripts/check --all`) removed the
  last incidental check of any script's exec bit, so a script committed `100644` would pass CI
  and only fail later, for a user running it from a fresh clone. `scripts/check` now asserts
  committed modes via `git ls-files -s` (the index — what a clone gets — not the working tree):
  `SHELL_FILES` is split into an explicit expected-executable list and a sourced list
  (`lib/cleanup.sh`, correctly `100644`), each defined once and consumed as their union by the
  syntax and ShellCheck passes. The assertion runs in both `--all` and `--staged`, fails before
  the expensive passes, and names the offending file with its exact fix
  (`git update-index --chmod=+x <file>`); the pre-commit hook now catches a mode regression at
  commit time. **(2) Half-pinned toolchain (#84):** `full-history-scan.yml` installed its
  toolchain through a rolling `brew install`, so after #81 the repo read as reproducible but
  was not. The pinned versions and their SHA-256s move to a single new home,
  `scripts/install-quality-tools` (`100755`, linted and mode-checked like the other scripts),
  called by both workflows with a tool-name subset: `lint.yml` pins all three, while the weekly
  scan pins `actionlint` + `shellcheck` and **deliberately floats `gitleaks`** — the weekly
  scan's mission is catching newly published rules, and a floating linter would only add
  authorless Monday-morning noise with no code change. The weekly scan keeps installing gitleaks
  via Homebrew (with the same bounded retry and external-condition messaging), which is why its
  `brew untap aws/tap` step stays live. #81's checksum-before-PATH fetch block is reused
  verbatim, not rewritten. `AGENTS.md` § "CI toolchain version contract" now names the single
  home, describes how the two workflows differ, and still points at #78 for the eventual move to
  `docs/governance/`.
- Governance/CI: the `quality` gate is now reproducible and demonstrably runs under the
  Bash version the project targets (#81). **(1) Unpinned toolchain:** `lint.yml` installed
  `actionlint`, `shellcheck`, and `gitleaks` via `brew install`, so every run got whatever
  Homebrew shipped that day and a green PR could go red overnight with no code change. They
  are now pinned to explicit versions (actionlint 1.7.12, shellcheck 0.11.0, gitleaks
  8.30.1), downloaded as `darwin_arm64` builds and verified by SHA-256 **before** being
  placed on `PATH`. The download is defensively coded: per-call `--connect-timeout` /
  `--max-time` bounds turn a stalled connection into a retryable failure, transient failures
  retry with exponential backoff, exhaustion fails with a bounded external/connectivity
  message rather than a raw curl error, and a checksum mismatch aborts immediately as a
  permanent error that is never retried; a `timeout-minutes` job cap backstops the rest. The
  "Remove unused third-party Homebrew tap" step is removed from `lint.yml` (added in
  `7713d83` only to smooth `brew install`, which `lint.yml` no longer runs) but retained in
  `full-history-scan.yml`, which still uses Homebrew. **(2) Unenforced Bash target:** a
  temporary CI diagnostic measured that `#!/usr/bin/env bash` resolves to `/bin/bash` 3.2.57
  on `macos-15` — so CI already tested Bash 3.2, but only *incidentally*, because the image
  ships no newer bash earlier on `PATH`. The gate now runs as `/bin/bash scripts/check
  --all`, and `scripts/check` threads `"$BASH"` through its `bash -n` and `tests/smoke.sh`
  calls, forcing every layer under 3.2 regardless of future `PATH` drift; a permanent
  workflow assertion fails loudly if `/bin/bash` is ever not 3.2.x. `actions/checkout` is
  SHA-pinned to `3d3c42e5…` (`# v7.0.1`), since a major-version tag is mutable. The same
  `/bin/bash` gate and SHA-pinned checkout are also applied to the weekly
  `full-history-scan.yml`; pinning that workflow's Homebrew toolchain is deferred to #84 (the
  weekly scan intentionally catches newly published rules). The target-version contract
  (Bash 3.2, the pinned versions, the recompute-SHA-on-bump rule, and the manual upgrade
  owner/cadence — no automation covers these three tools) is recorded in `AGENTS.md` § Local
  environment, which #78 may relocate to `docs/governance/`.
- Tests: `tests/smoke.sh` now enforces **every** assertion, not just each test's
  last statement. `run_test` invoked each test in an `if` condition, which
  suppressed `set -e` across the whole test body, so a failing intermediate
  `assert_contains` / `assert_not_contains` only exited the helper and the test's
  result was whatever its final statement returned — every non-final assertion was
  decorative. The assert helpers now raise a per-test failure flag that `run_test`
  checks at test end, so any failed assertion deterministically fails its test and
  the tally. A self-test (`test_harness_enforces_intermediate_assertions`) runs a
  deliberately-broken test through the harness and asserts it is reported `not ok`,
  guarding against regression (#64).
- Redaction: `redact_stream` no longer crashes and silently drops output lines
  when the captured Conda base path contains a newline. It passed the redaction
  needles via `awk -v`, which parses the value like a string literal and aborts
  with "newline in string" on an embedded newline; because the Conda base is
  captured with `2>&1`, any stderr from `conda info --base` made it multiline and
  corrupted every subsequently-redacted line (including maintenance dry-run
  previews). The needles are now passed through the environment (`ENVIRON`), which
  is read verbatim, so redaction can never crash regardless of needle content.
  Surfaced by the now-enforcing smoke test above (#64).
- Governance: the "Auto-add PR to Project" workflow no longer reports a false
  green when a PR is not actually boarded. It now authenticates with a
  `PROJECT_METADATA_TOKEN` classic PAT to reach the user-owned "macOS System
  Health Roadmap" project (Project #3) — which the default `GITHUB_TOKEN` cannot
  see — adds the PR, reads membership back, and **fails the check (non-zero
  exit)** if the secret is missing, the project cannot be resolved, or
  membership cannot be confirmed. The previous workflow warned-and-skipped on
  those paths and exited 0, so PRs could merge unboarded. Requires the
  maintainer to add the `PROJECT_METADATA_TOKEN` repository secret; until then
  the check correctly fails rather than false-passing (#57).
- Tooling: opening this repo in VS Code no longer raises a Python interpreter
  warning. A User-scope `python.defaultInterpreterPath` pointed at
  `${workspaceFolder}/.venv/bin/python`, which resolves in other repos but not
  here — this is a Bash-only project with no `.venv`. `.gitignore` now negates
  `.vscode/settings.json` (route A: fix the repository, not one machine — see
  #80), and a tracked `.vscode/settings.json` overrides the interpreter setting
  to `"python3"` (PATH-resolved, no hardcoded machine path), disables Python
  environment activation in terminals, maps the seven extensionless Bash
  scripts to `shellscript`, disables Markdown trailing-whitespace trimming to
  protect the intentional hard line breaks `.gitattributes` already exempts
  under `artifacts/**`, and pins line endings to `\n` (#80).

## [0.1.0] - 2026-06-30

### Added

- Safe report and explicit maintenance modes.
- Homebrew, Conda, pip, disk, backup, locking, and optional email checks.
- LaunchAgent scheduling and operational runbook.
- Automated linting, smoke tests, and secret scanning for local commits and CI.
- A public privacy- and security-focused publication checklist.

### Security

- Removed embedded recipient addresses, workstation paths, hardware serial collection, and secret-bearing notes.
- Restricted generated log and backup permissions with `umask 077`.
- Redacted home-directory and Conda-base paths from logged and emailed command output.
