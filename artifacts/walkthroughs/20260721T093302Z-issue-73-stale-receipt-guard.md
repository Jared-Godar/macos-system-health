# Continuity walkthrough — Issue #73 (pre-push guard against stale gate receipts)

Fill-in-the-rails so this workflow can be finished by hand if the session dies.
Mechanical steps only; work-in-progress state lives in the session, not here.
Fish syntax, run from the repository root. Replace every `⟨slot⟩` with the real
value. Refreshed at: **branch created** (this version). Next refresh points:
PR opened, awaiting merge.

- **Issue:** #73 — Name the stale-receipt failure mode + add the pre-push mechanism
- **Branch:** `fix/issue-73-stale-receipt-guard`
- **Milestone:** `Remediation - Back to Step 0`
- **Labels:** `type:feature` `area:governance` `priority:medium` `effort:small` `status:ready`
- **Spec:** `artifacts/specs/20260721T091208Z-issue-73-stale-receipt-guard.md`
- **PR:** ⟨#N once opened⟩

---

## 1. Sync main and branch (already done)

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git switch -c fix/issue-73-stale-receipt-guard
git branch --show-current   # -> fix/issue-73-stale-receipt-guard
```

## 2. Files changed by this work

- `.githooks/pre-push` (new) — refuses a red push on the committed state
- `scripts/install-hooks` — message mentions both hooks; verifies executable bit
- `scripts/check` — `.githooks/pre-push` added to the lint set `SHELL_FILES`
- `AGENTS.md` — new "Receipts expire on the next mutation" standing commitment
- `CONTRIBUTING.md` — one-time-setup mentions the pre-push hook
- `CHANGELOG.md` — `[Unreleased] > Added` entry
- `artifacts/specs/...` + `artifacts/walkthroughs/...` — tracked session artifacts

## 3. Install hooks and verify wiring

```fish
scripts/install-hooks
git config core.hooksPath          # -> .githooks
test -x .githooks/pre-push; and echo "pre-push executable"
```

## 4. Gate on the COMMITTED state (commit -> gate -> report)

```fish
git add -A
git status --short
git commit -m "Add pre-push guard against stale gate receipts (#73)"
scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"     # expect 0
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"  # expect 0
tail -1 /tmp/g.log                 # -> All checks passed.
```

## 5. STOP — push is gated (maintainer go-ahead required)

```fish
# Only after explicit go-ahead:
git push -u origin fix/issue-73-stale-receipt-guard
git ls-remote --heads origin fix/issue-73-stale-receipt-guard   # ref exists
```

## 6. STOP — opening the PR is gated (maintainer go-ahead required)

```fish
# Only after explicit go-ahead:
gh pr create -R Jared-Godar/macos-system-health \
  --title "Add pre-push guard against stale gate receipts (#73)" \
  --assignee Jared-Godar \
  --milestone "Remediation - Back to Step 0" \
  --label type:feature --label area:governance --label priority:medium \
  --label effort:small --label status:ready \
  --body "Closes #73

⟨what you built; the §3 decision and why; what the guard does and does NOT cover;
the three receipts; the scripts/check output from the committed state⟩"
```

## 7. Verify PR metadata + CI

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], closes:(.body|test("Closes #73"))}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

## 8. Merge is the maintainer's, on the PM GREEN LIGHT

Do not merge. From first push the PR is under merge **HOLD** until the PM
announces **GREEN LIGHT**. The maintainer squash-merges via the GUI.

## 9. Post-merge closure (runs unprompted after merge)

```fish
gh pr view ⟨#N⟩ -R Jared-Godar/macos-system-health --json state --jq .state   # MERGED
gh issue view 73 -R Jared-Godar/macos-system-health --json state --jq .state  # CLOSED
git switch main; and git fetch --prune origin; and git merge --ff-only origin/main
git branch -D fix/issue-73-stale-receipt-guard
gh issue edit 73 -R Jared-Godar/macos-system-health --remove-label status:ready
git status --short; and git log --oneline -1   # clean, main at squash commit
```

## Open risks / watch-items

- Bash is **3.2** on this host; the hook must stay 3.2-safe (guarded empty arrays,
  no `mapfile`).
- The `--no-verify` override receipt and the end-to-end origin push are the only
  receipts that require an actual push — both gated.
- `scripts/check` gained a file in `SHELL_FILES`; disclosed as a scope note in the PR.
