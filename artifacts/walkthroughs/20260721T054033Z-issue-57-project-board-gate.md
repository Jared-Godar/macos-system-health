# Continuity walkthrough — Issue #57 (false-green project-membership gate)

Fill-in-the-rails so Jared can finish the workflow by hand if this session dies.
All commands are **Fish**, runnable from the repository root. This is the
canonical-flow walkthrough only — no work-in-progress code/state (that already
merged into the branch and pushed).

## State snapshot (as of 2026-07-21T05:40Z)

| Item | Value |
|---|---|
| Issue | #57 — OPEN, milestone v1.0 |
| Branch | `fix/issue-57-project-board-gate` (pushed) |
| Commit | `bc7cd9d` Fail loudly when a PR is not boarded (Issue #57) |
| PR | **#58** (DRAFT) — https://github.com/Jared-Godar/macos-system-health/pull/58 |
| Worktree | `.claude/worktrees/fix-issue-57-project-board-gate` |
| Files | `.github/workflows/add-pr-to-project.yml` (rewritten), `CHANGELOG.md` (+`### Fixed`) |

**Gates (done / green this session):**
- `scripts/check --all` → All checks passed (actionlint + shellcheck + 41/41 smoke + gitleaks).
- CI on PR #58: `checks` ✅ (required), `GitGuardian Security Checks` ✅ (required),
  `Add PR to macOS System Health Roadmap (Project #3)` ✅ (ran live end-to-end),
  `CodeQL` ✅, `Analyze (actions)` ✅.
- Live receipt from the new workflow:
  `Resolved "macOS System Health Roadmap" (#3) -> PVT_kwHOAQEwMM4BcHim` /
  `Read-back confirmed: PR #58 is on "macOS System Health Roadmap" (#3)`.

**Done / owed accounting:**
- DONE: workflow rewrite, fail-loud paths (secret / project-not-found / read-back),
  read-back verification, bounded retry, actionlint clean, CHANGELOG entry,
  branch pushed, draft PR #58 opened with full metadata, PR on Project #3.
- ALREADY SATISFIED (not owed): `PROJECT_METADATA_TOKEN` secret exists (created
  2026-07-21T05:22:01Z). The seed assumed this was owed; it is not.
- OWED (optional follow-up, not blocking): a forced project-not-found spot-check
  to exercise the fail-loud branch; retiring the `CONTRIBUTING.md` manual fallback.

**Merge signal: HOLD** — draft PR, awaiting the PM thread's independent read-back
and **GREEN LIGHT** before the maintainer squash-merges via the GUI.

---

## 1. PM independent read-back (PM lane — verify, don't merge)

```fish
gh pr view 58 --json title,isDraft,labels,milestone,assignees,projectItems,body
gh pr checks 58
gh run view 29804542610 --log | grep -E "Resolved |Add mutation issued|Read-back confirmed"
```
Verify: labels = area:governance,type:bug,priority:high,effort:small,status:ready,risk:medium;
milestone v1.0; assignee Jared-Godar; PR on "macOS System Health Roadmap"; body has `Closes #57`.

## 2. Mark PR ready + PM GREEN LIGHT

Once the PM read-back is clean, take the PR out of draft and announce GREEN LIGHT:

```fish
gh pr ready 58
gh pr checks 58   # confirm required checks (checks, GitGuardian) still green
```
Verification: `gh pr view 58 --json isDraft --jq .isDraft` → `false`.

## 3. Maintainer merges (GUI, on GREEN LIGHT only)

Squash-merge PR #58 via the GitHub GUI. (Do not merge from the CLI unless Jared
prefers it: `gh pr merge 58 --squash --delete-branch`.)

Verification:
```fish
gh pr view 58 --json state,mergedAt --jq '{state: .state, mergedAt: .mergedAt}'
gh issue view 57 --json state --jq .state   # expect CLOSED
```

## 4. Post-merge closure (unprompted, canonical)

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git switch main
git fetch --prune origin
git merge --ff-only origin/main
# copy any session artifacts out of the worktree first (walkthroughs/handoffs):
cp -R .claude/worktrees/fix-issue-57-project-board-gate/artifacts/ artifacts/ 2>/dev/null; or true
# remove the worktree + branch (squash breaks -d ancestry, so -D):
git worktree remove .claude/worktrees/fix-issue-57-project-board-gate --force
git branch -D fix/issue-57-project-board-gate
git push origin --delete fix/issue-57-project-board-gate 2>/dev/null; or true
```
Verification:
```fish
git status --short          # clean
git branch --list 'fix/issue-57-*'   # empty
gh project item-list 3 --owner Jared-Godar --format json | \
  string match -q '*"#58"*'; and echo "PR #58 on board"
```
Confirm the board Status of PR #58 and issue #57 is `Done` (set in the GUI or via
`gh project item-edit`), per AGENTS.md post-merge closure.

## Open risks / watch-items

- The fail-loud *failure* branch (project-not-found) is not yet exercised in CI —
  only the success path is proven. A disposable forced-failure spot-check would
  close that gap.
- `CONTRIBUTING.md` still documents a manual board-add fallback; now that the
  automation is proven live it can be retired in a follow-up PR.
- Board Status field for PR #58 is unset (Todo default) — PM to curate; this fix
  deliberately does not populate board field values (spec non-goal).

## Links

- PR: https://github.com/Jared-Godar/macos-system-health/pull/58
- Issue: https://github.com/Jared-Godar/macos-system-health/issues/57
- Project #3: https://github.com/users/Jared-Godar/projects/3
- Spec: `prompts/issue-57-project-board-gate.md`
