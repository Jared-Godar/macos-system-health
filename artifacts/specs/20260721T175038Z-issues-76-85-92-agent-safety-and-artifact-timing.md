# Spec: Land the agent-safety rules and fix the artifact-timing collisions (Issues #76, #85, #92)

**Closes:** #76, #85, #92 · **Milestone:** Remediation - Back to Step 0
**Labels:** `area:governance`, `priority:high`, `type:docs`, `effort:medium`, `status:ready`, `risk:medium`
**Assignee:** Jared-Godar · **Project:** macOS System Health Roadmap
**Sizing:** `--model opus --effort high`

> **Sizing rationale.** The ladder's "Heavy" rung is *"anything touching an irreversible or
> public-facing surface."* This PR edits `AGENTS.md` — the contract every future session is bound by,
> including the session making the edit. The failure mode is not difficulty; it is **silently
> weakening a rule while rewording it**, which review catches poorly because the diff looks like
> prose polish. Most of the text already exists in the issue bodies, so this is closer to assembly
> than authorship — `sonnet high` would be a defensible call and would cost less. The rung is chosen
> for the consequence of a quiet regression, not the difficulty of the writing.

> **PLACEMENT NOTE.** This spec is already at its canonical path,
> `artifacts/specs/20260721T175038Z-issues-76-85-92-agent-safety-and-artifact-timing.md`, untracked
> on `main`. **Do not copy or move it. Commit it with your PR.**

---

## 0. Read the durable contracts first (non-negotiable)

Before writing anything, read and follow, in order:

1. **`AGENTS.md` on `main` in full** — all 22 standing commitments, not a skim. **You are editing
   this file**, so you must know what is already in it before adding to it.
2. `CLAUDE.md` at the repo root (89 lines, mirrors 11 of those 22).
3. `~/.claude/CLAUDE.md` — the maintainer's cross-project standing rules.
4. `CONTRIBUTING.md`.
5. **Issues #76, #85, and #92 in full, including every comment.** #92 has two comments that extend
   its scope materially; the second records a measurement you will need.

**The rules that will bite you on this specific task:**

- **The diff is additive except where §3c requires otherwise.** You are editing the contract you
  operate under. Do not reword, compress, or "clean up" an existing rule while you are in there. If
  an existing rule looks wrong, that is a finding to report — not an edit to make.
- **No contract-lawyering.** A criterion you cannot meet is a finding to report, never one to drop.
  AC9 in particular may not be satisfiable; say so with evidence rather than inventing an answer.
- **Receipts expire on the next mutation.** Order is mutate → commit → gate → report.
- **Four gated actions need per-instance go-ahead: push, open PR, merge, release-tag.** Never merge.
- **Specs are immutable after handoff.** This file is read-only to you.
- **Always pass `-R Jared-Godar/macos-system-health`** on every `gh` write.
- **A shell variable holding `-R owner/repo` will silently mangle the flag.** Write `-R` inline on
  every command. (The PM did exactly this an hour ago; nine writes failed and an `echo` printed
  success over them. Do not trust an exit code you did not check.)

## 0b. Progress tracking

Maintain a live task list — one item per §5 step plus each numbered acceptance criterion — moving
each to in-progress/done as you go. Use **TodoWrite** if available. If TodoWrite is unavailable, say
so once, then **re-post the full checklist as inline markdown at the top of every response that
starts or finishes a step**, marking `[x]`/`[~]`/`[ ]`. Do not let more than one tool batch pass
without a refreshed checklist.

---

## 1. Intended outcome

Three failures that have already happened once each — an agent committing to a live branch it was
merely told not to touch; a fan-out whose declared size was false and whose isolation silently
degraded; and required artifacts landing on `main` as blank forms — are answered by rules on the
surfaces that reach every session, plus explicit decisions where the issues demand one.

## 2. Current state and gap

### 2a. Neither agent-safety rule exists anywhere

```
$ grep -n -i "isolat\|fan-out\|worktree\|clone" AGENTS.md
39:  no branch, and a clean worktree is the state of both "never started" and
173:  clone-and-test its uncommitted state. **Verification begins at its
286:   breaks `-d`'s ancestry check) and remove their worktrees — copying any
448:- **Worktrees share a branch namespace.** …
450:  Verify refs after worktree operations.
461:  throwaway worktree — so the state the maintainer sees matches the session's.
```

