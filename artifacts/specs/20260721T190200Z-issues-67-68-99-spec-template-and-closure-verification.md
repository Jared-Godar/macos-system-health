# Spec: Rebuild the spec template, define the launch record, and fix closure verification (Issues #67, #68, #99)

**Closes:** #67, #68, #99 · **Milestone:** Remediation - Back to Step 0
**Labels:** `area:governance`, `priority:high`, `type:feature`, `effort:medium`, `status:ready`, `risk:medium`
**Assignee:** Jared-Godar · **Project:** macOS System Health Roadmap
**Sizing:** `--model sonnet --effort high`

> **Sizing.** Every decision is made in §2; what remains is a `git mv`, a template rewrite from two
> named exemplars, one shell function, and a settings edit. Scope is defined and the code is small.
> One rung above Light because the new gate must be Bash 3.2 and because a hook edit is involved.

> **PLACEMENT.** This spec is already at its canonical path, untracked on `main`. Do not copy or
> move it. Commit it with your PR.

---

## 0. Read the durable contracts first (non-negotiable)

1. **`AGENTS.md` on `main` in full.**
2. Root `CLAUDE.md`.
3. `~/.claude/CLAUDE.md`.
4. `CONTRIBUTING.md`.
5. **Issues #67, #68, #99 in full, including comments.** #67's body was rewritten on 2026-07-21 and
   its table of what is already delivered is authoritative over its comment history.

**The rules that will bite you here:**

- **A `PreToolUse` hook denies `Write`/`Edit` on any path matching `*/prompts/*`.** It lives in the
  **tracked** `.claude/settings.json` (not `settings.local.json`, which does not exist). See D4 —
  this blocks a deliverable, and the order of operations matters.
- **`git mv` is a shell command, not `Write`/`Edit`,** so moving a file out of `prompts/` is not
  blocked. Moving is fine; writing in place is not.
- **Receipts expire on the next mutation.** mutate → commit → gate → report.
- **Four gated actions need per-instance go-ahead: push, open PR, merge, release-tag.** Never merge.
  **GREEN LIGHT is the PM's signal, not yours** — report receipts and hold; do not announce
  merge-readiness.
- **A multi-issue PR repeats the closing keyword per number.** `Closes #67, #68, #99` links only
  #67. That is the subject of #99 and the mistake to not make in your own PR body.
- **No contract-lawyering.** A criterion you cannot meet is a finding to report, never one to drop.
- **Specs are immutable after handoff.** This file is read-only to you.
- **Write `-R Jared-Godar/macos-system-health` inline on every `gh` command** — never via a shell
  variable; it mangles silently.

## 0b. Progress tracking

Live task list via **TodoWrite** — one item per §4 step plus each numbered AC — refreshed at every
step boundary. If TodoWrite is unavailable, say so once, then re-post the checklist inline
(`[x]`/`[~]`/`[ ]`) at the top of every response that starts or finishes a step.

---

## 1. Intended outcome

The document every future spec is copied from is conformant, lives outside the frozen archive, and
carries a closure-verification command that can actually fail. A CI check keeps it that way. A
launched executor leaves a trace a successor session can find.

## 2. Decisions — made by the PM, implement as written

### D1 — Template location: `artifacts/specs/TEMPLATE.md`

Not `docs/governance/templates/`. **#78 is blocked on Fable access**, so that directory does not
exist and squatting on its namespace guarantees a second move later. `artifacts/specs/` puts the
template beside the two exemplars it is modelled on, and it is already inside the PM authoring lane,
so a PM can maintain it without a lane exception. The timestamp convention for real specs
(`<UTC>-issue-<n>-<slug>.md`) makes `TEMPLATE.md` unmistakably not a spec.

### D2 — Spec conformance: **build the gate**

#67 asks gate-vs-contract and says not to leave it undecided twice. Build it. Measured: **all 9
specs on `main` already open with a contracts block**, so there is zero backfill cost.

