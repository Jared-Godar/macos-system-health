# Spec: Land seven session-conduct commitments in AGENTS.md (Issue #77) — v2

**Supersedes:** `artifacts/specs/20260721T111213Z-issue-77-session-conduct-commitments.md`
(handed to the maintainer, never launched; retained unedited as the record). **Execute this file,
not that one.** Both are committed with the PR so the supersession is visible.

**Why superseded:** v1 made file length a design tension and asked the executor to choose between
appending all seven rules and consolidating them to keep `AGENTS.md` short. The maintainer struck
that: *"I don't care if it is twice as long as ECG — I just care if you do what you say you're
going to do and did what you say you did."* Length is **not** a constraint. The §3 decision is
removed; append all seven in full.

**Closes:** #77 · **Milestone:** Remediation - Back to Step 0
**Labels:** `type:docs`, `area:governance`, `priority:high`, `effort:medium`, `status:ready`, `risk:high`
**Assignee:** Jared-Godar · **Project:** macOS System Health Roadmap
**Sizing:** `--model sonnet --effort high` — Standard. With the consolidation judgment removed, this
is faithful transcription plus one reconciliation and one recorded decision.

---

## 0. Read the durable contracts first (non-negotiable)

Before writing anything, read and follow, in order:

1. **`AGENTS.md` on `main`** — the binding contract, currently 15 standing commitments / 23,323 bytes.
2. `CLAUDE.md` at the repo root — four non-negotiables.
3. `~/.claude/CLAUDE.md` — the maintainer's cross-project standing rules.
4. `CONTRIBUTING.md`.
5. **Issue #77 in full** — the authoritative content source: verbatim text for all seven
   commitments and the specific failure each traces to. This spec is process; #77 is content.

**The rules that will bite you on this specific task:**

- **Say what you mean, mean what you say, done means done.** This task exists because rules were
  written and not followed. Do not report a step complete that you have not executed and verified
  this session, and do not describe the result as something other than what you did.
- **Receipts expire on the next mutation.** Commit first, gate second, report third.
- **Four gated actions need per-instance go-ahead: push, open PR, merge, release-tag.** Stop and ask
  before `git push` and before `gh pr create`. Never merge.
- **No contract-lawyering.** Read each criterion for its high-quality spirit; ambiguity resolves
  toward more rigor. A criterion that cannot be met is a **finding to report, never a criterion to
  drop**. Do not add escape hatches.
- **Specs are immutable after handoff.** This file is read-only to you. If it is wrong, say so.
- **Always pass `-R Jared-Godar/macos-system-health`** on every `gh` write.

## 0b. Progress tracking

Maintain a live task list — one item per §4 step plus each acceptance criterion — moving each to
in-progress/done as you go. Use **TodoWrite** if available. If TodoWrite is unavailable, say so once,
then **re-post the full checklist as inline markdown at the top of every response that starts or
finishes a step**, marking `[x]` done / `[~]` in-progress / `[ ]` todo. Do not let more than one tool
batch pass without a refreshed checklist.

---

## 1. Intended outcome

Seven session-conduct rules that currently live **only in PM agent memory** reach every session type.
Agent memory does not reach executor, cold-start, or cloud sessions; `AGENTS.md` is the only surface
that does. Until they land there, every new session re-learns them by failing.

## 2. Current state and gap

All seven were agreed with the maintainer on 2026-07-21 and each traces to a specific failure that
day. Five have **zero** repo surface; two were moved here from #67. Verified on `main` at `302c779`:

```
$ grep -ic "answer the question" AGENTS.md      -> 0
$ grep -ic "keep progress visible" AGENTS.md    -> 0
$ grep -ic "bounded range" AGENTS.md            -> 0
$ grep -ic "decision input" AGENTS.md           -> 0
$ grep -ic "in-flight" AGENTS.md                -> 0
$ grep -ic "await approval" AGENTS.md           -> 0
$ grep -ic "both directions" AGENTS.md          -> 0
```

**One partial overlap to reconcile rather than duplicate:** `grep -ic "merge signal"` returns **1** —
`AGENTS.md` already uses HOLD/GREEN LIGHT language in the canonical work-item flow. Rule 2 asserts
"`HOLD` is a merge signal and never a status on its own." Integrate with the existing wording; do not
create a second, competing definition of HOLD.

## 3. Scope and deliverables

**Length is explicitly not a constraint.** Do not consolidate, compress, or trim to keep the file
short. If `AGENTS.md` ends up twice the size of ECG's, that is an acceptable outcome. Completeness
and fidelity are the only targets.

1. **All seven commitments in `AGENTS.md`**, using the verbatim text in #77. Adapt only to match the
   file's voice and formatting — **no clause may be dropped, softened, or merged away.** Each of the
   seven is its own bullet.
