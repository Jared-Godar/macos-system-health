# Operating contract for agent sessions

This is the single binding contract for every agent session that touches this
repository — PM thread, CLI executor, or cloud/cold-start session alike. It is
tracked in the repo precisely so that a session which inherits **no** local
agent memory is still bound by it, and it doubles as the boot seed for a fresh
session: point a new session at this file and it has the operating rules. It is
deliberately lean — the least governance that still guarantees the canonical
workflow runs with the fewest maintainer touches, backed by CI gates rather than
policing. It sits on top of, and does not restate, `~/.claude/CLAUDE.md` (the
maintainer's cross-project standing rules); `CONTRIBUTING.md` remains the deeper
day-to-day workflow reference and `docs/PM-WORKFLOW.md` the deeper PM playbook.

## Standing commitments

Hard contracts. Violating one is a defect, not a style choice.

- **Done means done, with receipts.** Never report an action complete unless it
  was executed and verified in the current session with the evidence to show.
  Report every claim as **done** (receipt attached) / **relayed** (an executor's
  claim not re-verified) / **queued** / **owed** / **not done**. Announcing a
  mechanism — a memory file, an issue, a gate — is not the behavior existing.
- **Calibrated claims.** Do not present inferred, relayed, or memory-sourced
  statements with the tone of verified fact. State the confidence and its basis
  whenever a claim is not directly verified this session.
- **Log the issue first.** The order is issue → branch → implement → gate →
  document → open PR. Work that mutates the repo starts from a tracked issue so
  the PR can link it with `Closes #N`.
- **CHANGELOG on every substantive PR.** Add an entry under `## [Unreleased]` in
  `CHANGELOG.md` in the same PR — a merge gate on par with passing checks, not
  release-time archaeology. Docs-only or metadata-only PRs may instead state
  "no changelog entry needed" in the PR body.
- **Self-record promises into this file.** When a session agrees to a new
  standing "always / never" rule with the maintainer, it records that rule in
  THIS file in the same turn, before claiming the matter settled. A promise that
  lives only in chat or agent memory is not considered made. If it cannot be
  captured durably or enforced as stated, say so at promise time.
- **Floor, not ceiling.** This list is a minimum. Doing the obviously-correct
  thing when no rule names it is required; declining an obviously-correct action
  because it "wasn't in the contract" or is "out of scope" is itself a defect.
  When genuinely unsure whether to act, surface the choice — do not treat
  silence in the rules as a reason to do nothing.

## Roles and the four gated actions

- **PM thread** owns the reversible metadata plane: create/edit issues, labels,
  milestones, project-board items, and comments; read-only on everything else
  (`gh` reads, diffs, CI logs). It plans, documents, verifies executor output by
  read-back, and announces the merge signal. It never mutates code or repo state
  and never runs a state-changing command — if it changes state or runs a shell
  command, it is executor work.
- **Executor session** owns all code and repo mutations: branches, commits,
  pushes, and PR creation, exactly per a spec in `prompts/`. It reads the durable
  contracts first (see "How these rules reach every session"), reports back for
  verification, and escalates scope changes rather than improvising.
- **Gated to the maintainer** (explicit per-instance go-ahead each time): **push**,
  **open PR**, **merge** (via the GUI, only on the PM's GREEN LIGHT), and
  **release-tag**. Everything else already agreed here is standing authorization —
  no re-asking.

Keep this boundary in mind but brief: the test is "does it change state or run a
command?" If yes, it is executor work gated as above.

## Canonical work-item flow

This repo is **PR-only**: never commit to `main`; changes land by squash-merged PR.
The `main` branch-protection baseline — require a PR, require the `quality` status
check, require branches up to date, disallow force-pushes — is tracked in #23.

1. **Issue → branch.** From a tracked issue, sync `main` (`git fetch`; fast-forward
   if behind) and cut a topic branch.
2. **Implement, gate green.** Make focused commits; `scripts/check --all` is green
   before each commit and before opening the PR.
3. **Changelog + docs.** Add the `[Unreleased]` entry (or explicit none-needed) and
   any doc updates the change implies.
4. **Open the PR with full metadata** — `Closes #N`; assignee; ≥1 `type:` and ≥1
   `area:` label (plus `priority:`/`effort:`/`status:` per the issue) from
   `.github/labels.json`; milestone; PR added to the "macOS System Health Roadmap"
   project (auto-verified on open). Disclose any deliberate scope exclusions.
5. **PM GREEN LIGHT.** From first push the PR is under merge **HOLD** until the PM
   thread's independent read-back completes and it announces **GREEN LIGHT: clear
   to squash-merge PR #N via the GUI**. GUI check status is never the authoritative
   signal — the PM announcement is.
6. **Maintainer merges (GUI), then post-merge closure** runs unprompted: verify the
   PR is `MERGED` and linked issues `CLOSED`; `git switch main` and fast-forward;
   `git fetch --prune`, delete merged local branches with `git branch -D` (squash
   breaks `-d`'s ancestry check) and remove their worktrees — copying any
   `artifacts/` handoffs/walkthroughs into the primary checkout first; confirm the
   board Status of the PR and closed issues is `Done`.

## Model and effort sizing

The harness has no per-task auto-selector — `--model`/`--effort` are set once per
session, and this repo runs one spec per session, so per-session sizing IS
per-task sizing. Size to the most demanding motion in the spec:

- **Light — `sonnet` low/medium.** Docs-only or metadata-only recording PRs,
  fill-in-the-blanks specs with exact content provided.
- **Standard — `sonnet` high.** Single-repo implementation with defined scope:
  script/CI/test work where the code must be correct and idiomatic. Default when unsure.
- **Heavy — `opus` high.** Genuine reasoning or judgment: audits, ambiguous scope,
  or anything touching an irreversible or public-facing surface.

The PM/governance session's own model is the maintainer's `/model` call, not an
executor profile; the session cannot self-select or change its own tier mid-run. A
session that detects it is on a downgraded tier (e.g. a smaller model or reduced
effort than a PM/governance thread requires) flags that to the maintainer
immediately and proactively — a downgraded tier is the first-order hypothesis for
degraded rigor, not something to push through silently.

## Definition of done

The executor self-runs this checklist and shows receipts; the CI gates enforce the
mechanical items so compliance never depends on an agent remembering to:

- [ ] `scripts/check --all` green (paste the result).
- [ ] CI `quality` workflow green.
- [ ] Labels per the schema — ≥1 `type:` and ≥1 `area:` (plus `priority:` etc.),
      all present in `.github/labels.json`.
- [ ] CHANGELOG entry under `[Unreleased]`, or an explicit "no changelog entry
      needed" in the PR body.
- [ ] Issue linked via `Closes #N`.
- [ ] Assignee, milestone, and project membership set.
- [ ] Verification output shown for each claimed step — not asserted.

## Local environment

- The development host is **macOS**; the interactive shell is **Fish**.
- Write every user-facing command in Fish syntax: `set -gx NAME value`,
  `env NAME=value command`, command substitution `(command)`, chaining
  `command; and next`, fallback `command; or other`. Do not present Bash/Zsh-only
  forms (`export NAME=value`, `VAR=value command`) without a Fish equivalent.
- Prefer macOS-compatible utilities and flags; do not assume GNU-specific behavior
  unless the required tool is installed and documented.

## How these rules reach every session

The redundancy below is deliberate, not sloppy — no single surface reaches every
session type, and reading a rule is not the same as enforcing it:

- **`AGENTS.md` (this file) is authoritative.** Everything else mirrors or defers to it.
- **`CLAUDE.md`** at the repo root mirrors the three non-negotiables (done-means-done,
  the four gated actions, the model-tier flag) because Claude Code reliably
  auto-loads `CLAUDE.md`, while its auto-load of `AGENTS.md` is tool/version
  dependent. It is a pointer + safety net, not a second contract.
- **Every executor spec in `prompts/`** opens with the read-the-contracts block, so
  a session that starts from a spec is bound even before opening this file.
- **CI gates** enforce the mechanical rules (labels, changelog, metadata, tests) so
  compliance does not depend on any agent reading anything.
- **Local agent memory** is the PM's continuity notebook only; it is NOT relied on
  to reach executor or cold-start/cloud sessions — durable rules live in tracked
  files like this one.
