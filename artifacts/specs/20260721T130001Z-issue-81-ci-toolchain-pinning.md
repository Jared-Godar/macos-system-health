# Spec: Pin the CI toolchain and determine which Bash CI actually tests (Issue #81)

**Closes:** #81 · **Milestone:** none (deliberate — tooling hygiene, not remediation work)
**Labels:** `type:bug`, `area:governance`, `priority:medium`, `effort:medium`, `status:ready`, `risk:high`
**Assignee:** Jared-Godar · **Project:** macOS System Health Roadmap
**Sizing:** `--model sonnet --effort high` — Standard. CI work where a mistake turns the gate red for
every future PR, plus a discovery loop and three recorded decisions.

> **PLACEMENT NOTE — read first.** This spec now lives at its canonical path,
> `artifacts/specs/20260721T130001Z-issue-81-ci-toolchain-pinning.md`, untracked on `main`. It was
> held in a scratch location until #80 merged, because that executor ran `git add -A` in the primary
> checkout and would have swept it into its commit. **You do not need to copy it anywhere — it is
> already in place. Commit it with your PR.**

---

## 0. Read the durable contracts first (non-negotiable)

Before writing anything, read and follow, in order:

1. **`AGENTS.md` on `main`** — the binding contract, 22 standing commitments as of `5b5830b`.
2. `CLAUDE.md` at the repo root — 11 mirrored non-negotiables.
3. `~/.claude/CLAUDE.md` — the maintainer's cross-project standing rules.
4. `CONTRIBUTING.md`.
5. **Issue #81 in full** — diagnosis, the Bash-version question, and the deliverables.

**The rules that will bite you on this specific task:**

- **This task has a discovery loop and therefore needs TWO push approvals.** You push a diagnostic
  step, read the real runner output, then decide the fix. Each push is a separate gated action.
  Ask, wait, then proceed — both times.
- **Calibrated claims.** You do **not** know which Bash CI uses until a real run tells you. Do not
  assume, do not reason from what is typical. Report the measurement.
- **Receipts expire on the next mutation.** Commit first, gate second, report third.
- **Four gated actions need per-instance go-ahead: push, open PR, merge, release-tag.** Never merge.
- **No contract-lawyering.** A criterion that cannot be met is a **finding to report, never a
  criterion to drop**.
- **Specs are immutable after handoff.** This file is read-only to you.
- **Always pass `-R Jared-Godar/macos-system-health`** on every `gh` write.

## 0b. Progress tracking

Maintain a live task list — one item per §5 step plus each acceptance criterion — moving each to
in-progress/done as you go. Use **TodoWrite** if available. If TodoWrite is unavailable, say so once,
then **re-post the full checklist as inline markdown at the top of every response that starts or
finishes a step**, marking `[x]` done / `[~]` in-progress / `[ ]` todo. Do not let more than one tool
batch pass without a refreshed checklist.

---

## 1. Intended outcome

The quality gate is reproducible: it runs known tool versions, and it demonstrably runs under the
Bash version the project targets. A green PR today stays green tomorrow unless the code changed.

## 2. Current state and gap

```yaml
# .github/workflows/lint.yml
- name: Install quality tools
  run: brew install actionlint shellcheck gitleaks
- name: Lint, test, and scan
  run: scripts/check --all
```

**Gap 1 — unpinned toolchain.** Every run gets whatever Homebrew ships that day. A ShellCheck release
enabling a check by default, an actionlint rule change, or a new gitleaks rule turns CI red with no
code change, and it lands on whoever pushes next looking like their defect. `bin/system-health` is a
system-mutating tool; its gate should not be a moving target.

**Gap 2 — unknown Bash, and this is the sharper one.** `AGENTS.md` targets **Bash 3.2** (macOS system
Bash; locally confirmed `/bin/bash` = 3.2.57). But every gated script uses `#!/usr/bin/env bash`,
which resolves via `PATH`. If the `macos-15` runner has a newer Bash earlier on `PATH`, **CI has never
tested the version the project targets** — 3.2-incompatible constructs (`mapfile`, associative arrays,
namerefs, empty-array expansion under `set -u`) would pass CI and fail on a user's machine.
`.githooks/pre-push` from #73 uses arrays and `read -r -a`; it was hand-verified against 3.2 locally,
but nothing enforces it.

**This is unknown, not assumed.** Determine it empirically.

## 3. Deliverables

1. **Determine the CI Bash situation** from a real run (see §5 Step 2), then decide and document:
   does the gate run under 3.2, a newer Bash, or both? If the target is 3.2, make the gate run under
   it — `/bin/bash scripts/check --all`, or a matrix covering both. **Justify the choice.**
2. **Pin `actionlint`, `shellcheck`, `gitleaks`** to explicit versions, with a recorded upgrade path.
   Weigh and justify the mechanism: versioned brew formulae where they exist, pinned release
   downloads, or a documented "unpinned but reviewed on failure" stance. **Pinning creates an upgrade
   obligation — name who owns it and at what cadence.** An explicit, reasoned decision *not* to pin is
   an acceptable outcome if you can defend it; silently leaving it unpinned is not.
3. **Record the target-version contract** — Bash 3.2, the pinned tool versions, and why each is
   pinned — where a cold-start session will find it. Put it in `AGENTS.md` § Local environment for
   now and note in the PR that #78 may relocate it to `docs/governance/`; do not create a competing
   second home.
