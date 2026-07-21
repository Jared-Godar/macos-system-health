# Spec: ⟨imperative one-line title⟩ (Issues #⟨A⟩, #⟨B⟩)

> **This is the copy-from template, not a spec.** The `TEMPLATE.md` filename is deliberately *not* a
> `<UTC-timestamp>-issue-<n>-<slug>.md` name, so it is unmistakably not itself a work item. To start
> a real spec: copy this file to
> `artifacts/specs/<UTC-timestamp>-issue-<n>-<slug>.md` (`date -u +%Y%m%dT%H%M%SZ` gives the stamp),
> then fill every ⟨slot⟩ and delete this banner and the parenthetical PM-notes. Leave nothing
> generic: a rule recited but not tailored is worse than no rule, because it reads as covered.

**Closes:** #⟨A⟩, #⟨B⟩ · **Milestone:** ⟨milestone, or "none — deliberately unmilestoned"⟩
**Labels:** `area:⟨…⟩`, `priority:⟨…⟩`, `type:⟨…⟩`, `effort:⟨…⟩`, `status:⟨…⟩`⟨, `risk:⟨…⟩` — required when TYPE is `type:feature`/`type:bug`⟩
**Assignee:** Jared-Godar · **Project:** macOS System Health Roadmap
**Sizing:** `--model ⟨sonnet|opus⟩ --effort ⟨low|medium|high⟩`

> **Sizing rationale, stated honestly.** ⟨Name the rung on `AGENTS.md` § "Model and effort sizing"
> (Light / Standard / Heavy) and the single most-demanding motion in this spec that puts it there.
> If you are recommending one rung up or down, say what specific risk or ease justifies it — the
> maintainer decides on your honest reasoning, not on a default.⟩

> **PLACEMENT.** Once handed over, this spec is already at its canonical path, untracked on `main`.
> The executor does **not** copy or move it — it is committed with the executor's PR exactly as
> authored. (Leaving it untracked in the primary checkout while an executor commits a separate copy
> from a worktree causes a path collision on post-merge `git merge --ff-only`; author at the path
> the executor commits from directly.)

---

## 0. Read the durable contracts first (non-negotiable)

Before writing anything, read and follow, in order:

1. **`AGENTS.md` on `main` in full** — the single binding operating contract: the standing
   commitments, the roles and the four gated actions, the canonical work-item flow, the definition
   of done, and the Fish/macOS local environment. Read it in full, not a skim; every §0 a spec
   imposes on the executor binds the author identically.
2. `CLAUDE.md` at the repo root — the auto-loaded safety-net mirror of `AGENTS.md`'s
   non-negotiables. If it and `AGENTS.md` ever appear to disagree, `AGENTS.md` is authoritative.
3. `~/.claude/CLAUDE.md` — the maintainer's cross-project standing rules (changelog discipline,
   done-means-done, promises-persisted, GitHub metadata governance, continuity walkthrough).
4. `CONTRIBUTING.md` — the day-to-day workflow and the label policy pointer.
5. **Issue(s) #⟨A⟩, #⟨B⟩ in full, including every comment.** ⟨PM: if a comment rewrote the body or
   changed a deliverable, say so here and name which reading is authoritative — an executor handed a
   stale body works the wrong task.⟩

**The rules that will bite you on _this_ task** ⟨PM: REPLACE this list with the 3–6 rules that
actually apply to *this* work — the specific ones an executor would trip on here, drawn from
`AGENTS.md`. Do not ship the generic recital below unedited; a tailored list is the whole point of
this slot. The four starred rules are load-bearing on nearly every task and are safe to keep:⟩

- **★ Four gated actions need the maintainer's explicit per-instance go-ahead: push, open PR, merge,
  release-tag.** Stop and ask before `git push` and before `gh pr create`. **Never merge** — the
  maintainer merges via the GUI, and only after the PM announces **GREEN LIGHT**. Do not declare
  merge-readiness yourself.
- **★ Receipts expire on the next mutation.** A `scripts/check` result is a fact about one tree
  state; `git add`/`git commit` void it. Order is **mutate → commit → gate → report**, every time —
  the gate is the *last* command before you report it.
- **★ No contract-lawyering.** A criterion you cannot meet is a **finding to report, never a
  criterion to quietly drop.** Obligations are read for their high-quality spirit; ambiguity
  resolves toward more rigor, not less.
