# Executor Seed Prompt: Issue #45 — Goldilocks Label Schema

**This file contains the seed prompt to send to CLI executor.**

---

## Seed Prompt (Copy & Send to CLI)

```fish
--model opus --effort high "
DURABLE CONTRACTS: Read and follow these before proceeding:
1. CLAUDE.md (global user instructions — standing rules for ALL projects)
2. AGENTS.md or equivalent (project-specific agent contracts)
3. CONTRIBUTING.md (repo workflow, merge gates, changelog discipline)
4. Memory files in .claude/projects/.../memory/ (cross-project lessons, gates, patterns)

Read prompts/2026-07-21-issue-45-goldilocks-label-schema.md fully — detailed 6-phase implementation spec.

PROGRESS TRACKING: Use TodoWrite immediately (before starting work):
- Create list matching the 6 phases: Create Labels, Create labels.json, Retroactively Label, Update Docs, Update Memories, Archive Unused
- Mark complete as you finish each phase
- Update after each phase completion (PM watches for blockers)
- Phases are sequential; verify each before moving to next

Then proceed with spec. This is a governance + operational task:
1. Create 12 new labels (effort, status, risk, confidence, type, help-wanted)
2. Create .github/labels.json documenting the schema
3. Retroactively apply labels to all existing issues/PRs (open and closed)
4. Update CONTRIBUTING.md with label guidelines
5. Create memory file documenting schema
6. Archive unused labels

Before announcing merge-readiness:
- Verify all 12 labels created (gh label list)
- Verify .github/labels.json exists with all 28 labels
- Verify open issues all have effort + status + type labels (sample 3+)
- Verify Phase 1 closed issues/PRs retroactively labeled (sample 5+)
- Verify CONTRIBUTING.md updated
- Verify memory file created and linked
- Verify CHANGELOG.md updated
- Verify scripts/check --all passes

All verification steps must pass before announcing GREEN LIGHT."
```

---

## Why This Task Matters

The label schema enables:
- **GitHub Projects dashboarding:** Filter by effort (capacity planning), status (workflow), risk (prioritization)
- **Consistent workflow:** Status labels show bottlenecks; effort shows feasibility
- **Cross-project standardization:** Same schema applies to ecg_anomaly_detection and github-portfolio-modernization
- **Durable governance:** Schema documented in .github/labels.json and memory

---

## Model & Effort Rationale

- **Opus:** Label creation is mechanical, but retroactive labeling requires judgment (effort estimation, risk assessment, confidence evaluation)
- **High effort:** Multiple phases (create, document, retroactive labeling, doc updates, memory updates); requires quality control across 15–25 existing issues/PRs

---

## Ready to send to CLI executor?
