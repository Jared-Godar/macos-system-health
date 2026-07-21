# Continuity walkthrough — Issue #73 (pre-push guard against stale gate receipts)

Fill-in-the-rails so this workflow can be finished by hand if the session dies.
Mechanical steps only; work-in-progress state lives in the session, not here.
Fish syntax, run from the repository root. Replace any `⟨slot⟩` with the real
value. Refreshed at: **PR opened** (#75). Next refresh point: awaiting merge.

- **Issue:** #73 — Name the stale-receipt failure mode + add the pre-push mechanism
- **Branch:** `fix/issue-73-stale-receipt-guard` (origin tip `555d419`)
- **PR:** #75 — https://github.com/Jared-Godar/macos-system-health/pull/75 (HOLD)
- **Milestone:** `Remediation - Back to Step 0`
- **Labels:** `type:feature` `area:governance` `priority:medium` `effort:small` `status:ready`
- **Spec:** `artifacts/specs/20260721T091208Z-issue-73-stale-receipt-guard.md`

---

## 1. Sync main and branch — DONE

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git switch -c fix/issue-73-stale-receipt-guard
git branch --show-current   # -> fix/issue-73-stale-receipt-guard
```

## 2. Files changed by this work

- `.githooks/pre-push` (new) — refuses a red push on the committed state
- `scripts/install-hooks` — message names both hooks; verifies executable bit
- `scripts/check` — `.githooks/pre-push` added to the lint set `SHELL_FILES`
- `AGENTS.md` — new "Receipts expire on the next mutation" standing commitment
- `CONTRIBUTING.md` — one-time-setup mentions the pre-push hook
- `CHANGELOG.md` — `[Unreleased] > Added` entry
- `artifacts/specs/...` + `artifacts/walkthroughs/...` — tracked session artifacts

## 3. Install hooks and verify wiring — DONE

```fish
scripts/install-hooks
git config core.hooksPath          # -> .githooks
test -x .githooks/pre-push; and echo "pre-push executable"
```

## 4. Gate on the COMMITTED state (commit -> gate -> report) — DONE (555d419)

```fish
git add -A
git status --short
git commit -m "Add pre-push guard against stale gate receipts (#73)"
scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"           # was 0
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"   # was 0
tail -1 /tmp/g.log                 # -> All checks passed.
```

## 5. Push — DONE (pre-push hook gated it and allowed the green state)

```fish
git push -u origin fix/issue-73-stale-receipt-guard
git ls-remote --heads origin fix/issue-73-stale-receipt-guard   # -> 555d419e1c...
```

## 6. Open the PR — DONE (#75)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Add pre-push guard against stale gate receipts (#73)" \
  --assignee Jared-Godar \
  --milestone "Remediation - Back to Step 0" \
  --label type:feature --label area:governance --label priority:medium \
  --label effort:small --label status:ready \
  --body-file <pr-body>
```

## 7. Verify PR metadata + CI — DONE (all green)

```fish
gh pr view 75 -R Jared-Godar/macos-system-health \
  --json number,title,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], closes:(.body|test("Closes #73"))}'
gh pr checks 75 -R Jared-Godar/macos-system-health
```

Read-back confirmed: 5 labels, milestone `Remediation - Back to Step 0`, assignee
`Jared-Godar`, project `macOS System Health Roadmap`, `closes` true. Checks (all pass):
`Add PR to macOS System Health Roadmap`, `Analyze (actions)`, `CodeQL`,
`GitGuardian Security Checks`, `checks` (quality, branch push + PR).

## 8. Merge is the maintainer's, on the PM GREEN LIGHT — PENDING

Do not merge. The PR is under merge **HOLD** until the PM announces
**GREEN LIGHT: clear to squash-merge PR #75 via the GUI**. An adversarial review
of the diff is running (isolated `/tmp` clone, issue #76). Merge is the
maintainer's action via the GUI on the announcement.

## 9. Post-merge closure (runs unprompted after merge)

```fish
gh pr view 75 -R Jared-Godar/macos-system-health --json state --jq .state   # MERGED
gh issue view 73 -R Jared-Godar/macos-system-health --json state --jq .state # CLOSED
git switch main; and git fetch --prune origin; and git merge --ff-only origin/main
git branch -D fix/issue-73-stale-receipt-guard
gh issue edit 73 -R Jared-Godar/macos-system-health --remove-label status:ready
git status --short; and git log --oneline -1   # clean, main at squash commit
```

Confirm afterward: PR #75 `MERGED`, issue #73 `CLOSED`, board Status `Done` for
both, local branch deleted, `main` fast-forwarded.

## Open risks / watch-items

- Bash is **3.2.57** on this host; the hook must stay 3.2-safe (guarded empty
  arrays, no `mapfile`). Under adversarial review (see #76).
- `scripts/check` gained a file in `SHELL_FILES`; disclosed as a scope note in the PR.
- Adversarial-review findings (batch) are pending; do not remediate piecemeal.
