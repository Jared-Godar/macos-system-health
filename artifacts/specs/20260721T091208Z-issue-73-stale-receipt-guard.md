# Spec: Make stale gate receipts impossible (Issue #73)

**Closes:** #73 · **Milestone:** Remediation - Back to Step 0
**Labels:** `type:feature`, `area:governance`, `priority:medium`, `effort:small`, `status:ready`
**Assignee:** Jared-Godar · **Project:** macOS System Health Roadmap
**Sizing:** `--model sonnet --effort high` — Standard. Shell/hook work with a defined scope where
the code must be correct and idiomatic; §3's design decision is the one judgment call.

---

## 0. Read the durable contracts first (non-negotiable)

Before writing anything, read and follow, in order:

1. **`AGENTS.md`** — the binding contract. It was restored to full strength in PR #72; read the
   current `main` version, not a remembered one.
2. `CLAUDE.md` at the repo root — four non-negotiables.
3. `~/.claude/CLAUDE.md` — the maintainer's cross-project standing rules.
4. `CONTRIBUTING.md`.
5. Issue **#73**, including its comments — the mechanism deliverable was added after filing.

**The rules that will bite you on this specific task:**

- **Receipts expire on the next mutation.** This issue exists *because* a gate receipt was taken
  before a later `git add` invalidated it. Do not reproduce the defect while fixing it: the last
  command before you report a gate result is the gate itself, run on the state you are shipping.
- **Done means done, with receipts.** Label every claim **done** / **relayed** / **queued** /
  **owed** / **not done**.
- **Four gated actions need per-instance go-ahead: push, open PR, merge, release-tag.** Stop and
  ask before `git push` and before `gh pr create`. Never merge.
- **No contract-lawyering.** Read each criterion for its high-quality spirit; ambiguity resolves
  toward more rigor. A criterion that cannot be met is a **finding to report, never a criterion to
  drop**. Do not add escape hatches.
- **Always pass `-R Jared-Godar/macos-system-health`** on every `gh` write. The Bash tool's working
  directory persists between calls; on 2026-07-21 that caused a write to a merged PR in the wrong
  repository.

## 0b. Progress tracking

Use **TodoWrite** to create a task list immediately after reading this spec — one item per §5 step
plus each acceptance criterion. If TodoWrite is unavailable in your session, say so explicitly and
track inline; do not skip silently.

---

## 1. Intended outcome

A push carrying a red gate is **refused by the tooling**, so a false-green receipt cannot be
reported for a pushed state. The reporting rule is written into `AGENTS.md` as backup, but the hook
is the actual control — `AGENTS.md`: *"a rule an agent must remember to follow is a hope, not a
guardrail."*

## 2. Current state and gap

On 2026-07-21 an executor reported `scripts/check --all → exit 0` for PR #72's first commit. The run
was genuine **when taken** — before `git add -A`, while `artifacts/` was still gitignored and
therefore invisible to `git show --check HEAD`. That same commit then un-ignored `artifacts/`,
newly tracking three files whose markdown hard-line-breaks trip the whitespace check. On the
committed state the gate was **exit 2** with 14 errors.

CI caught it, but only after a push and a false report:

```
043163a  quality  completed/failure   <- pre-fix state
22c5c39  quality  completed/success   <- shipping state
```

Nobody misreported. The receipt was true about a state that no longer existed when it was cited.
Nothing in the repo prevents that recurring.

Existing pattern to follow — `.githooks/pre-commit`:

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
exec "$ROOT/scripts/check" --staged
```

and `scripts/install-hooks`, which sets `core.hooksPath .githooks`.

## 3. The design decision you must make and justify

`scripts/check --all` inspects the **working tree** (ShellCheck, actionlint, smoke tests) plus
three git checks, one of which — `git show --check --format= HEAD` — inspects only the **tip
commit**. For a pre-push guard that is not automatically the same thing as "the state being
pushed." Two real gaps:

- **Dirty working tree.** If the tree differs from `HEAD`, `--all` tests the tree, not what is
  being pushed — the exact class of mismatch this issue is about.
- **Multi-commit push.** `git show --check HEAD` sees only the tip. `043163a` was red while
  `22c5c39` was green; a range push would have passed the check while carrying a red commit.

Pick an approach, implement it, and **justify it in the PR body**. Acceptable options:

- **(a) Require a clean tree, then run `--all`.** Simple and honest: refuse the push when
  `git status --porcelain` is non-empty, so `--all` genuinely reflects `HEAD`. Cost: blocks pushing
  with unrelated local edits present.
- **(b) Read the pushed range from stdin and check each commit.** Pre-push receives
  `<local-ref> <local-sha> <remote-ref> <remote-sha>` on stdin. Most rigorous; costs a checkout or
  `git stash` dance, which is riskier in a hook.
- **(c) Hybrid** — always run `--all`, plus `git show --check` over the full pushed range, and warn
  loudly on a dirty tree.

Whatever you choose, the **limits of the check must be stated in the failure message and the PR
body**. A guard that silently checks less than it appears to is worse than none.

## 4. Scope and deliverables

1. **`.githooks/pre-push`** — matches the existing hook's style (`#!/usr/bin/env bash`,
   `set -euo pipefail`, resolve `ROOT` via `git rev-parse --show-toplevel`). Refuses the push when
   the gate is red.
2. **Failure message** — names the stale-receipt failure mode, not just the gate output. Tells the
   user what to do: re-run the gate on the committed state, fix, re-commit. States what the check
   does and does not cover per §3. Mentions that `--no-verify` bypasses it.
