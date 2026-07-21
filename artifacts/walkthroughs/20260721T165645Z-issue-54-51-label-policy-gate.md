# Continuity walkthrough — Issues #54 / #51 (type-aware label policy + PR gate)

Fill-in-the-rails workflow so the maintainer can finish this by hand if the session dies.
**Rails only** — the work-state narrative lives in the session handoff (if one is written), which
links here rather than repeating these commands. All blocks are **Fish**, run from the repo root.

- **Issue(s):** Closes #54, #51 · **Milestone:** Remediation - Back to Step 0
- **Branch:** `feat/issues-54-51-label-policy-gate` (cut from `main` @ `60780f0`)
- **Labels:** `area:governance`, `priority:high`, `type:feature`, `effort:medium`, `status:ready`, `risk:high`
- **Spec:** `artifacts/specs/20260721T164206Z-issues-54-51-label-policy-and-gate.md`
- **PR:** ⟨#NNN once opened⟩ · **Check context:** ⟨job key, confirmed in Step 6⟩

---

## Step 1 — Sync and branch (DONE)

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git switch -c feat/issues-54-51-label-policy-gate
git branch --show-current   # -> feat/issues-54-51-label-policy-gate
```

## Step 2 — Add `risk:low` on the live repo (metadata write, not gated)

```fish
gh label create risk:low -R Jared-Godar/macos-system-health \
  --description "Minimal or easily reversible impact" --color "0E8A16"
gh label list -R Jared-Godar/macos-system-health --limit 200 --json name --jq '.[].name' | grep '^risk:'
# verify: risk:high, risk:medium, risk:low all present
```

## Step 3 — Files land on the branch

Deliverables (all committed in Step 5):
- `.github/labels.json` — `risk:low` added to `schema.risk.values` and `labels[]`
- `.github/label-policy.json` — required-label matrix (source of truth)
- `scripts/check-label-policy` — pure `--labels` evaluator + thin `--pr` fetch path (mode `100755`)
- `.github/workflows/label-policy-gate.yml` — PR gate
- `tests/smoke.sh` — negative tests via `run_test`
- `scripts/check` — `scripts/check-label-policy` added to `EXECUTABLE_FILES`
- `CONTRIBUTING.md` — one-paragraph pointer to the policy file
- `CHANGELOG.md` — `[Unreleased]` entry

```fish
git update-index --chmod=+x scripts/check-label-policy   # index mode 100755
```

## Step 4 — Exercise the gate against known-bad input (AC10–AC12)

```fish
# AC10 — feature without risk:* FAILS
scripts/check-label-policy --labels "type:feature,area:governance,priority:high,effort:medium,status:ready"; echo "exit=$status"  # nonzero
# AC11 — docs without risk:* PASSES
scripts/check-label-policy --labels "type:docs,area:governance,priority:high,effort:medium,status:ready"; echo "exit=$status"      # 0
# AC12 — missing effort FAILS, names effort
scripts/check-label-policy --labels "type:feature,area:governance,priority:high,status:ready,risk:high"; echo "exit=$status"       # nonzero
```

## Step 5 — Commit, then gate on the committed state

```fish
git add -A
git status --short
git commit -m "Encode the type-aware label policy and gate PRs on it (#54, #51)"
/bin/bash scripts/check --all > /tmp/g.log 2>&1; echo "gate exit=$status"   # 0
git show --check HEAD > /dev/null 2>&1; echo "show --check exit=$status"      # 0
tail -3 /tmp/g.log   # new smoke-test count
```

## Step 6 — STOP: push is gated (ask the maintainer first)

```fish
git push -u origin feat/issues-54-51-label-policy-gate
# After CI runs, capture the exact check context (job key):
gh api repos/Jared-Godar/macos-system-health/commits/(git rev-parse HEAD)/check-runs \
  --jq '[.check_runs[].name]'
```

## Step 7 — STOP: open PR is gated (ask the maintainer first)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Encode the type-aware label policy and gate PRs on it (#54, #51)" \
  --assignee Jared-Godar \
  --milestone "Remediation - Back to Step 0" \
  --label area:governance --label priority:high --label type:feature \
  --label effort:medium --label status:ready --label risk:high \
  --body "⟨see spec §6 — full body with receipts⟩"
```

Verify metadata + checks:

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], closes54:(.body|test("Closes #54")), closes51:(.body|test("Closes #51"))}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

## Step 8 — Merge is gated (maintainer merges via GUI on the PM's GREEN LIGHT)

Do **not** self-merge. After the PM announces GREEN LIGHT and the maintainer squash-merges:

```fish
gh pr view ⟨#NNN⟩ -R Jared-Godar/macos-system-health --json state,mergedAt --jq '{state, mergedAt}'  # MERGED
gh issue view 54 -R Jared-Godar/macos-system-health --json state --jq .state   # CLOSED
gh issue view 51 -R Jared-Godar/macos-system-health --json state --jq .state   # CLOSED
```

## Step 9 — Post-merge closure (runs unprompted after merge)

```fish
git switch main; and git fetch --prune; and git merge --ff-only origin/main
git branch -D feat/issues-54-51-label-policy-gate
git status --short   # clean
# strip status:ready from the closed issues
gh issue edit 54 -R Jared-Godar/macos-system-health --remove-label status:ready
gh issue edit 51 -R Jared-Godar/macos-system-health --remove-label status:ready
# confirm board Status = Done for #54, #51, and the PR (via the project UI or gh project item-list)
```

## Step 10 — OWED after this PR merges (not part of it)

Branch protection: add the new check as a required context **only after** one PR has been
observed green under it (a misnamed required context blocks every future PR, including its own
fix). Command the maintainer runs, with `⟨context⟩` = the job key confirmed in Step 6:

```fish
gh api -X PATCH repos/Jared-Godar/macos-system-health/branches/main/protection/required_status_checks \
  -f 'checks[][context]=checks' -f 'checks[][context]=GitGuardian Security Checks' -f 'checks[][context]=⟨context⟩'
```

Deferred / out of scope (tracked): #53 relabel 7 violating issues · #52→#78 selection guide ·
#93 orphan-label cleanup + labels.json↔live drift.

## Open risks / watch-items

- New check's context name is **unverified until Step 6** — confirm empirically; do not trust
  the job key blindly before flipping branch protection.
- `jq` availability on `macos-15` runners is PM-verified for the toolchain but the gate's own
  `jq` use is exercised for the first time in CI here.
