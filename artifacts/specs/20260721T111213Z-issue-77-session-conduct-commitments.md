# Spec: Land seven session-conduct commitments in AGENTS.md (Issue #77)

**Closes:** #77 · **Milestone:** Remediation - Back to Step 0
**Labels:** `type:docs`, `area:governance`, `priority:high`, `effort:medium`, `status:ready`, `risk:high`
**Assignee:** Jared-Godar · **Project:** macOS System Health Roadmap
**Sizing:** `--model opus --effort high` — Heavy. Judgment work on the repo's binding contract, with a
consolidation decision that requires reading the whole file and weighing it against the design goal.

---

## 0. Read the durable contracts first (non-negotiable)

Before writing anything, read and follow, in order:

1. **`AGENTS.md` on `main`** — the binding contract, currently 15 standing commitments / 23,323 bytes.
   Read the whole thing; this task requires knowing what is already there.
2. `CLAUDE.md` at the repo root — four non-negotiables.
3. `~/.claude/CLAUDE.md` — the maintainer's cross-project standing rules.
4. `CONTRIBUTING.md`.
5. **Issue #77 in full** — it contains the verbatim text for all seven commitments and the specific
   failure each traces to. That issue is the authoritative content source; this spec is the process.

**The rules that will bite you on this specific task:**

- **Receipts expire on the next mutation.** Commit first, gate second, report third. Never gate →
  commit → report.
- **Four gated actions need per-instance go-ahead: push, open PR, merge, release-tag.** Stop and ask
  before `git push` and before `gh pr create`. Never merge.
- **No contract-lawyering.** Read each criterion for its high-quality spirit; ambiguity resolves
  toward more rigor. A criterion that cannot be met is a **finding to report, never a criterion to
  drop**. Do not add escape hatches.
- **Specs are immutable after handoff.** This file is read-only to you. If it is wrong, say so —
  do not edit it.
- **Always pass `-R Jared-Godar/macos-system-health`** on every `gh` write. The Bash tool's working
  directory persists between calls; on 2026-07-21 that caused a write to a merged PR in the wrong repo.

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
day. Five have **zero** repo surface; two were parked in #67 and moved here. Verified:

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

## 3. The design decision you must make and justify

`AGENTS.md` is at **15 standing commitments, 23,323 bytes**. Appending seven more bullets verbatim
takes it to 22 and roughly 27–28 KB — approaching `ecg_anomaly_detection/AGENTS.md` (26 KB), which
this repo's contract was **explicitly designed not to replicate** (see #55: *"ecg's AGENTS.md is
intentionally over-governed — do NOT replicate its scale"*).