Every hit is about git worktrees or the PM lane. **Nothing about isolating subagents, nothing about
bounding a fan-out, nothing about committing before launching one.** Both incidents (#76's stray
`bad.sh` commit on an open PR's branch; #85's `args.clone` arriving `undefined` and four reviewers
silently falling back to the live checkout) are unprevented today.

### 2b. The artifact-timing rules have no compliant path

Measured on `main` across two consecutive PRs:

| | PR #90 walkthrough | PR #97 walkthrough |
|---|---|---|
| unresolved `⟨slots⟩` | 13 | 5 |
| `⟨status⟩` (no outcome recorded) | 6 | 0 |

`AGENTS.md` requires a walkthrough refresh at "awaiting merge." Under PR-only, the values that
refresh would fill (PR number, check context, merge SHA) only exist after the last commit on the
branch — so there is nowhere for the refresh to land without a second PR or a force-push.

The same root breaks the handoff rule in the other direction: `AGENTS.md` says write handoffs to
`artifacts/session-handoffs/`, `.gitignore` line 78 says `artifacts/` is deliberately **tracked**,
and the PM lane forbids the PM writing repo files outside `artifacts/specs/`. A PM that follows the
handoff rule breaks the lane; one that follows the lane produces no handoff. There is no compliant
path — this is a live contradiction, not a preference.

### 2c. The `CLAUDE.md` mirror carries a hard-coded count — the trap in this PR

```
$ grep -n "eleven" CLAUDE.md AGENTS.md
CLAUDE.md:5:its auto-load of `AGENTS.md` is tool/version dependent. It mirrors the eleven
AGENTS.md:469:- **`CLAUDE.md`** at the repo root mirrors this file's eleven non-negotiables
```

Both files assert "eleven," and `AGENTS.md:469` **enumerates** them. Adding a mirrored rule without
updating both the number and the enumeration leaves the two surfaces contradicting each other — the
exact drift `CLAUDE.md`'s own preamble says must never happen. See AC7.

## 3. Deliverables

### 3a. #76 — isolate agents, do not instruct them

Add to `AGENTS.md` § Standing commitments. The issue body carries the agreed text; use it, adapting
only to match surrounding voice:

> - **Isolate agents; do not instruct them.** Never point a subagent or workflow at the live working
>   checkout and rely on a prompt telling it not to mutate state — that is a request, not
>   containment. Isolate structurally: clone to `/tmp` (adding `origin/main` for diffing) or pass
>   `isolation: 'worktree'`. A reviewer only needs to *read* a diff, so a clone is always
>   sufficient; no adversarial reviewer needs write access to a real branch. If agents are already
>   running against a live surface, **stop the run** rather than hoping, then verify the surface —
>   `HEAD` vs `origin`, clean tree, no stray local or remote scratch refs, expected file list on the
>   PR — before relaunching. Discarded in-flight work is cheap; an unexplained commit on an open PR
>   is not.