- **★ Always pass `-R Jared-Godar/macos-system-health` inline on every `gh` command** — never via a
  shell variable, which mangles the flag silently. The Bash working directory persists across tool
  calls, so an untargeted write can land in the wrong repository.
- ⟨task-specific rule, e.g. "the diff must be additive except in §X" / "Bash 3.2 only — no
  `mapfile`, `declare -A`, `${v^^}`" / "this file is hook-protected; move with `git mv`, not
  `Write`"⟩

## 0b. Progress tracking

Maintain a live task list — one item per §4 execution step plus each numbered acceptance criterion —
moving each to in-progress/done as you go. Use **TodoWrite** if available. **If TodoWrite is
unavailable, say so once, then re-post the full checklist as inline markdown at the top of every
response that starts or finishes a step**, marking `[x]` done / `[~]` in-progress / `[ ]` todo. Do
not let more than one tool batch pass without a refreshed checklist. Before any long stretch, post a
one-line "next I am doing X." (The recurrence is the fix: a one-shot inline checklist scrolls away,
so it must be re-posted, not written once.)

---

## 1. Intended outcome

⟨One short paragraph: the checkable end state this PR produces. Write it so "done" is a property
someone can verify, not a judgment call.⟩

## 2. Current state and gap  ⟨or "Decisions — made by the PM, implement as written"⟩

⟨Either the measured baseline this work changes (show the commands and their output — do not assert
a gap you did not measure), or, when the maintainer has already decided the open questions, a
numbered list of decisions the executor implements exactly and does not re-litigate. Mark each
factual claim's provenance; §8 records which you actually ran.⟩

## 3. Deliverables

⟨Numbered, each independently checkable and mapped to the acceptance criterion that proves it. Name
the exact files and the exact behavior. Include the CHANGELOG entry under `[Unreleased]` as a
numbered deliverable — it is a merge gate, not an afterthought.⟩

1. ⟨…⟩
2. **CHANGELOG** entry under `## [Unreleased]` (or an explicit "no changelog entry needed" with
   reason, for docs-only/metadata-only PRs).

## 4. Execution rails

Fish syntax, from the repository root. Each step is followed by its verification command and its
expected output.

### Step 1 — Sync and branch

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git status --short; and git log --oneline -1
git switch -c ⟨type⟩/issues-⟨A⟩-⟨B⟩-⟨slug⟩
git status --short artifacts/specs/   # only the untracked spec for this PR
```

Expected: `main` at ⟨SHA⟩ or later; the only untracked file under `artifacts/specs/` is this spec.

### Step 1b — Continuity walkthrough, immediately after branching

Write the fill-in-the-rails walkthrough now (not on request) to
`artifacts/walkthroughs/<UTC-timestamp>-issue-<n>-<slug>.md`, per `AGENTS.md`'s proactive-walkthrough
rule and the option-1 convention: finalize it *before the final commit on the branch* so it lands on
`main` filled in, leaving only the merge SHA and closure receipts as ⟨slots⟩ tagged deliberate.

### Step 2 … N — ⟨implement the deliverables⟩

⟨One step per logical unit of work, each a copy-pasteable Fish block with its verification. Prove
any new gate/test rejects as well as accepts — a gate only ever seen passing is unproven.⟩

### Step N+1 — Commit, then gate on the committed state

```fish
git add -A
git status --short
git commit -m "⟨imperative subject⟩ (#⟨A⟩, #⟨B⟩)"
/bin/bash scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"
tail -5 /tmp/g.log
```

Expected: both `exit=0`, and the tail showing the smoke-test count. Name the commit SHA the gate ran
against when you report it — the receipt is about that tree state only.

### Step N+2 — STOP: push is gated.  ·  Step N+3 — STOP: opening the PR is gated.

Request approval separately for each. From first push the PR is under merge **HOLD** until the PM's
independent read-back completes and the PM announces GREEN LIGHT.

## 5. PR metadata (all at creation time)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "⟨same as the commit subject⟩ (#⟨A⟩, #⟨B⟩)" \
  --assignee Jared-Godar \
  --milestone "⟨milestone⟩" \
  --label area:⟨…⟩ --label priority:⟨…⟩ --label type:⟨…⟩ \
  --label effort:⟨…⟩ --label status:⟨…⟩ ⟨--label risk:⟨…⟩⟩ \
  --body-file ⟨path⟩
```

