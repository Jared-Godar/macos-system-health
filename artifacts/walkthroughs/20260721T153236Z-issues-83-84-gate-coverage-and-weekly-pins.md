# Continuity walkthrough — Issues #83, #84 (gate mode-coverage + end the half-pinned toolchain)

Fill-in-the-rails so this workflow can be finished by hand if the session dies.
Mechanical steps only; work-in-progress state lives in the session, not here.
Fish syntax, run from the repository root. Replace any `⟨slot⟩` with the real
value. Refreshed at: **branch created** (initial). Next refresh points: PR opened,
awaiting merge.

- **Issues:** #83 — gate no longer verifies committed executable bits after #81 ·
  #84 — weekly full-history scan still installs a rolling, unpinned toolchain
- **Branch:** `fix/issues-83-84-gate-coverage-and-weekly-pins` (cut from `main` @ `f21a6d2`)
- **PR:** ⟨#N — URL⟩ (HOLD until PM GREEN LIGHT)
- **Milestone:** none (deliberate — both are #81 hygiene follow-ups, filed unmilestoned on purpose)
- **Labels:** `type:bug` `area:governance` `priority:medium` `effort:medium` `status:ready` `risk:medium`
- **Spec:** `artifacts/specs/20260721T152007Z-issues-83-84-gate-coverage-and-weekly-pins.md`

> **Two gated stops in this task:** push (before Step 7 can run) and open-PR.
> Ask, wait, proceed — each time. **Never merge.**

---

## 1. Sync main and branch — DONE

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git switch -c fix/issues-83-84-gate-coverage-and-weekly-pins
git branch --show-current            # -> fix/issues-83-84-gate-coverage-and-weekly-pins
git status --short artifacts/specs/   # -> only the #83/#84 spec, untracked (follows onto branch)
```

## 2. Files changed by this work

- `scripts/check` — split `SHELL_FILES` into an expected-executable list and a
  sourced list; add a committed-mode assertion via `git ls-files -s` that runs in
  both `--all` and `--staged`, fails before the expensive passes, and prints the
  `git update-index --chmod=+x <file>` fix (#83, D1–D3).
- `scripts/install-quality-tools` — **NEW**, `100755`. The single home for the
  pinned versions + SHA-256s; installs a named **subset** of tools, reusing #81's
  fetch/retry/checksum block. Added to the linted file list (#84, D5).
- `.github/workflows/lint.yml` — replace the inline pinned-install block with
  `/bin/bash scripts/install-quality-tools actionlint shellcheck gitleaks`. Job key
  `checks` and the Bash-3.2 assertion step are **untouched** (D5, non-goal).
- `.github/workflows/full-history-scan.yml` — call the script for pinned
  `actionlint shellcheck`; keep `gitleaks` floating via `brew install` with its
  bounded retry; keep the `brew untap aws/tap` step (still uses Homebrew) (#84, D4/D5).
- `AGENTS.md` § "CI toolchain version contract (Issue #81)" — name the new home,
  describe both workflows accurately, keep the #78 relocation pointer, and remove the
  literal version numbers so the pins live in exactly one file (D6, AC7).
- `CHANGELOG.md` — `[Unreleased]` entry (D7).
- `artifacts/specs/...` + `artifacts/walkthroughs/...` — tracked session artifacts.

## 3. Implement + happy path — ⟨status⟩

```fish
# after editing scripts/check (D1–D3):
/bin/bash scripts/check --all; echo "gate exit=$status"   # expect 0
```

## 4. Negative test (AC1; mutates the index) — ⟨status⟩

```fish
git update-index --chmod=-x bin/system-health
git ls-files -s bin/system-health                          # -> 100644 ...
/bin/bash scripts/check --all; echo "gate exit=$status (expect NON-zero)"
git update-index --chmod=+x bin/system-health
git ls-files -s bin/system-health                          # -> 100755 ... (RESTORED)
/bin/bash scripts/check --all; echo "gate exit=$status (expect 0)"
```

Do not proceed until the `100755` restore is verified.

## 5. Implement D4–D7, commit, gate on the COMMITTED state — ⟨status⟩

```fish
git add -A
git status --short
git commit -m "Restore committed-mode gate coverage and end the half-pinned toolchain (#83, #84)"
git ls-files -s | awk '$1=="100755"{print $4}' | sort   # -> the 8 paths + scripts/install-quality-tools
/bin/bash scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"      # expect 0
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"       # expect 0
tail -1 /tmp/g.log                                                            # -> All checks passed.
```

## 6. STOP — push is GATED — ⟨status⟩

```fish
# After maintainer approval only:
git push -u origin fix/issues-83-84-gate-coverage-and-weekly-pins
```

## 7. Exercise the weekly workflow on the branch (AC11) — ⟨status⟩

```fish
gh workflow run "Full-history secret scan" -R Jared-Godar/macos-system-health --ref fix/issues-83-84-gate-coverage-and-weekly-pins
sleep 10
gh run list -R Jared-Godar/macos-system-health --workflow "Full-history secret scan" --limit 1 --json databaseId,headBranch,status,conclusion,url
gh run watch (gh run list -R Jared-Godar/macos-system-health --workflow "Full-history secret scan" --limit 1 --json databaseId --jq '.[0].databaseId') -R Jared-Godar/macos-system-health
```

Confirm `headBranch` is the branch, not `main`. If `--ref` is refused, record a
finding: the weekly path is unexercised; fallback is dispatch immediately after merge.

## 8. STOP — open PR is GATED — ⟨#N⟩

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Restore committed-mode gate coverage and end the half-pinned toolchain (#83, #84)" \
  --assignee Jared-Godar \
  --label type:bug --label area:governance --label priority:medium \
  --label effort:medium --label status:ready --label risk:medium \
  --body-file ⟨pr-body-file⟩
```

`Closes #83` and `Closes #84` on **separate lines**. No `--milestone` (deliberate).
The Step 7 dispatch receipt goes in the PR body.

## 9. Verify PR metadata + CI — ⟨status⟩

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], c83:(.body|test("Closes #83")), c84:(.body|test("Closes #84"))}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