Two assertions, implemented as a function **inline in `scripts/check`** — not a new script, which
would need adding to `EXECUTABLE_FILES` and a committed mode (the #83 trap):

1. Every tracked `artifacts/specs/*.md` contains a `## 0.` contracts-block heading matching
   `Read the durable contracts first`. **Applies to all specs — all 9 pass today.**
2. `artifacts/specs/TEMPLATE.md` contains `closingIssuesReferences` and does **not** contain
   `body|test("Closes`. **Applies to the template only.**

**Why assertion 2 is template-only, and this is not a loophole:** the 9 historical specs all
contain the defective `body|test("Closes` snippet, and **specs are immutable after handoff** — they
cannot be rewritten. Gating them would produce a permanently red build with no legal fix. The
template is the propagation source; blocking it there stops every future copy. The historical specs
are inert records, not instructions anyone re-runs.

### D3 — Launch record: **the maintainer, at launch** (maintainer's decision, 2026-07-21)

Owner is the **maintainer**, writing the record at the moment he launches. This is the only option
with **no ambiguity window at all**: the record exists before the executor starts, so a successor
session that sees the comment knows a launch happened, and one that sees no comment knows none did.
The executor-at-Checkpoint-1 alternative was recommended by the PM and **rejected** — it leaves a
minutes-long window between launch and first checkpoint where the ambiguity persists.

**The accepted cost is a manual step on the maintainer's path, and reducing it to zero marginal
effort is a deliverable of this PR, not an afterthought.** The mechanism:

**The PM includes the launch-record command inside the same fenced block as the `claude`
invocation**, so the maintainer copies one block and both run together. It is never a separate
thing to remember. Canonical shape:

```fish
gh issue comment <N> -R Jared-Godar/macos-system-health \
  --body "Launched — spec: artifacts/specs/<file>.md · (date -u +%Y-%m-%dT%H:%M:%SZ)"

claude --model <m> --effort <e> --append-system-prompt "…" "Read and execute …"
```

**The one real risk of this owner, stated rather than glossed:** the record states intent, so if the
comment runs and the `claude` invocation does not, the issue claims a launch that never happened —
the same false-certainty class as the #68 incident itself. **Shipping both commands in one block is
what collapses that risk**: they succeed or fail together in a single paste. The rule text must say
so explicitly, because a launch-record command delivered separately from the invocation reintroduces
exactly the failure it exists to prevent.

### D4 — `prompts/README.md`: narrow the hook, then write it normally

**This collision is real and will stop you if you do it in the wrong order.** #67 item 5 requires a
freeze note at `prompts/README.md`. The `PreToolUse` hook denies `Write` on `*/prompts/*`, so
creating it will be blocked.

Three options considered:

| option | verdict |
|---|---|
| Create it via shell redirect (`cat > prompts/README.md`) | **Rejected.** Routing around a guard because it is inconvenient is the behaviour the guard exists to prevent, and it sets the precedent that the hook is advisory. |
| Skip the file; rely on `AGENTS.md`'s existing freeze statement | **Rejected.** Someone browsing `prompts/` does not read `AGENTS.md`. #67's stated purpose is that a future session not mine those specs as current exemplars. |
| **Narrow the hook to permit exactly `prompts/README.md`** | **Chosen.** |

Edit the hook's `case` in `.claude/settings.json` so `*/prompts/README.md` falls through to allow
while every other `*/prompts/*` path still denies with the identical message. This does not weaken
spec immutability — a README documenting the freeze is not a spec, and no historical spec becomes
writable. **#67 says "do not weaken the hook to permit an edit"; that constraint is about editing
specs, and this carve-out leaves every spec exactly as protected as before. Disclose it in the PR
body as a deliberate deviation from #67's literal wording so it can be vetoed.**

**Order of operations: edit the hook first, verify the deny still fires for a spec path, then create
the README.**

## 3. Deliverables

1. **`git mv prompts/EXECUTOR-SEED-PROMPT-TEMPLATE.md artifacts/specs/TEMPLATE.md`** (D1).
2. **Rewrite the template** (currently 108 lines, `grep -ci "AGENTS.md"` = **0**) against the two
   best exemplars on `main` —
   `artifacts/specs/20260721T164206Z-issues-54-51-label-policy-and-gate.md` and
   `…20260721T175038Z-issues-76-85-92-agent-safety-and-artifact-timing.md`. It must carry:
   - **§0 contracts block** — read `AGENTS.md`, root `CLAUDE.md`, `~/.claude/CLAUDE.md`,
     `CONTRIBUTING.md`, the issue — plus a "the rules that will bite you on **this** task" slot,
     not a generic recital.
   - **§0b progress tracking with the recurrence clause**, verbatim from #67 item 3: *"If TodoWrite
     is unavailable, say so once, then re-post the full checklist as inline markdown at the top of
     every response that starts or finishes a step."* The recurrence is the whole fix — a one-shot
     phrasing let the #73 executor satisfy it once then go silent.
   - The four gated actions, the checkpoints, `Closes` metadata, and a non-goals section.
   - **The closure-verification command as GraphQL, never a body text-match** (#99):
     ```fish
     gh api graphql -f query='{repository(owner:"Jared-Godar",name:"macos-system-health"){
       pullRequest(number:<PR>){closingIssuesReferences(first:10){nodes{number state}}}}}' \
       --jq '.data.repository.pullRequest.closingIssuesReferences.nodes[].number'
     ```
     with a note that this lags a few seconds behind `gh pr edit` — re-query rather than trusting
     the first read.
3. **`prompts/README.md`** — dated freeze note: frozen as of 2026-07-21, why, and where specs now
   live. Per D4, after the hook edit.
4. **The conformance gate in `scripts/check`** per D2.
5. **`AGENTS.md`** — the launch-record rule (D3: the maintainer owns it, and the PM **must** ship the
   `gh issue comment` line inside the same fenced block as the `claude` invocation so the two run
   from one paste — a separately-delivered launch-record command reintroduces the intent-vs-fact
   failure it exists to prevent) and the #99 per-issue
   closing-keyword requirement with the GraphQL verification and why a body text-match cannot fail.
6. **`CONTRIBUTING.md`** — the #99 requirement in one sentence.
7. **`.claude/settings.json`** — add `TodoWrite` to the permissions allowlist (#67 item 7; verified
   absent). In the PR body, record the unresolved launch-layer finding: TodoWrite was absent from an
   executor session despite a plain launch with no tool restriction; cause unknown and
   harness-dependent, so §0b's inline fallback is the **primary** mechanism, not a degraded path.
8. **CHANGELOG** entry under `[Unreleased]`.

## 4. Execution rails

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git log --oneline -1     # expect d276e6a or later
git switch -c feat/issues-67-68-99-spec-template
```

Write the continuity walkthrough immediately after branching, under the option-1 convention that
landed in #98 — finalize it before your final commit, leaving only the merge SHA and closure
receipts as slots tagged deliberate.

**Hook first, then the README** (D4):

```fish
# after editing .claude/settings.json, prove the deny still fires for a spec path
# and that README.md is now permitted — show both results in your checkpoint.
```

Then the move, the rewrite, the gate, the docs. Commit, then gate on the committed state:

```fish
git add -A
git status --short
git commit -m "Rebuild the spec template, define the launch record, and fix closure verification (#67, #68, #99)"
/bin/bash scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"
tail -5 /tmp/g.log
```

Expected: both `exit=0`, smoke **46**, and the new conformance check visible in the output.

**Step 5 — STOP: push is gated.  ·  Step 6 — STOP: opening the PR is gated.**

## 5. PR metadata

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Rebuild the spec template, define the launch record, and fix closure verification (#67, #68, #99)" \
  --assignee Jared-Godar \
  --milestone "Remediation - Back to Step 0" \
  --label area:governance --label priority:high --label type:feature \
  --label effort:medium --label status:ready --label risk:medium \
  --body-file <path>
```

**The body carries three separate closing directives — `Closes #67`, `Closes #68`, `Closes #99` —
each with its own keyword.** Verify with the GraphQL query, not a text-match; expect all three.

Body also carries: the four decisions restated as implemented; the D4 hook carve-out flagged as a
deliberate deviation from #67's literal wording; the negative-and-positive hook test; the
conformance gate demonstrated **failing** on a seeded bad file and then passing; `scripts/check
--all` from the committed state with its SHA; the CI receipt including `label-policy`; the
TodoWrite launch-layer finding; and deferrals (#78, #52, #95).

## 6. Numbered acceptance criteria

- **AC1.** `artifacts/specs/TEMPLATE.md` exists; `prompts/EXECUTOR-SEED-PROMPT-TEMPLATE.md` does
  not. Move done with `git mv` — show `git log --follow --oneline` or the rename in `git show --stat`.
- **AC2.** `grep -c "AGENTS.md" artifacts/specs/TEMPLATE.md` > 0 (was 0). Output pasted.
- **AC3.** Template carries the §0 contracts block, the §0b recurrence clause verbatim, the four
  gated actions, the checkpoints, and a non-goals section.
- **AC4.** Template's closure verification is the GraphQL query; it contains **no**
  `body|test("Closes` anywhere. Show both greps.
- **AC5.** `prompts/README.md` exists with a dated freeze note and a pointer to `artifacts/specs/`.
- **AC6.** The hook edit permits `prompts/README.md` and still denies other `*/prompts/*` paths —
  **both results demonstrated**, not asserted.
- **AC7.** `scripts/check` runs the conformance function; it is a function in that file, not a new
  script.
- **AC8.** The gate is demonstrated **failing**: temporarily seed a spec-shaped file missing the
  contracts block, show the red, remove it. A gate only ever seen passing is unproven.
- **AC9.** `AGENTS.md` carries the launch-record rule naming the **maintainer** as owner, and states
  that the PM ships the `gh issue comment` line **inside the same fenced block** as the `claude`
  invocation. The rule must say why: delivered separately, the record can claim a launch that never
  happened.
- **AC9b.** `artifacts/specs/TEMPLATE.md` and the PM-facing guidance both show the two-command launch
  block as the canonical handoff shape, so the next PM inherits it rather than rediscovering it.
- **AC10.** `AGENTS.md` carries the per-issue closing-keyword rule, the GraphQL verification, and
  why a body text-match cannot detect the failure.
- **AC11.** `CONTRIBUTING.md` carries the #99 requirement.
- **AC12.** `TodoWrite` present in `.claude/settings.json` permissions. Output pasted.
- **AC13.** `/bin/bash scripts/check --all` green on the **committed** state; output pasted, SHA named.
- **AC14.** CI green; `label-policy` result reported.
- **AC15.** `closingIssuesReferences` on the PR returns **67, 68, 99**. Output pasted.
- **AC16.** CHANGELOG entry.
- **AC17.** Deferrals named in the PR body: #78 (blocked, will relocate procedural docs later),
  #52, #95.

## 7. Non-goals

- Not creating `docs/governance/` or moving anything into it — #78 is blocked (D1).
- Not editing any historical spec under `artifacts/specs/` or any file under `prompts/` other than
  the new `README.md`.
- Not weakening spec-immutability protection — D4's carve-out is one filename.
- Not gating the historical specs on the `body|test("Closes` anti-pattern (D2 explains why).
- Not touching `bin/`, `lib/`, `tests/`, branch protection, or the label policy.

## 8. Verification status of this spec's claims

| Claim | Status |
|---|---|
| All 9 specs on `main` open with a contracts block | **PM-VERIFIED** — per-file loop, 2026-07-21 |
| 9 specs contain `body|test("Closes` | **PM-VERIFIED** via `git grep -l` |
| Template is 108 lines, `grep -ci "AGENTS.md"` = 0 | **PM-VERIFIED** |
| `prompts/README.md` absent | **PM-VERIFIED** |
| Hook lives in tracked `.claude/settings.json`, matcher `Write\|Edit`, case `*/prompts/*` | **PM-VERIFIED** — read from the file |
| `TodoWrite` absent from `.claude/settings.json` | **PM-VERIFIED** |
| `main` at `d276e6a`; smoke 46 | **PM-VERIFIED** / count from PR #98, not re-run |
| **That editing the hook's `case` produces the intended allow/deny split** | **PM-UNVERIFIED** — never tested. This is why AC6 requires demonstrating **both** outcomes. |
| That `git mv` is not intercepted by the `Write\|Edit` matcher | **PM-UNVERIFIED** — reasoned from the matcher, not observed. If it is blocked, that is a finding: report it, do not route around it. |
| The GraphQL lag behind `gh pr edit` | **PM-VERIFIED** — observed on PR #98 |

## 9. Dependencies

- **#78** blocked on Fable; it may later relocate the template into `docs/governance/templates/`.
  D1 is chosen so that move is optional rather than forced.
- **#52**, **#95** untouched.
- Nothing here blocks or is blocked by #74.

## 10. References

- **#67** (rewritten body is authoritative) · **#68** (only the launch-record deliverable remains;
  the other four are already on `main`) · **#99** (the defective snippet and its 9-file blast radius)
- Exemplars: `artifacts/specs/20260721T164206Z-…` and `…20260721T175038Z-…`
- `.claude/settings.json` (hook + permissions) · `scripts/check` · `AGENTS.md` § Canonical
  work-item flow, § Definition of done
