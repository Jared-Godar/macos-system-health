# Continuity walkthrough — Issue #81 (pin CI toolchain + fix the gate's Bash version)

Fill-in-the-rails so this workflow can be finished by hand if the session dies.
Mechanical steps only; work-in-progress state lives in the session, not here.
Fish syntax, run from the repository root. Replace any `⟨slot⟩` with the real
value. Refreshed at: **branch created** (initial). Next refresh points: PR opened,
awaiting merge.

- **Issue:** #81 — CI toolchain unpinned + unverified whether CI tests Bash 3.2
- **Branch:** `fix/issue-81-ci-toolchain-pinning` (cut from `main` @ `a2d9bc2`)
- **PR:** ⟨#N — URL⟩ (HOLD until PM GREEN LIGHT)
- **Milestone:** none (deliberate — tooling hygiene, not remediation work)
- **Labels:** `type:bug` `area:governance` `priority:medium` `effort:medium` `status:ready` `risk:high`
- **Spec:** `artifacts/specs/20260721T130001Z-issue-81-ci-toolchain-pinning.md`

> **This task has a DISCOVERY LOOP and therefore TWO gated pushes.** Push #1 is a
> diagnostic step; you read the real runner output, then decide the fix. Push #2
> ships the fix. Each push is separately gated — ask, wait, proceed, both times.

---

## 1. Sync main and branch — DONE

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git switch -c fix/issue-81-ci-toolchain-pinning
git branch --show-current   # -> fix/issue-81-ci-toolchain-pinning
git status --short artifacts/specs/   # -> only the #81 spec, untracked (follows onto branch)
```

## 2. Files changed by this work

- `.github/workflows/lint.yml` — pin the three brew tools; Bash-version fix per the
  measurement; `actions/checkout` decision. (Diagnostic step added in push #1, then
  removed/quieted in push #2.)
- `AGENTS.md` § Local environment — the target-version contract (Bash 3.2 + pinned
  tool versions + why + upgrade owner/cadence). Note in PR that #78 may relocate it.
- `CHANGELOG.md` — `[Unreleased]` entry.
- `artifacts/specs/...` + `artifacts/walkthroughs/...` — tracked session artifacts.

## 3. Push #1 — diagnostic (GATED) — ⟨status⟩

Add the temporary "Diagnose shell environment" step to `.github/workflows/lint.yml`
immediately before "Lint, test, and scan", then:

```fish
git add -A
git status --short
git commit -m "Diagnose CI shell environment (temporary, #81)"
scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"   # expect 0
tail -1 /tmp/g.log                                               # -> All checks passed.
# STOP — request push approval. After approval:
git push -u origin fix/issue-81-ci-toolchain-pinning
```

Read the real runner output (this is the entire basis for deliverable 1):

```fish
gh run list -R Jared-Godar/macos-system-health --branch fix/issue-81-ci-toolchain-pinning --limit 1
gh run view ⟨run-id⟩ -R Jared-Godar/macos-system-health --log | grep -A8 "Diagnose shell environment"
```

Measured result: ⟨paste verbatim — which bash `command -v bash` resolves to on the runner, and its version⟩

## 4. Decide + implement (deliverables 1–4) — ⟨status⟩

From the measurement:
- **Bash:** if the runner runs `scripts/check` under a newer Bash than 3.2, make the
  gate run under 3.2 (`/bin/bash scripts/check --all`) or a matrix covering both. Justify.
- **Pin** `actionlint` / `shellcheck` / `gitleaks` to explicit versions (mechanism +
  upgrade owner + cadence), or record a defended decision not to.
- **Record** the version contract in `AGENTS.md` § Local environment.
- **Decide** on SHA-pinning `actions/checkout@v7` (implement or decline with reasoning).
- **Remove** the temporary diagnostic step (or keep a quieter permanent version — say why).

## 5. Push #2 — the fix (GATED, on the COMMITTED state) — ⟨status⟩

```fish
git add -A
git status --short
git commit -m "Pin the CI toolchain and fix the gate's Bash version (#81)"
scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"           # expect 0
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"   # expect 0
tail -1 /tmp/g.log                                                       # -> All checks passed.
# STOP — request the SECOND push approval (separate from push #1). After approval:
git push
```

## 6. Open the PR (GATED) — ⟨#N⟩

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Pin the CI toolchain and fix the gate's Bash version (#81)" \
  --assignee Jared-Godar \
  --label type:bug --label area:governance --label priority:medium \
  --label effort:medium --label status:ready --label risk:high \
  --body-file ⟨pr-body-file⟩
```

No `--milestone` — #81 is deliberately unmilestoned.

## 7. Verify PR metadata + CI — ⟨status⟩

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], closes:(.body|test("Closes #81"))}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

Expected: six labels, **milestone null**, assignee `Jared-Godar`, project membership
present, `closes` true, all checks green **with the new pins in effect**.

## 8. Merge is the maintainer's, on the PM GREEN LIGHT — PENDING

Do not merge. The PR is under merge **HOLD** until the PM announces
**GREEN LIGHT: clear to squash-merge PR ⟨#N⟩ via the GUI**.

## 9. Post-merge closure (runs unprompted after merge)

```fish
gh pr view ⟨#N⟩ -R Jared-Godar/macos-system-health --json state --jq .state   # MERGED
gh issue view 81 -R Jared-Godar/macos-system-health --json state --jq .state  # CLOSED
git switch main; and git fetch --prune origin; and git merge --ff-only origin/main
git branch -D fix/issue-81-ci-toolchain-pinning
gh issue edit 81 -R Jared-Godar/macos-system-health --remove-label status:ready
git status --short; and git log --oneline -1   # clean, main at squash commit
```

Confirm afterward: PR ⟨#N⟩ `MERGED`, issue #81 `CLOSED`, board Status `Done` for
both, local branch deleted, `main` fast-forwarded.

## Open risks / watch-items

- Bash is **3.2.57** on this host; locally `command -v bash` -> `/bin/bash` (3.2).
  The runner PATH is the unknown this task measures — do not assume it matches local.
- Pinning creates an upgrade obligation; the contract must name the owner + cadence.
- The temporary diagnostic step must be removed (or deliberately kept quieter) before merge.
- Diagnostic push may turn the run red if the diagnostic step itself errors; the
  diagnostic output is still readable from the log regardless.