Expected: six labels, **milestone null**, assignee `Jared-Godar`, project present, both
`c83`/`c84` true, checks green. Required contexts: `GitGuardian Security Checks`, `checks`.

## 10. Merge is the maintainer's, on the PM GREEN LIGHT — PENDING

Do not merge. HOLD until the PM announces
**GREEN LIGHT: clear to squash-merge PR ⟨#N⟩ via the GUI**.

## 11. Post-merge closure (runs unprompted after merge)

```fish
gh pr view ⟨#N⟩ -R Jared-Godar/macos-system-health --json state --jq .state   # MERGED
gh issue view 83 -R Jared-Godar/macos-system-health --json state --jq .state  # CLOSED
gh issue view 84 -R Jared-Godar/macos-system-health --json state --jq .state  # CLOSED
git switch main; and git fetch --prune origin; and git merge --ff-only origin/main
git branch -D fix/issues-83-84-gate-coverage-and-weekly-pins
gh issue edit 83 -R Jared-Godar/macos-system-health --remove-label status:ready
gh issue edit 84 -R Jared-Godar/macos-system-health --remove-label status:ready
git status --short; and git log --oneline -1   # clean, main at squash commit
```

Confirm afterward: PR ⟨#N⟩ `MERGED`, #83 and #84 `CLOSED`, board Status `Done` for all
three items, local branch deleted, `main` fast-forwarded.

## Open risks / watch-items

- **Step 4 and Step 7 are PM-unverified** in the spec — both mutate state. Paste the
  real output; if either behaves differently than described, that is a finding.
- `scripts/install-quality-tools` writes to `$GITHUB_PATH` / `$RUNNER_TEMP` — it is a
  CI-only installer. It is still linted by ShellCheck; keep env-looking vars uppercase.
- The weekly scan floats `gitleaks` via Homebrew **by design** — which is exactly why
  the `brew untap aws/tap` step stays. Removing it would be a silent regression.
- Bash **3.2** is the target; CI syntax-checks under 3.2. No `mapfile`, `declare -A`,
  `${v^^}`, or namerefs in either edited script. Run `/bin/bash scripts/check --all`
  (not a PATH-resolved `bash`) to reproduce CI locally.