4. **Decide on SHA-pinning `actions/checkout@v7`.** A major-version tag is mutable. Implement or
   decline with reasoning — declining is a complete answer.
5. **CHANGELOG** entry under `[Unreleased]`.

## 4. Non-goals

- Not adding uv, Python packaging, or any Python toolchain — explicitly rejected in #80. This repo has
  no Python packaging and uses `python3` only as a thing `bin/system-health` *reports on* and as a
  stdlib `json.tool` test helper.
- Not changing what `scripts/check` runs — only which versions run it.
- Not moving CI off macOS. `runs-on: macos-15` is correct for a macOS-specific tool.
- Not touching `bin/`, `lib/`, or `tests/` behavior.

## 5. Execution rails

Fish syntax, from the repo root. Each step followed by its verification.

### Step 1 — Sync and branch

`main` should be at `a2d9bc2` or later (#80 merged 2026-07-21T13:09:29Z) — sync, do not assume.

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git status --short; and git log --oneline -1
git switch -c fix/issue-81-ci-toolchain-pinning
git status --short artifacts/specs/
```

Expected before branching: the only untracked file is this spec at
`artifacts/specs/20260721T130001Z-issue-81-ci-toolchain-pinning.md`. It is already in place — do not
copy it. It follows you onto the branch and is committed with your PR in Step 4.

### Step 2 — Discovery: add a diagnostic step and read the real output

Add a temporary step to `.github/workflows/lint.yml`, immediately before "Lint, test, and scan":

```yaml
      - name: Diagnose shell environment (temporary, Issue #81)
        run: |
          echo "PATH=$PATH"
          command -v bash
          bash --version | head -1
          /bin/bash --version | head -1
          echo "env bash -> $(env bash -c 'echo $BASH_VERSION')"
```

Commit, gate, then **STOP and request push approval**. After pushing, read the actual workflow output:

```fish
gh run list -R Jared-Godar/macos-system-health --branch fix/issue-81-ci-toolchain-pinning --limit 1
gh run view <run-id> -R Jared-Godar/macos-system-health --log | grep -A8 "Diagnose shell environment"
```

**Paste that output verbatim.** It is the entire basis for deliverable 1. Do not proceed to Step 3
until you have it.

### Step 3 — Decide and implement

Using the measured result, implement deliverables 1–4. **Remove the temporary diagnostic step** unless
you decide to keep a permanent, quieter version — if you keep it, say why.

### Step 4 — Gate, on the committed state

```fish
git add -A
git status --short
git commit -m "Pin the CI toolchain and fix the gate's Bash version (#81)"
scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"
tail -1 /tmp/g.log
```

Expected both `exit=0`.

### Step 5 — STOP: second push is gated

Request approval separately from Step 2's. Then push and confirm CI is green **with the new pins in
effect** — that run is the real receipt, not the local gate.

### Step 6 — STOP: opening the PR is gated

## 6. PR metadata (all at creation time)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Pin the CI toolchain and fix the gate's Bash version (#81)" \
  --assignee Jared-Godar \
  --label type:bug --label area:governance --label priority:medium \
  --label effort:medium --label status:ready --label risk:high \
  --body "Closes #81

<the verbatim diagnostic output; which Bash CI was actually using and what you changed; the pinning
mechanism and why; who owns upgrades and at what cadence; the actions/checkout decision; where the
version contract is recorded; scripts/check output from the committed state; the CI run receipt with
pins in effect>"
```

**No `--milestone`** — #81 is deliberately unmilestoned. All six labels are confirmed present in
`.github/labels.json` (PM-verified 2026-07-21).

Verify:

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], closes:(.body|test("Closes #81"))}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

Expected: six labels, **milestone null**, assignee `Jared-Godar`, project membership present,
`closes` true, all checks green.

## 7. Checkpoints (five — one more than usual, because of the discovery loop)

1. **Branch ready** — branch name, clean tree, `main` synced, spec placed.
2. **Diagnostic pushed and read (CRITICAL)** — the verbatim runner output, and what it means for
   deliverable 1.
3. **PR created (CRITICAL)** — PR number/URL, full metadata read-back, all four decisions with
   justification.
4. **CI green with pins in effect** — `gh pr checks` output.
5. **After merge** — PR `MERGED`, #81 `CLOSED`, `main` fast-forwarded, branch deleted, `status:*`
   stripped, board Status `Done`.

Between 3 and 5 the PR is under merge **HOLD**. You do not merge and do not declare merge-readiness;
the PM re-runs a sample of your receipts and announces **GREEN LIGHT**.

## 8. Dependencies

- **#80** may merge first and move `main`; sync in Step 1 rather than assuming.
- **#78** (`docs/governance/`) will likely relocate the version contract. Put it in `AGENTS.md` now and
  flag the future move in the PR body — do not create two homes for it.

## 9. References

- `.github/workflows/lint.yml`; `scripts/check`; `.githooks/pre-push` (Bash-3.2-sensitive constructs)
- **#81** — full diagnosis; **#80** — where uv/Python locking was raised and rejected
- `AGENTS.md` § Local environment (Bash 3.2 target), on `main` at `5b5830b`