But the opposite failure already happened once: PR #56 shipped a contract at 52% of its baseline by
dropping rules, and disclosed only the omissions that suited the story (#69/#70). **Do not resolve
this by dropping content.**

Choose an approach and justify it in the PR body:

- **(a) Append all seven as separate bullets.** Faithful, simplest to verify, largest growth.
- **(b) Consolidate where rules genuinely share a subject**, preserving every clause. Candidates:
  rules **3 + 4** are both about estimates; rules **5 + 6 + 7** are all lane-boundary rules and may
  read better as one "lane discipline" commitment with sub-points, or as a short subsection.
- **(c) A new `## Session conduct` section** holding these seven, leaving `## Standing commitments`
  at its current size.

Whatever you choose, **no clause may be lost**. The acceptance criteria below check for the substance
of each rule, not for a specific bullet count. If consolidating makes any rule weaker or ambiguous,
that rule stays standalone.

## 4. Scope and deliverables

1. **All seven commitments in `AGENTS.md`**, using the verbatim text in #77 as the content source,
   adapted to the file's voice but **not weakened**.
2. **Rule 2 reconciled** with the existing HOLD/GREEN LIGHT language rather than duplicating it.
3. **Rule 6 carries both lists** — the no-permission-needed list (issues, labels, milestones, board,
   comments, authoring specs, memory) *and* the propose-and-wait list (running tests or gates,
   touching code or repo state, cloning-and-testing, launching agents or workflows, verifying by
   doing rather than by reading back). Rule 6 is meaningless without both halves.
4. **Root `CLAUDE.md` decision.** It currently carries four non-negotiables. Does any of these seven
   belong there? Decide and record the reasoning either way — an explicit "no, and here is why" is a
   complete answer. Do not silently skip it.
5. **CHANGELOG** entry under `[Unreleased]`.

## 5. Execution rails

Fish syntax, from the repo root. Each step followed by its verification.

### Step 1 — Sync and branch, before any edit

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git status --short; and git log --oneline -1
git switch -c govern/issue-77-session-conduct
git branch --show-current
```

Expected: clean tree, `main` at `302c779` or later.

### Step 2 — Record the baseline, so growth is measurable

```fish
wc -c AGENTS.md
sed -n '/## Standing commitments/,/## Roles/p' AGENTS.md | grep -c '^- \*\*'
```

Expected: `23323` and `15`. Put both the before and after numbers in the PR body.

### Step 3 — Implement, per your §3 decision

### Step 4 — Verify every rule landed

```fish
for t in "answer the question" "keep progress visible" "bounded range" "decision input" "in-flight" "await approval" "both directions"
  printf '%-28s %s\n' $t (grep -ic $t AGENTS.md)
end
```

Every count must be non-zero. If your consolidation changed a phrase, adapt the probe **and say so** —
do not report a passing probe for wording you altered without disclosing it.

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

Wait for go-ahead, then use §6.

## 6. PR metadata (all at creation time)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Land seven session-conduct commitments in AGENTS.md (#77)" \
  --assignee Jared-Godar \
  --milestone "Remediation - Back to Step 0" \
  --label type:docs --label area:governance --label priority:high \
  --label effort:medium --label status:ready --label risk:high \
  --body "Closes #77

<your §3 decision and why; before/after byte and commitment counts; a table mapping each of the
seven rules to where it landed; the CLAUDE.md decision and its reasoning; the §4 probe output;
scripts/check output from the committed state>"
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

## 7. Checkpoints (all four)

1. **Branch ready** — branch name, clean tree, baseline byte/commitment counts.
2. **PR created (CRITICAL)** — PR number/URL, full metadata read-back, your §3 decision and its
   justification, the rule-to-location table, the §4 probe output.
3. **CI green** — `gh pr checks` output.
4. **After merge** — PR `MERGED`, #77 `CLOSED`, `main` fast-forwarded, branch deleted, `status:*`
   stripped from #77, board Status `Done`.

Between 2 and 4 the PR is under merge **HOLD**. You do not merge and do not declare merge-readiness;
the PM re-runs a sample of your receipts and announces **GREEN LIGHT**.

## 8. Non-goals

- Not restating rules already on `main` — done-means-done, calibrated claims, receipts-expire-on-the-
  next-mutation, floor-not-ceiling, disclose-every-omission.
- Not touching `bin/`, `lib/`, `tests/`, `.githooks/`, or CI workflow logic. Governance text only.
- Not weakening any of the seven to make the file shorter. Consolidate structure, never substance.
- Not editing this spec.

## 9. Dependencies

Ahead of #67 in the governance queue: conduct rules that do not reach executors are why the same
behaviours keep being re-litigated, whereas #67's template defect propagates only to newly authored
specs, which the PM is currently writing by hand from the two shipped exemplars. Remaining queue
after this: #67, #68, #76, #51, #54 → #52 → #53, #31, then #74's independent review. **All behavioral
work (#60/#61/#62) stays blocked until that queue completes** — see #74.

## 10. References

- **#77** — authoritative content: verbatim text for all seven rules, and the failure each traces to
- #67 (rules 2 and 7's status half were moved here from it), #76, #74
- #55 / PR #56 — the under-scoped contract; #69/#70/PR #72 — the restoration
- `AGENTS.md` on `main` at `302c779`
