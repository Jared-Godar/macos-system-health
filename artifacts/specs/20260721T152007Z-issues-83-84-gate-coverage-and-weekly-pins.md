# Spec: Restore committed-mode coverage to the gate, and end the half-pinned toolchain (#83, #84)

**Closes:** #83, #84 · **Milestone:** none — **deliberate**: both issues are #81 hygiene
follow-ups, filed unmilestoned on purpose. Do not add one; state the omission in the PR body.
**Labels:** `type:bug`, `area:governance`, `priority:medium`, `effort:medium`, `status:ready`,
`risk:medium` — all six verified present in `.github/labels.json` (PM-verified 2026-07-21T15:20Z).
**Assignee:** Jared-Godar · **Project:** macOS System Health Roadmap (PRs are auto-boarded)
**Sizing:** `--model opus --effort high` — Heavy. #84 exists to *make a design decision*, not to
apply one, and both issues change the gate that every future PR depends on.

> **PLACEMENT NOTE — read first.** This spec is already at its canonical path,
> `artifacts/specs/20260721T152007Z-issues-83-84-gate-coverage-and-weekly-pins.md`, untracked on
> `main`. **Do not copy or move it.** It follows you onto your branch and you commit it with your PR.

---

## 0. Read the durable contracts first (non-negotiable)

Before writing anything, read and follow, in order:

1. **`AGENTS.md` on `main`** — the binding contract, 22 standing commitments as of `f21a6d2`.
   Pay particular attention to § **"CI toolchain version contract (Issue #81)"** — this PR edits it.
2. `CLAUDE.md` at the repo root — 11 mirrored non-negotiables.
3. `~/.claude/CLAUDE.md` — the maintainer's cross-project standing rules.
4. `CONTRIBUTING.md`.
5. **Issues #83 and #84 in full** — including #84 §4 and §5, which frame the two decisions you own.

**The rules that will bite you on this specific task:**

- **Four gated actions need the maintainer's explicit per-instance go-ahead: push, open PR, merge,
  release-tag.** This task stops twice: before pushing (§5 Step 6) and before opening the PR
  (§5 Step 8). Ask, wait, then proceed. **Never merge.**
- **Receipts expire on the next mutation.** This task contains a deliberate index mutation — the
  negative test in Step 4 runs `git update-index --chmod=-x`. **That voids every prior receipt.**
  The order is: negative test → restore → verify restored → `git add` → commit → **then** gate →
  report. Never gate before the final commit.
- **Never weaken a test to make it pass.** If the new mode assertion fires on something you did not
  expect, that is a finding to investigate and report — not an entry to delete from the list.
- **No contract-lawyering.** A criterion that cannot be met is a **finding to report, never a
  criterion to drop**. §7 is numbered; report against those numbers, do not invent your own.
- **Disclose every omission.** Both design decisions (§3 D4, D5) must be recorded with reasoning in
  the PR body even where you adopt this spec's recommendation unchanged.
- **Specs are immutable after handoff.** This file is read-only to you. If it is wrong, say so in a
  checkpoint and let the PM issue a new timestamped file.
- **Always pass `-R Jared-Godar/macos-system-health`** on every `gh` write.

## 0b. Progress tracking (hard requirement)

Call **TodoWrite immediately after reading this spec, before any other tool call**, seeding it with
one item per §5 step plus one per §7 acceptance criterion (AC1–AC14). Keep exactly one item
`in_progress`; mark items `completed` as you finish them; refresh at **every step boundary**. Before
any long-running command, post a one-line "next I am doing X."

If TodoWrite is unavailable, say so once, then re-post the full checklist as inline markdown with
`[x]` / `[~]` / `[ ]` at the top of every response that starts or finishes a step. Do not let more
than one tool batch pass without a refreshed checklist.

---

## 1. Intended outcome

Two gaps that #81 either created or left behind are closed:

- The gate verifies the **committed executable bits** of every file a user is expected to run — a
  coverage that used to exist incidentally and, after #81's interpreter pinning, exists nowhere.
- The repository stops being **half-pinned**. Either both workflows share one pinned toolchain
  definition, or the difference between them is a recorded, reasoned decision rather than an
  oversight — and `AGENTS.md` says which, in one place.

## 2. Current state — surveyed, not assumed

Everything below was verified by the PM against `main` at `f21a6d2` on 2026-07-21T15:1x Z. Where a
figure is unverified, it says so.

### 2a. Executable modes — the complete class, not the named list

`git ls-files -s` over the whole repository, not just `SHELL_FILES`:

```
100755 .githooks/pre-commit      100755 bin/system-health      100755 tests/smoke.sh
100755 .githooks/pre-push        100755 scripts/check
100755 bin/configure-email       100755 scripts/install-hooks
100755 bin/install-schedule
100644 lib/cleanup.sh            <- correct; sourced, never executed
```

Three facts that constrain the implementation:

1. **Exactly eight tracked files are `100755`**, and that set is exactly `SHELL_FILES` minus
   `lib/cleanup.sh`. No executable file exists outside the array today. `#83`'s current-state block
   is accurate.
2. **A shebang is not a usable discriminator.** `lib/cleanup.sh` carries `#!/usr/bin/env bash` and is
   correctly non-executable. Every tracked shell file in the repo has a shebang, including the one
   that must stay `100644`. **Do not implement this by detecting shebangs** — the expected-executable
   list must be explicit.
3. `scripts/check`'s `SHELL_FILES` is a literal array with **no globbing**, so nothing is covered by
   living in a particular directory. This matters for #84 — see §2c.

Current coverage: `scripts/check`'s own bit and `tests/smoke.sh`'s bit were exercised *incidentally*
until #81; after #81 both are invoked through an explicit interpreter, so **no file's mode is
verified by anything in CI**. The other six never were.

### 2b. The two workflows that run the gate

Surveyed by grep across all of `.github/workflows/` — there are three workflow files plus
Dependabot/CodeQL; **two** of them run `scripts/check --all`:

| File | Trigger | Toolchain install | Runs |
| --- | --- | --- | --- |
| `lint.yml` (job key `checks`) | push, pull_request | pinned + SHA-256 verified (#81) | `/bin/bash scripts/check --all` |
| `full-history-scan.yml` | weekly cron + `workflow_dispatch` | `brew install actionlint shellcheck gitleaks` with bounded retry | `/bin/bash scripts/check --all` |

`full-history-scan.yml` also carries a **`Remove unused third-party Homebrew tap`** step
(`brew untap aws/tap`). It exists only because that job uses Homebrew — `AGENTS.md` links the two
explicitly ("which is also why its Homebrew tap-cleanup step is still live"). It is in scope for a
decision (§3 D5), not for a silent keep or a silent delete.

### 2c. The correction that makes these two issues one PR

**#84 §4 option 2 contains a factual error you must not inherit.** It says extracting the installer
to `scripts/install-quality-tools` means "the script is covered by `scripts/check`'s existing
ShellCheck pass since it lands under `scripts/`." That is **false**: `SHELL_FILES` is an explicit
array, so a new script under `scripts/` is linted only if it is **added to that array**.

That array is precisely what #83 restructures. Landing #83 and #84 separately means touching the same
seven lines of `scripts/check` twice, in two PRs, with a window in between where a new installer
script is unlinted. **This shared surface is the reason the two issues ship together.** Say so in the
PR body.

### 2d. Receipt that #81's fetch block works

The pinned-install block in `lint.yml` (lines 15–94) is green on `main` at `f21a6d2` — workflow run
[`29841866289`](https://github.com/Jared-Godar/macos-system-health/actions/runs/29841866289),
conclusion `success`, 2026-07-21T15:00:19Z, with the pins in effect. **Reuse that block; do not
rewrite it.** Its retry/backoff, permanent-vs-transient classification, checksum-before-PATH ordering,
and `::error::` messages are an existing, CI-proven implementation of `AGENTS.md`'s defensive
external-call rule.

## 3. Deliverables

**D1 — Committed-mode assertion in `scripts/check` (#83).** Assert index modes with
`git ls-files -s`, not the working tree: what is committed is what a user clones. Requires splitting
`SHELL_FILES` into an expected-executable list and a sourced list, with **one** definition of each
and the lint/syntax passes consuming their union. Must be Bash **3.2**-safe — no `mapfile`, no
`declare -A`, no `${v^^}`, no namerefs; CI now syntax-checks under 3.2 and will catch you.

**D2 — A failure message that resolves itself.** On mismatch, name the offending file and print the
exact fix, `git update-index --chmod=+x <file>`. Fail before the expensive passes so the signal is
immediate.

**D3 — Both gate modes.** The assertion must run under `--all` and `--staged`. `git ls-files -s`
reads the **index**, so a `git update-index --chmod=+x` fix is picked up without committing, and the
pre-commit hook catches a mode regression at commit time.

**D4 — Decide, per tool, whether the weekly scan is pinned (#84 §5), and record it.**
This is the decision the issue exists to make; do not apply #81's answer by reflex.

> **PM's recommendation, which you may override with reasoning:** pin `actionlint` and `shellcheck`,
> deliberately **float `gitleaks`**. Rationale: the weekly scan's purpose is catching rules that did
> not exist when the code was written, so a floating Gitleaks is the mission, while a floating
> linter is pure noise — an actionlint or ShellCheck default-check change turns a Monday-morning
> scheduled run red with no code change and no author attached. This is the "defensible outcome"
> #84 §5 names, and it is consistent with the reasoning already recorded in `AGENTS.md`.
> **Constraint this imposes:** whatever mechanism you build must support installing a **subset** of
> the tools, not all-or-nothing.

**D5 — Decide the mechanism (#84 §4), and the tap-cleanup step with it.**
PM's lead is **option 2** — extract to `scripts/install-quality-tools`, called by both workflows, so
the pins have exactly one home. Option 1 (duplicate) contradicts #81's "no competing second home";
option 3 (composite action) is more machinery than two call sites justify. Override with reasoning
if you disagree. Whatever you choose:

- The pinned versions and their SHA-256s exist in **exactly one file**.
- The bounded-retry and external-condition messaging survives in whatever replaces the `brew` block.
- If any tool still comes from Homebrew, the `brew untap aws/tap` step **stays**; if none does, state
  whether it is now vestigial and remove it deliberately. Either way it is a recorded decision.
- If you create `scripts/install-quality-tools`: it is `100755`, it is added to the linted file list
  from D1, and it is invoked as `/bin/bash scripts/install-quality-tools …` for the same
  one-interpreter reason #81 gives.

**D6 — Update `AGENTS.md` § "CI toolchain version contract (Issue #81)"** so it names the new home
and states plainly how the two workflows differ. Its current text says the pins are "installed in
`.github/workflows/lint.yml`" and that the weekly scan's toolchain "is still installed with
`brew install` (unpinned) on purpose"; both statements change. **Keep the closing "One home, not two"
note pointing at #78** — #78 will relocate this whole section to `docs/governance/` later, and it is
currently on hold. Do **not** create a second home for the contract now.

**D7 — CHANGELOG** entry under `## [Unreleased]`.

## 4. Non-goals

- **Not touching `lint.yml`'s job key `checks`.** It is a required branch-protection context with no
  job-level `name:`; renaming it blocks every future PR indefinitely. Editing the job's *steps* is
  fine and expected.
- Not changing the weekly schedule, `fetch-depth: 0`, `runs-on: macos-15`, or what the scan runs.
- Not changing which files are executable, and not checking working-tree permissions — committed
  modes only.
- Not bumping any tool version. This PR relocates and extends pinning; version bumps are a separate,
  deliberate act per the contract's bump procedure.
- Not touching `bin/`, `lib/`, or `tests/` behavior.

## 5. Execution rails

Fish syntax, from the repo root. Each step is followed by its verification.

### Step 1 — Sync and branch

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git log --oneline -1; git status --short
git switch -c fix/issues-83-84-gate-coverage-and-weekly-pins
git status --short artifacts/specs/
```

Expected: `main` at `f21a6d2` or later; the only untracked file is this spec. It is already in
place — do not copy it.

### Step 2 — Write the continuity walkthrough (immediately after branching)

`AGENTS.md` requires it now, not at the end:
`artifacts/walkthroughs/<UTC-timestamp>-issues-83-84-gate-coverage-and-weekly-pins.md`, Fish rails
with `⟨slots⟩` for values you do not have yet. Refresh it at **PR opened** and **awaiting merge**.

### Step 3 — Implement D1–D3 in `scripts/check`

Then confirm the happy path still passes before you try to break it:

```fish
/bin/bash scripts/check --all; echo "gate exit=$status"
```

Expected `exit=0`. (Use `/bin/bash` explicitly — that is what CI runs; a PATH-resolved `bash` may be
5.x and will not catch 3.2 violations.)

### Step 4 — Negative test (this is AC1's evidence; it mutates the index)

**PM-unverified — these three commands were not executed by the PM** (running the gate and mutating
the index are outside the PM lane). Verify the behaviour yourself and paste the real output.

```fish
git update-index --chmod=-x bin/system-health
git ls-files -s bin/system-health
/bin/bash scripts/check --all; echo "gate exit=$status (expect NON-zero)"
git update-index --chmod=+x bin/system-health
git ls-files -s bin/system-health
/bin/bash scripts/check --all; echo "gate exit=$status (expect 0)"
```

Expected: `100644` then a non-zero exit whose message names `bin/system-health` and prints the
`git update-index --chmod=+x` fix; then `100755` restored and a clean pass. **Do not proceed until
the restore is verified** — leaving the index mutated would ship a mode regression in your own PR.

### Step 5 — Implement D4–D7, then gate on the committed state

Receipts expire on the next mutation, so commit first and gate last:

```fish
git add -A
git status --short
git commit -m "Restore committed-mode gate coverage and end the half-pinned toolchain (#83, #84)"
git ls-files -s | awk '$1=="100755"{print $4}' | sort
/bin/bash scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"
tail -1 /tmp/g.log
```

Expected: the same eight `100755` paths as §2a (plus `scripts/install-quality-tools` if you created
it), and both `exit=0`.

### Step 6 — STOP: push is gated

Request approval. Do not push while explaining.

### Step 7 — Exercise the weekly workflow on your branch (AC11 — do not skip)

`full-history-scan.yml` runs on cron and dispatch only, so **nothing in a PR exercises it**. Shipping
a change to it without a real run is the exact "reads as reproducible and is not" failure #84 exists
to fix.

**PM-unverified — the PM did not run these** (dispatching a workflow is a state-changing action):

```fish
gh workflow run "Full-history secret scan" -R Jared-Godar/macos-system-health --ref fix/issues-83-84-gate-coverage-and-weekly-pins
sleep 10
gh run list -R Jared-Godar/macos-system-health --workflow "Full-history secret scan" --limit 1 --json databaseId,headBranch,status,conclusion,url
gh run watch (gh run list -R Jared-Godar/macos-system-health --workflow "Full-history secret scan" --limit 1 --json databaseId --jq '.[0].databaseId') -R Jared-Godar/macos-system-health
```

Confirm `headBranch` is **your branch**, not `main`, before trusting the result. If GitHub refuses
the `--ref` (dispatch requires the workflow to exist on the default branch — it does, but the API
can still reject a ref), **report that as a finding**: say the weekly path is unexercised, propose
dispatching immediately after merge as the fallback, and do not claim coverage you do not have.

### Step 8 — STOP: opening the PR is gated

The dispatch receipt from Step 7 goes **in the PR body**.

## 6. PR metadata (all at creation time)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Restore committed-mode gate coverage and end the half-pinned toolchain (#83, #84)" \
  --assignee Jared-Godar \
  --label type:bug --label area:governance --label priority:medium \
  --label effort:medium --label status:ready --label risk:medium \
  --body "Closes #83
Closes #84

<why these two ship together (§2c: both restructure scripts/check's SHELL_FILES, and #84's claim
that a script under scripts/ is linted automatically is false); the D4 decision per tool with
reasoning; the D5 mechanism decision and the tap-cleanup call; the negative-test output from Step 4;
the eight-path mode read-back; scripts/check output from the committed state; the Step 7 weekly-scan
run URL and conclusion; the AGENTS.md diff summary; and an explicit note that no milestone is set
because both issues are deliberately unmilestoned #81 follow-ups>"
```

`Closes #83` and `Closes #84` must be on **separate lines** — GitHub does not parse
`Closes #83, #84`. Verify:

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], c83:(.body|test("Closes #83")), c84:(.body|test("Closes #84"))}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

Expected: six labels, **milestone null**, assignee `Jared-Godar`, project membership present, both
`c83`/`c84` true, all checks green. Required contexts are exactly `GitGuardian Security Checks` and
`checks`.

## 7. Acceptance criteria

Report against these numbers. Each names the command or artifact that demonstrates it.

1. **AC1** — `scripts/check --all` fails when an expected-executable file is committed `100644`.
   *Evidence:* the Step 4 negative-test transcript, showing non-zero exit.
2. **AC2** — `lib/cleanup.sh` at `100644` passes. *Evidence:* the clean `exit=0` run in Step 5 with
   `git ls-files -s lib/cleanup.sh` showing `100644`.
3. **AC3** — the failure message names the offending file and prints
   `git update-index --chmod=+x <file>`. *Evidence:* verbatim message from Step 4.
4. **AC4** — the expected-executable list has exactly one definition. *Evidence:*
   `grep -n 'bin/install-schedule' scripts/check` returns **one** line.
5. **AC5** — the assertion runs in both modes. *Evidence:* `/bin/bash scripts/check --staged` output
   showing the mode step, plus the `--all` run.
6. **AC6** — a recorded decision for **each** of `actionlint`, `shellcheck`, `gitleaks` on whether
   the weekly scan pins it, with reasoning. *Evidence:* PR body **and** `AGENTS.md`.
7. **AC7** — pinned versions and SHA-256s live in exactly one file. *Evidence:*
   `git grep -n "1\.7\.12\|0\.11\.0\|8\.30\.1" -- ':!CHANGELOG.md' ':!artifacts'` returns hits in one
   file only.
8. **AC8** — bounded retry, permanent-vs-transient classification, and the external-condition
   `::error::` message survive in whatever replaces the weekly `brew` block. *Evidence:* the diff.
9. **AC9** — `AGENTS.md` § "CI toolchain version contract" describes both workflows accurately, names
   the pins' home, and still points at #78 for the future relocation. *Evidence:* the diff.
10. **AC10** — the `brew untap aws/tap` step is explicitly kept or explicitly removed, with reasoning.
    *Evidence:* PR body.
11. **AC11** — `full-history-scan.yml` was actually run on the branch. *Evidence:* the run URL with
    `headBranch` = your branch and its conclusion — **or** an explicit finding that it could not be
    dispatched, with the fallback stated.
12. **AC12** — `/bin/bash scripts/check --all` exits 0 on the **committed** state, and CI `checks` is
    green on the PR. *Evidence:* Step 5 output plus `gh pr checks`.
13. **AC13** — CHANGELOG entry under `[Unreleased]`. *Evidence:* the diff.
14. **AC14** — if `scripts/install-quality-tools` was created: it is `100755`, it is in the linted
    file list, and the new mode assertion covers it. *Evidence:* `git ls-files -s scripts/` and
    `grep -n install-quality-tools scripts/check`. If you chose a different mechanism, say so and
    mark this AC **not applicable, with the reason**.

## 8. Checkpoints

Report at each; do not batch them at the end.

1. **Branch ready** — branch name, clean tree, `main` synced, spec placed, walkthrough written.
2. **Implementation + negative test** — the Step 4 transcript and the two design decisions with
   reasoning. This is the checkpoint where a wrong decision is cheapest to correct.
3. **PR created (CRITICAL)** — PR number/URL, full metadata read-back, AC1–AC14 status.
4. **CI green + weekly scan exercised** — `gh pr checks` output and the Step 7 run URL.
5. **After merge** — PR `MERGED`, #83 and #84 `CLOSED`, `main` fast-forwarded, branch deleted,
   `status:*` stripped from both issues, board Status `Done` for all three items.

Between 3 and 5 the PR is under merge **HOLD**. You do not merge and do not declare
merge-readiness; the PM re-runs a sample of your receipts and announces **GREEN LIGHT**.

## 9. Dependencies and sequencing

- **#81 is merged** (`f21a6d2`); this builds directly on it.
- **#78 is on hold** pending Fable availability and will relocate `AGENTS.md` § "CI toolchain version
  contract" to `docs/governance/`. Edit it **in place** now; do not pre-create the new home.
- No other open issue touches `scripts/check` or `.github/workflows/`. Verified by the PM against the
  open-issue list 2026-07-21T15:1x Z.

## 10. References

- **#83** — gate coverage for committed modes; **#84** — the half-pinned weekly toolchain
- **#81** / PR #86 — the pinning this follows from; `AGENTS.md` § "CI toolchain version contract"
- `scripts/check` (`SHELL_FILES`, line 18), `.github/workflows/lint.yml` (lines 15–94),
  `.github/workflows/full-history-scan.yml` (lines 42–78)
- CI receipt for the reusable fetch block: run `29841866289` on `main` @ `f21a6d2`, `success`

## 11. Verification status of the commands in this spec

Stated plainly so you know what to trust, per the #81 lesson that an unverified worked example in a
spec is worse than none:

| Commands | Status |
| --- | --- |
| §2a mode survey, §2b workflow survey, §2c `SHELL_FILES` claim, §2d CI receipt | **PM-verified** against `f21a6d2`, 2026-07-21 |
| Label existence, project auto-boarding, required check contexts | **PM-verified** |
| Step 1 sync/branch, Step 5 commit/gate, Step 6 metadata read-back | Standard rails, **structure verified**, not executed by the PM |
| **Step 4 negative test**, **Step 7 `gh workflow run --ref`** | **PM-UNVERIFIED — never executed.** Both mutate state. Verify and report the real output; if either behaves differently than described, that is a finding, not a reason to skip the AC |