**A multi-issue PR repeats the closing keyword before _every_ number** — `Closes #⟨A⟩` and
`Closes #⟨B⟩` (one per line, or a separate `Closes #⟨B⟩`). The combined form `Closes #⟨A⟩, #⟨B⟩`
links **only #⟨A⟩** and silently leaves the rest open. Confirm all labels exist in
`.github/labels.json` and satisfy `.github/label-policy.json` before creating the PR.

**Verify the closure links with the authoritative GraphQL field — never a body text-match.** A body
text-match (a `jq` `.body` regex test) checks what you *typed*; it returns true for the combined form
even though GitHub linked only the first issue. Only `closingIssuesReferences` reflects what GitHub
actually parsed:

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh api graphql -f query='{repository(owner:"Jared-Godar",name:"macos-system-health"){
  pullRequest(number:'$pr'){closingIssuesReferences(first:10){nodes{number state}}}}}' \
  --jq '.data.repository.pullRequest.closingIssuesReferences.nodes[].number'
```

Expected: every issue this PR closes, e.g. `⟨A⟩`, `⟨B⟩`. **`closingIssuesReferences` lags a few
seconds behind `gh pr edit`** — if the first read is short, re-query rather than trusting it. Also
read back the rest of the metadata:

```fish
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title]}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

The PR body carries: every decision restated as implemented; every deliberate scope exclusion and
deferral named with its issue number; the gate output from the **committed** state with its SHA; the
CI receipt; and any AC the spec flagged as possibly unmeetable, reported as a finding rather than
dropped.

## 6. Numbered acceptance criteria

⟨Explicitly numbered, each independently checkable, each naming the command or artifact that
demonstrates it, each mapped to the deliverable it proves. Self-reports against criteria the spec
never defined are unfalsifiable — define them here so the PM has a shared referent. Always include:⟩

- **AC⟨n⟩.** `/bin/bash scripts/check --all` is green on the **committed** state — output pasted, SHA named.
- **AC⟨n⟩.** CI `quality` is green on the pushed branch, with the run receipt; `label-policy`'s result reported.
- **AC⟨n⟩.** `closingIssuesReferences` on the PR returns **every** closed issue number — output pasted.
- **AC⟨n⟩.** CHANGELOG entry under `[Unreleased]`.
- **AC⟨n⟩.** Every deliberately-omitted or deferred item is named explicitly in the PR body.

## 7. Non-goals

⟨What this PR deliberately does not do, each with the issue that owns it if deferred. This is the
disclose-every-omission surface: name what was dropped, weakened, or deferred, not only the
comfortable ones.⟩

## 8. Verification status of this spec's claims

⟨A table: each factual claim / worked example in this spec marked **PM-VERIFIED** (with how) or
**PM-UNVERIFIED** (reasoned, not run). A worked example nobody ran is a liability handed to the
executor — say which is which so the executor knows what to confirm empirically.⟩

| Claim | Status |
|---|---|
| ⟨…⟩ | **PM-VERIFIED** — ⟨command/date⟩ |
| ⟨…⟩ | **PM-UNVERIFIED** — ⟨what is assumed⟩ |

## 9. References

⟨The issues (noting which body is authoritative if rewritten), the exemplar specs, and the exact
files/sections touched: `AGENTS.md` § ⟨…⟩, `scripts/check`, `.github/labels.json`, etc.⟩

---

## Handoff — the launch block the PM hands the maintainer (PM-only; delete before the executor works)

This is **not** part of the executor's spec — it is the canonical two-command block the PM delivers
to the maintainer to launch the work (see `AGENTS.md` § PM thread discipline, "Every executor launch
leaves a record"). Ship both lines in **one** fenced block so the maintainer copies once and both
run together: the `gh issue comment` records the launch on the tracked issue *before* the executor
starts (closing the absence-is-ambiguity gap), and the `claude` invocation starts it. Delivered
separately, the comment can run while the invocation does not — the issue would then claim a launch
that never happened, the failure this exists to prevent.

```fish
gh issue comment <N> -R Jared-Godar/macos-system-health \
  --body "Launched — spec: artifacts/specs/<this-file>.md · "(date -u +%Y-%m-%dT%H:%M:%SZ)
claude --model <m> --effort <e> "Read and execute artifacts/specs/<this-file>.md in full."
```
