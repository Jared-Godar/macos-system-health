# Spec: Create lean AGENTS.md (Issue #55)

**Closes:** #55
**Design mandate:** "fluffy but not fat" — the least governance that still guarantees the SOPs
run with minimal maintainer interaction. The maintainer's goal is high-quality output with the
**fewest touches** and confidence (from machine gates, not policing) that canonical workflows are
followed. ecg's `AGENTS.md` is intentionally over-governed — do NOT replicate its scale.
`github-portfolio-modernization/AGENTS.md` + `docs/pm-context.md` are the balanced model to adapt.

---

## Source material (read these first, then adapt — do not copy wholesale)

- `/Users/jaredgodar/Code/portfolio/github-portfolio-modernization/AGENTS.md` — primary model:
  standing commitments, PM/executor operating model, four gated actions, canonical workflow,
  closure pass, local-env (Fish).
- `/Users/jaredgodar/Code/portfolio/github-portfolio-modernization/docs/pm-context.md` — the
  **Execution profile** (model/effort) rubric and division-of-labor digest to fold in.
- This repo: `CONTRIBUTING.md`, `SECURITY.md`, `docs/PM-WORKFLOW.md`, `docs/GOVERNANCE.md`
  (stale — to be folded in and deleted), `.github/labels.json`, `scripts/check`.

## Build the file: `AGENTS.md` at repo root, ~2 pages, seven tight sections

1. **How to use** — one short paragraph: single binding contract for PM, executor, and cloud
   sessions; tracked so cold-start sessions are bound; doubles as the fresh-session boot seed.
2. **Standing commitments** (bullets, tight):
   - done-means-done with receipts — report as done (receipt) / relayed (executor claim not
     re-verified) / queued / owed / not done; announcing a mechanism is not the behavior existing
   - calibrated claims (state confidence + basis when not directly verified)
   - log-issue-first: issue → branch → implement → gate → document → open PR
   - CHANGELOG on every substantive PR (or explicit "none needed" for docs/metadata-only)
   - self-recording promises **into this file**, in the same turn, before claiming settled
   - floor-not-ceiling: doing the obviously-correct unnamed thing is required; declining because
     "not in the contract" is itself a defect
3. **Roles + the four gated actions:**
   - PM owns the reversible metadata plane: create/edit issues, labels, milestones, board items,
     comments; read-only on everything else
   - Executor owns all code/repo mutations, via PR
   - Gated to the maintainer (per-instance go-ahead): **push, open-PR, merge (GUI, on GREEN
     LIGHT), release-tag**. Everything else agreed is standing authorization — no re-asking.
   - Keep this defined but brief; it is not the document's focus.
4. **Canonical flow** — six one-liners: issue → branch → implement + `scripts/check --all` green
   → changelog + docs → open PR with full metadata → PM GREEN LIGHT → maintainer merges (GUI) →
   post-merge closure (pull main ff, delete merged local branch + worktree, verify clean).
5. **Model/effort sizing** — the Execution-profile rubric adapted from gh: Light (`sonnet`
   low/med — docs, metadata), Standard (`sonnet` high — defined-scope implementation), Heavy
   (`opus` high — audits, ambiguous scope, irreversible surfaces); size to the most demanding
   motion. Plus: "the PM session's own model is the maintainer's `/model` call; the harness has no
   per-task auto-selector; a PM session that detects it is on a downgraded tier flags it
   immediately." (~5 lines total.)
6. **Definition of done** — a checklist the executor self-runs and shows receipts for, and that
   the compliance gates enforce mechanically: `scripts/check --all` green; CI green; labels per
   the type-aware policy; changelog entry (or explicit none-needed); issue linked via
   `Closes #N`; assignee + milestone + project set; verification output shown.
7. **Local environment** — macOS; every shown command in Fish syntax (`set -gx`, `env VAR=…`,
   `(cmd)`, `; and` / `; or`).

## Also deliver: a thin, auto-loaded `CLAUDE.md` (the hedge — required)

Claude Code reliably auto-loads `CLAUDE.md`; its auto-load of `AGENTS.md` is tool/version
dependent. So a session pointed at this repo could miss AGENTS.md entirely. Add a **short**
project `CLAUDE.md` at repo root (~15 lines) whose only job is:
- one line: "The operating contract for this repo is `AGENTS.md` — read it and follow it."
- inline the **three non-negotiables verbatim** so they hold even if AGENTS.md is never opened:
  done-means-done (with receipts), the four gated actions (push / open-PR / merge / release), and
  the model-tier flag rule.
Keep it a pointer + safety net, NOT a second contract. Do not restate all of AGENTS.md — that
creates drift. (Precedent: github-portfolio-modernization carries both AGENTS.md and CLAUDE.md.)

## Add to AGENTS.md a short "How these rules reach every session" note (4–6 lines)

State the layering so the redundancy reads as deliberate, not sloppy: AGENTS.md is authoritative;
CLAUDE.md mirrors the non-negotiables for auto-load; every executor seed opens with the
read-contracts block; enforceable rules (labels, changelog, metadata, tests) are additionally
enforced by **CI gates** so compliance does not depend on any agent reading anything; local
memory is the PM's continuity notebook and is NOT relied on to reach executor/cloud sessions.

## Doc reconciliation (do all three)

- Fold the still-true content of `docs/GOVERNANCE.md` into `AGENTS.md`, then `git rm` GOVERNANCE.md.
- Add a one-line header to `docs/PM-WORKFLOW.md`: "AGENTS.md is the authoritative contract; this
  document is the deeper PM playbook." Leave the rest.
- Add an `AGENTS.md` pointer to `docs/README.md`.

## Non-goals (hold the line on scope)

- No ecg-scale machinery: no nine-field board rules, automation graduation ladder, non-closing
  markers, or extra issue templates. If tempted, stop — that is the "fat" we are avoiding.
- Do not duplicate `~/.claude/CLAUDE.md`; reference it.
- No tool/CI/safety-boundary changes.

## Progress tracking & checkpoints

- Use TodoWrite: one item per section + the three doc-reconciliation tasks + gates.
- Produce handoff extracts at: (1) branch created, (2) AGENTS.md + doc changes drafted (before
  PR), (3) PR opened with metadata verified, (4) post-merge closure.

## Definition of done for THIS PR (verify with output, then STOP for GREEN LIGHT)

- [ ] `AGENTS.md` present, ~2 pages, seven sections; GOVERNANCE.md deleted; PM-WORKFLOW header
      added; docs/README pointer added
- [ ] All shown commands Fish; `scripts/check --all` green (paste result)
- [ ] CHANGELOG updated under `[Unreleased]`
- [ ] PR links `Closes #55`; metadata verified:
      `gh pr view <PR> --json labels,milestone,assignees,projectItems`
      (labels: area:governance, type:docs, priority:high, effort:medium, status:ready, risk:medium)
- [ ] Announce readiness; do NOT merge — the maintainer merges on the PM GREEN LIGHT.
