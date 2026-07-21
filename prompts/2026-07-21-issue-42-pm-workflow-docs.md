# Executor Seed Prompt: Issue #42 — PM Workflow Documentation

**This file is a seed prompt template. Copy the command block at the end and send to CLI executor.**

---

## For the PM

This work is straightforward documentation. It creates `docs/PM-WORKFLOW.md` — a comprehensive guide to PM processes that ensures governance stickiness beyond just memory files.

**Should be bundled with or follow after Issue #40?** That's a judgment call:
- **Bundle with #40:** One PR, one merge (cleaner but bigger scope)
- **Separate PR:** Issue #42 becomes its own PR after #40 merges (clearer separation but two PRs)

Recommend **separate PR** — keeps #40 focused on committing artifacts, #42 focused on documenting workflow.

---

## Executor Seed Prompt (Copy This Block)

```fish
--model sonnet --effort medium "Read prompts/2026-07-21-pm-workflow-documentation.md fully.

PROGRESS TRACKING: Use TodoWrite to create and update a task list:
- Create immediately (match implementation checklist: file creation, 6 sections, links, markdown verification)
- Mark complete as you finish each section and verification step
- Update after sections 1-3 and before final verification

This is pure documentation: create docs/PM-WORKFLOW.md with 6 sections documenting PM artifact lifecycle, commit gates, durable contracts, session responsibilities, seed prompt pattern, and Phase 1 lessons learned. Link from docs/README.md and CONTRIBUTING.md. Update CHANGELOG.md. All markdown checks must pass before announcing merge readiness."
```

---

## When to Run This

**Option 1 (Recommended):** After Issue #40 merges
- Ensures clean state between work items
- Keeps scope clear (artifacts committed first, then documented)
- Allows you to review PM workflow doc independently

**Option 2:** In parallel with Issue #40 (if you want dual PRs)
- Faster to merge both
- More complex to manage (two PRs in flight)

---

## Key Points for Executor

- Spec file is comprehensive; follow the structure exactly
- This is documentation-only (no code changes)
- Link from docs/README.md ("Architecture & Governance" section)
- Link from CONTRIBUTING.md (reference where relevant)
- All markdown must pass linting (`scripts/check --all`)
- Update CHANGELOG.md with entry under `[Unreleased] ### Added`

**Pre-merge verification:**
- `docs/PM-WORKFLOW.md` exists with all 6 sections
- Links to memory files, CONTRIBUTING.md, SECURITY.md all valid
- Lessons learned table references Phase 1 issues (#7, #24, #34-#36, #9, #40)
- `scripts/check --all` passes (no markdown warnings)
