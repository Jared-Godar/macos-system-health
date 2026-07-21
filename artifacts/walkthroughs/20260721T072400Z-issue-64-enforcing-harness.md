# Continuity walkthrough — Issue #64: make smoke-test assertions enforcing

Fill-in-the-rails steps to finish the branch/PR workflow by hand if this session
dies. All commands are **Fish**, runnable from the repository root. Secrets: none.

## State snapshot

- **Issue:** #64 — `tests/smoke.sh` intermediate assertions non-enforcing (audit #59 finding A1)
- **Branch:** `fix/issue-64-enforcing-harness` (worktree under `.claude/worktrees/issue-64-enforcing-harness`)
- **Milestone:** Remediation - Back to Step 0 (#2)
- **Labels:** `area:script` `type:bug` `priority:high` `effort:small` `status:ready` `risk:medium`
- **Assignee:** Jared-Godar
- **PR:** #66 (draft) — link https://github.com/Jared-Godar/macos-system-health/pull/66
- **Gates run this session:** `scripts/check --all` → GREEN (exit 0); smoke suite 42 passed / 0 failed.

## What changed (done, receipts in PR body)

1. `tests/smoke.sh` — `run_test` now runs the test without an `if`-condition and checks a
   per-test failure flag (`CURRENT_TEST_FAILED`) raised by `assert_*`, so intermediate
   assertions gate. Added self-test `test_harness_enforces_intermediate_assertions`.
2. `tests/smoke.sh` — stubs default `CALL_LOG` to `/dev/null` so direct-invocation tests
   don't inject stderr into captured output.
3. `bin/system-health` — `redact_stream` passes needles via `ENVIRON` not `awk -v`, so a
   newline in the captured Conda base can no longer crash redaction (surfaced by #64).
4. `CHANGELOG.md` — two `### Fixed` entries under `[Unreleased]`.
5. `prompts/issue-64-test-harness-enforcing.md` — the build spec, committed on this branch.

## Next steps (each block is copy-pasteable Fish + a verification command)

### 1. Confirm gate is green

```fish
cd (git rev-parse --show-toplevel)
scripts/check --all
```
Verify: last line `All checks passed.` and `42 passed; 0 failed`.

### 2. Confirm the commit is present

```fish
git log --oneline -1
git show --stat HEAD
```
Verify: HEAD subject references #64; touches `tests/smoke.sh`, `bin/system-health`,
`CHANGELOG.md`, `prompts/issue-64-test-harness-enforcing.md`.

### 3. Push the branch (GATED — maintainer go-ahead)

```fish
git push -u origin fix/issue-64-enforcing-harness
```
Verify:
```fish
git rev-parse --abbrev-ref '@{u}'
```
prints `origin/fix/issue-64-enforcing-harness`.

### 4. Open the draft PR with full metadata (GATED — maintainer go-ahead)

```fish
gh pr create --draft \
  --base main --head fix/issue-64-enforcing-harness \
  --title "Make tests/smoke.sh assertions enforcing (Issue #64)" \
  --assignee Jared-Godar \
  --milestone "Remediation - Back to Step 0" \
  --label "area:script" --label "type:bug" --label "priority:high" \
  --label "effort:small" --label "status:ready" --label "risk:medium" \
  --body-file /Users/jaredgodar/.claude/jobs/9e7da9d3/tmp/pr-body.md
```
Verify:
```fish
gh pr view --json number,labels,milestone,assignees,projectItems
```

### 5. Confirm CI + project membership, then HOLD for PM GREEN LIGHT

```fish
gh pr checks (gh pr view --json number -q .number)
```
Verify: `quality` check present and passing; PR appears under the
"macOS System Health Roadmap" project. Then **HOLD** — do not merge; the
maintainer merges via the GUI only on the PM's GREEN LIGHT.

### 6. Post-merge closure (after maintainer squash-merges)

```fish
gh pr view 66 --json state,mergedAt
gh issue view 64 --json state
git switch main; and git fetch --prune; and git pull --ff-only
git branch -D fix/issue-64-enforcing-harness
git worktree remove .claude/worktrees/issue-64-enforcing-harness
```
Verify: PR `MERGED`, issue #64 `CLOSED`, `main` fast-forwarded, branch + worktree gone,
board Status of PR and #64 is `Done`.

## Open risks / watch-items

- The redaction hardening (#3) is a product change surfaced by the enforcing harness; it is
  covered by the now-enforcing `test_cleanup_dry_run_no_delete` (`[DRY-RUN]` assertion) but
  no dedicated unit test asserts the multiline-needle case directly. Low risk — the ENVIRON
  path is strictly more robust than `awk -v`.
- `capture_output_timed`'s `2>&1` merge (the reason the needle went multiline) is unchanged;
  #61 (timeout mis-scaling) touches the same helper and is deliberately out of scope here.