3. **`--no-verify` stays available.** A guard nobody can override gets disabled wholesale. Say so
   in the message.
4. **`scripts/install-hooks`** — installs the new hook (it already sets `core.hooksPath`, so verify
   the pre-push hook is picked up) and its confirmation message mentions both hooks.
5. **`AGENTS.md`** — add to § Standing commitments:

   > - **Receipts expire on the next mutation.** A gate or test result is a fact about one specific
   >   tree state, not a property of the branch. Any mutation taken afterward — `git add`, a commit,
   >   a `.gitignore` or `.gitattributes` change — voids it. The **last** command before reporting a
   >   gate result is the gate itself, run on the state being shipped: mutate → stage → commit →
   >   **then** gate → report, never gate → commit → report. When a change alters which files are
   >   tracked, assume every prior receipt is stale and re-take all of them. The same rule governs
   >   claims about another session's state — whether a branch is pushed, whether a PR exists —
   >   verify it this turn rather than carrying an assumption forward.

6. **`CONTRIBUTING.md`** — mention the pre-push hook wherever `scripts/install-hooks` is documented,
   if it is.
7. **CHANGELOG** — `[Unreleased]` entry.

## 5. Execution rails

Fish syntax, from the repo root. Each step followed by its verification.

### Step 1 — Sync and branch, before any edit

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git status --short; and git log --oneline -1
git switch -c fix/issue-73-stale-receipt-guard
git branch --show-current
```

Expected: clean tree, `main` at `71cd720` or later.

### Step 2 — Copy this spec into the branch

This spec lives at `artifacts/specs/20260721T091208Z-issue-73-stale-receipt-guard.md`. `artifacts/`
is now **tracked**, so the file is already in place — confirm it is staged with your work:

```fish
git status --short artifacts/specs/
```

### Step 3 — Implement, per your §3 decision

### Step 4 — Prove the guard works (all three receipts required)

```fish
scripts/install-hooks
git config core.hooksPath
```

**(a) A red state is refused.** Create a deliberate gate failure on a throwaway commit, attempt a
push to a scratch ref, paste the refusal, and confirm the ref was not created:

```fish
git ls-remote --heads origin | grep scratch; or echo "no scratch ref - correct"
```

**(b) `--no-verify` overrides.** Show the same push succeeding with `--no-verify` — then delete the
scratch ref immediately:

```fish
git push origin --delete <scratch-ref>
git ls-remote --heads origin | grep scratch; or echo "scratch ref removed"
```

**(c) A green state passes.** The real branch pushes without the hook objecting.

Use a **scratch ref**, never `main`, and never leave one behind. If any receipt cannot be produced,
report it as a finding — do not drop it.

### Step 5 — Gate, on the committed state

```fish
git add -A
git status --short
git commit -m "Add pre-push guard against stale gate receipts (#73)"
scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"
tail -1 /tmp/g.log
```

Expected both `exit=0`. **Commit first, gate second, report third** — that ordering is the whole
point of this issue.

### Step 6 — STOP: push is gated

Report and wait for explicit go-ahead. Then push and verify the remote ref.

### Step 7 — STOP: opening the PR is gated

Wait for go-ahead, then use §6.

## 6. PR metadata (all at creation time)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Add pre-push guard against stale gate receipts (#73)" \
  --assignee Jared-Godar \
  --milestone "Remediation - Back to Step 0" \
  --label type:feature --label area:governance --label priority:medium \
  --label effort:small --label status:ready \
  --body "Closes #73

<what you built; your §3 decision and why; what the guard does and does NOT cover; all three
receipts from §4; the scripts/check output from the committed state>"
```

All five labels verified present in `.github/labels.json` (PM-verified 2026-07-21). There is no
`area:testing` and no `status:in-progress` in this repo's schema.

Verify:

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], closes:(.body|test("Closes #73"))}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

## 7. Checkpoints (all four)

1. **Branch ready** — branch name, clean tree, `main` synced.
2. **PR created (CRITICAL)** — PR number/URL, full metadata read-back, all three §4 receipts, your
   §3 decision and its justification.
3. **CI green** — `gh pr checks` output.
4. **After merge** — PR `MERGED`, #73 `CLOSED`, `main` fast-forwarded, branch deleted, `status:*`
   stripped from #73, board Status `Done`.

Between 2 and 4 the PR is under merge **HOLD**. You do not merge and do not declare
merge-readiness; the PM re-runs a sample of your receipts and announces **GREEN LIGHT**.

## 8. Non-goals

- Not changing `scripts/check`'s own logic beyond what the hook needs. If you believe `check` needs
  a new mode, **propose it** rather than adding one unilaterally.
- Not touching `bin/system-health`, `lib/`, or `tests/` behavior.
- Not weakening or removing the existing `pre-commit` hook or the `prompts/**` spec-immutability
  hook.
- Not making the guard unbypassable.

## 9. Dependencies

First in the governance queue. #67, #68, #51, the #54→#52→#53 label chain, #31, and finally #74's
independent review follow. **All behavioral work (#60, #61, #62) is blocked until that queue
completes** — see #74.

## 10. References

- #73 (this issue, including the mechanism comment), #74 (governance-before-product gate)
- PR #72 — where the stale receipt occurred, disclosed in its body
- `.githooks/pre-commit`, `scripts/install-hooks`, `scripts/check`
- `AGENTS.md` — "Done means done, with receipts"; "prefer the mechanism"