2. **Rule 2 reconciled** with the existing HOLD/GREEN LIGHT language rather than duplicating it.
3. **Rule 6 carries both lists** — the no-permission-needed list (issues, labels, milestones, board,
   comments, authoring specs, memory) *and* the propose-and-wait list (running tests or gates,
   touching code or repo state, cloning-and-testing, launching agents or workflows, verifying by
   doing rather than by reading back). Rule 6 is meaningless without both halves.
4. **Root `CLAUDE.md` decision.** It carries four non-negotiables. Does any of these seven belong
   there? Decide and record the reasoning either way — an explicit "no, and here is why" is a
   complete answer. Do not silently skip it.
5. **CHANGELOG** entry under `[Unreleased]`.
6. **Commit both spec files** — this one and the superseded v1 — so the supersession is on the record.

## 4. Execution rails

Fish syntax, from the repo root. Each step followed by its verification.

### Step 1 — Sync and branch, before any edit

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git status --short; and git log --oneline -1
git switch -c govern/issue-77-session-conduct
git branch --show-current
```

Expected: `main` at `302c779` or later, and two untracked files under `artifacts/specs/` (v1 and v2).

### Step 2 — Record the baseline so growth is measurable and reportable

```fish
wc -c AGENTS.md
sed -n '/## Standing commitments/,/## Roles/p' AGENTS.md | grep -c '^- \*\*'
```

Expected `23323` and `15`. Report before and after in the PR body — as a fact, not a concern.

### Step 3 — Implement

### Step 4 — Verify every rule actually landed

```fish
for t in "answer the question" "keep progress visible" "bounded range" "decision input" "in-flight" "await approval" "both directions"
  printf '%-28s %s\n' $t (grep -ic $t AGENTS.md)
end
```

Every count must be non-zero. If your wording differs from the probe string, **adapt the probe and
say so explicitly** — do not report a passing probe for wording you altered without disclosing it.
Paste the output.

### Step 5 — Gate, on the committed state

```fish
git add -A
git status --short
git commit -m "Land session-conduct commitments in AGENTS.md (#77)"
scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"
tail -1 /tmp/g.log
```

Expected both `exit=0`. **Commit first, gate second, report third.**

### Step 6 — STOP: push is gated

Report and wait for explicit go-ahead. Then push and verify the remote ref.

### Step 7 — STOP: opening the PR is gated

Wait for go-ahead, then use §5.

## 5. PR metadata (all at creation time)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Land seven session-conduct commitments in AGENTS.md (#77)" \
  --assignee Jared-Godar \
  --milestone "Remediation - Back to Step 0" \
  --label type:docs --label area:governance --label priority:high \
  --label effort:medium --label status:ready --label risk:high \
  --body "Closes #77

<a table mapping each of the seven rules to where it landed; before/after byte and commitment
counts; how rule 2 was reconciled with the existing HOLD wording; the CLAUDE.md decision and its
reasoning; the §4 probe output; scripts/check output from the committed state; note that v1 of the
spec was superseded before launch and both files are committed>"
```

All six labels verified present in `.github/labels.json` (PM-verified 2026-07-21). There is no
`area:testing` and no `status:in-progress` in this repo's schema.

Verify:

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], closes:(.body|test("Closes #77"))}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

## 6. Checkpoints (all four)

1. **Branch ready** — branch name, clean tree, baseline byte/commitment counts.
2. **PR created (CRITICAL)** — PR number/URL, full metadata read-back, the rule-to-location table,
   the §4 probe output, the `CLAUDE.md` decision.
3. **CI green** — `gh pr checks` output.
4. **After merge** — PR `MERGED`, #77 `CLOSED`, `main` fast-forwarded, branch deleted, `status:*`
   stripped from #77, board Status `Done`.

Between 2 and 4 the PR is under merge **HOLD**. You do not merge and do not declare merge-readiness;
the PM re-runs a sample of your receipts and announces **GREEN LIGHT**.

## 7. Non-goals

- Not restating rules already on `main` — done-means-done, calibrated claims, receipts-expire-on-the-
  next-mutation, floor-not-ceiling, disclose-every-omission.
- Not touching `bin/`, `lib/`, `tests/`, `.githooks/`, or CI workflow logic. Governance text only.
- **Not shortening `AGENTS.md`** or trading fidelity for brevity.
- Not editing either spec file.

## 8. Dependencies

Ahead of #67 in the governance queue. Remaining after this: #67, #68, #76, #51, #54 → #52 → #53,
#31, then #74's independent review. **All behavioral work (#60/#61/#62) stays blocked until that
queue completes** — see #74.

## 9. References

- **#77** — authoritative content for all seven rules
- v1 of this spec: `artifacts/specs/20260721T111213Z-issue-77-session-conduct-commitments.md`
- #67 (rules 2 and 7's status half moved here from it), #76, #74
- #55 / PR #56 — the under-scoped contract; #69/#70/PR #72 — the restoration
- `AGENTS.md` on `main` at `302c779`