**Plus a recorded decision** (#76's third AC): should agent-created commits carry a distinguishing
trailer or committer identity? **Implement it or decline it with reasoning** — leaving it undecided
is not an option. Note that *implementing* attribution is **#89**'s scope; a decision here that says
"yes, and #89 carries it" is a complete answer. A decision that says "no, because…" is also
complete. Silence is not.

### 3b. #85 — fan-out bounds, launch hygiene, and self-verifying isolation

Three rules, all to `AGENTS.md` § Standing commitments. Draft from the issue's §4; the substance is
fixed, the wording is yours:

1. **A fan-out may be described as bounded only if** the agent type cannot spawn sub-agents, **or**
   spawning is forbidden in the prompt *and* verified in the transcript afterward. Otherwise report
   the ceiling as **unbounded and say so**. Cardinality analysis of a script is necessary and not
   sufficient — `general-purpose` and `claude` both carry the `Agent` tool.
2. **Commit all work before launching any agent or workflow against a repository**, including
   read-only ones. This is the cheap safeguard that contained the #85 incident.
3. **Isolation must self-verify.** The first agent echoes the absolute path it is working in; an
   unset or missing target is a **hard abort, never a fallback**. Configured isolation that
   degrades to the live repository without erroring is worse than none, because it manufactures
   confidence.

**Plus a recorded decision** (#85's §4.4): should a non-spawning agent type be the default for
review fleets in this repo? Decide and record.

### 3c. #92 — one decision governing both artifact timings

**This is the only place the diff is not purely additive.** The existing walkthrough rule in
§ Standing commitments changes, and the handoff destination rule may.

Choose and record one option for the walkthrough refresh. **The PM recommends option 1**, and #92's
second comment sets out why plus the residual question it must answer:

1. Redefine "awaiting merge" as **before the final commit on the branch**. Everything knowable then
   gets filled; only the merge SHA and closure receipts remain, **explicitly marked as deliberate**
   so blank-on-purpose is distinguishable from abandoned. PR #97's walkthrough is the working
   exemplar — except its five slots (PR number ×2, check context, PR-body pointer, protection
   context) were knowable *before merge* though not before the final commit. Option 1 leaves them
   unresolved permanently; that trade must be stated, not glossed.
2. Allow one amend-and-force-push before merge. **Note the cost:** force-pushing a branch that has
   already gone green under a required check invalidates that receipt.
3. Drop the awaiting-merge refresh entirely and make the walkthrough a pre-work artifact only.

**And resolve the handoff-destination contradiction** from §2b — either an explicitly-permitted
path for PM-authored handoffs, an ignored zone, or the outside-the-repo fallback stated **in
`AGENTS.md` itself** rather than only in `~/.claude/CLAUDE.md`, which executor and cloud sessions
never load. One decision must govern walkthroughs and handoffs consistently; two different answers
recreate the problem.

### 3d. Mirror and changelog

- Mirror the #76 and #85 rules into the root `CLAUDE.md` — they reach every session type, which is
  what that file is for — **and update both count claims and the `AGENTS.md:469` enumeration** (§2c).
- `CHANGELOG.md` entry under `[Unreleased]`.

## 4. Non-goals

- **Not** resolving the 11-vs-22 `CLAUDE.md` mirroring gap. That is #95, which the maintainer has
  deliberately left unscheduled. Update the count to match what you actually mirror; do not
  backfill the other rules.
- **Not** implementing agent-commit attribution (#89) — only deciding whether it should exist.
- **Not** running #74's independent contract review. It is unblocked *by* this PR's rule 3b.1 and
  runs after.
- **Not** touching branch protection, the label policy, or any code under `bin/`, `lib/`, `scripts/`.
- **Not** rewording any existing `AGENTS.md` rule outside §3c.

## 5. Execution rails

Fish syntax, from the repository root.

### Step 1 — Sync and branch

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git status --short; and git log --oneline -1
git switch -c docs/issues-76-85-92-agent-safety
git status --short artifacts/specs/
```

Expected: `main` at `37c4034` or later; the only untracked file under `artifacts/specs/` is this spec.

### Step 1b — Continuity walkthrough, written under the rule you are about to change

Write it per §3c's chosen option, not the current rule. It is the first artifact produced under the
new convention and doubles as the exemplar — say so in the PR body.

### Step 2 — Draft the additions

Read the surrounding bullets first and match their voice, length, and structure. Each new bullet
opens with a **bolded imperative**, like every existing one.

### Step 3 — Verify the diff is additive where it must be

```fish
git diff main -- AGENTS.md | grep '^-' | grep -v '^---'
```

Expected: **empty**, except the §3c walkthrough/handoff lines and the `eleven` count. Any other
removed line is an unintended regression — investigate before proceeding.

### Step 4 — Commit, then gate on the committed state

```fish
git add -A
git status --short
git commit -m "Land the agent-safety rules and fix the artifact-timing collisions (#76, #85, #92)"
/bin/bash scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"
tail -3 /tmp/g.log
```

Expected both `exit=0`, smoke count **46**.

### Step 5 — STOP: push is gated.  ·  Step 6 — STOP: opening the PR is gated.

## 6. PR metadata (all at creation time)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Land the agent-safety rules and fix the artifact-timing collisions (#76, #85, #92)" \
  --assignee Jared-Godar \
  --milestone "Remediation - Back to Step 0" \
  --label area:governance --label priority:high --label type:docs \
  --label effort:medium --label status:ready --label risk:medium \
  --body-file <path>
```

Body must carry: the three decisions with reasoning (attribution, default agent type, #92 option);
the Step 3 additive-diff output; the `eleven`-count update; `scripts/check --all` from the committed
state with its SHA; the CI receipt; and every deferral named (#95, #89, #74, #93).

**Note:** this is the **first PR gated by `label-policy`**, which shipped in #97. It is not yet a
required check — report whether it ran and its result either way.

Verify:

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], c76:(.body|test("Closes #76")), c85:(.body|test("Closes #85")), c92:(.body|test("Closes #92"))}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

## 7. Numbered acceptance criteria

- **AC1.** `AGENTS.md` carries the isolate-don't-instruct rule, including the stop-and-verify
  procedure and the statement that a clone suffices for review and write access is never required.
- **AC2.** A decision on agent-commit attributability is recorded — implemented, or declined with
  reasoning. Not deferred silently.
- **AC3.** `AGENTS.md` carries the fan-out bounding rule, naming that **agent type** determines
  whether a ceiling exists at all, and that an unverifiable ceiling is reported as unbounded.
- **AC4.** `AGENTS.md` carries the commit-before-launch rule, covering read-only runs.
- **AC5.** `AGENTS.md` carries the isolation-self-verifies rule: first agent echoes its absolute
  path; unset target is a hard abort, never a fallback.
- **AC6.** A decision on the default agent type for review fleets is recorded.
- **AC7.** The #76 and #85 rules are mirrored into root `CLAUDE.md`, **and** both `eleven` count
  claims plus the `AGENTS.md:469` enumeration are updated to match. Show `grep -n "eleven"` before
  and after.
- **AC8.** #92's walkthrough option is chosen and recorded in `AGENTS.md`, with the residual
  trade-off stated explicitly rather than glossed.
- **AC9.** The handoff-destination contradiction is resolved **in `AGENTS.md`**, consistently with
  AC8. If no resolution is possible without a decision above your authority, **report that as a
  finding with the specific blocking constraint** — do not drop the criterion.
- **AC10.** `git diff main -- AGENTS.md | grep '^-'` shows no removed line outside §3c's scope.
  Output pasted.
- **AC11.** `/bin/bash scripts/check --all` green on the **committed** state, output pasted, SHA named.
- **AC12.** CI green, with the run receipt. `label-policy`'s result reported explicitly.
- **AC13.** The continuity walkthrough is written under the newly-chosen convention and named in
  the PR body as the first artifact produced under it.
- **AC14.** CHANGELOG entry under `[Unreleased]`.
- **AC15.** Every deferral named in the PR body: #95 (11-vs-22, deliberately unscheduled), #89
  (attribution implementation), #74 (independent review, unblocked by AC3), #93.

## 8. Verification status of the commands in this spec

| Command / claim | Status |
|---|---|
| `grep` showing no isolation/fan-out rules in `AGENTS.md` | **PM-VERIFIED** 2026-07-21 |
| Walkthrough slot counts, 13/6 and 5/0 | **PM-VERIFIED** on `main` at `60780f0` and `37c4034` |
| `grep -n "eleven"` hits in both files | **PM-VERIFIED** |
| `.gitignore` line 78 — artifacts tracked | **PM-VERIFIED** |
| `AGENTS.md` = 488 lines, `CLAUDE.md` = 89 | **PM-VERIFIED** |
| Smoke count 46 | **PM-VERIFIED** from PR #97's body; **not re-run this session** |
| `main` at `37c4034` | **PM-VERIFIED** |
| The Step 3 additive-diff command | **PM-UNVERIFIED** — never run; expected output is reasoned, not observed |
| That `label-policy` will run on this PR | **PM-UNVERIFIED** — it triggers on `pull_request` and is not required; confirm empirically |

## 9. Dependencies and sequencing

- **Unblocks #74's gap 1** — the independent contract review is an agent fan-out, and AC3/AC5 are
  the rules it must run under. Do not run it here.
- **#89** implements attribution if AC2 decides for it.
- **#95** is deliberately unscheduled; do not expand into it.
- **#78** will reorganize procedural docs but not § Standing commitments — no collision.

## 10. References

- **#76** (incident: stray `bad.sh` on an open PR's branch, reflog in the body) · **#85** (run
  `wf_e4fdaf7c-9d5`: false ceiling + silent isolation fallback) · **#92** (two comments extending
  scope; the second carries the two-PR measurement)
- `AGENTS.md` § Standing commitments · root `CLAUDE.md` · `.gitignore` line 78
- Memory: `isolate-agents-never-instruct-them`, `bounded-fanout-or-dont-launch`,
  `workflow-review-isolation-lesson`
