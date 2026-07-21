# PM Workflow & Governance

> `AGENTS.md` at the repo root is the authoritative operating contract; this
> document is the deeper PM playbook.

This document describes the Product Manager role in this project: how to structure work, create durable specifications, coordinate with executors, and maintain clean governance state. It serves as both a reference for executors and a checklist for PM sessions.

---

## Section 1: PM Role & Division of Labor

### What is the PM role?

The PM in this project:
- **Proposes** PR-sized chunks of work (informed by issues, roadmap, dependencies)
- **Creates durable specifications** (`prompts/*.md` files with detailed requirements + checklists)
- **Creates durable governance** (`memory/*.md` files documenting contracts and lessons learned)
- **Coordinates with executors** (via seed prompts with clear model/effort flags)
- **Verifies executor work** (via PM extracts: does it match the spec?)
- **Maintains clean state** (artifacts committed, no accumulation)

### Division of Labor

| Role | Task | Example |
|------|------|---------|
| **PM** | Propose work | "Next chunk: Issues #10+#11, feature bundle" |
| **PM** | Create spec | Write `prompts/issue-X-detailed-spec.md` |
| **PM** | Create seed prompt | `--model opus --effort high "Read spec...use TodoWrite..."` |
| **PM** | Review PM extract | Verify all gates pass; announce GREEN LIGHT or blockers |
| **Executor** | Execute spec | Create branch, implement, test, open PR |
| **Executor** | Verify locally | Run `scripts/check --all` before announcing readiness |
| **Executor** | Announce readiness | PM extract with merge-readiness status + gate results |
| **PM** | Approve merge | Confirm all gates pass + project membership + announce GREEN LIGHT |
| **Executor** | Post-merge cleanup | Fetch main, delete branches, verify state |

---

## Section 2: PM Artifact Lifecycle

### Key Principle

Durable PM artifacts are committed to version control; session artifacts are gitignored.

### Durable Artifacts (Committed to `prompts/` and `.claude/projects/.../memory/`)

- **Lifetime:** Persist across sessions; discovered by future work
- **Commit gate:** Must be committed immediately after creation (not accumulated as uncommitted)
- **Example lifecycle:**
  1. PM creates `prompts/issue-X-spec.md` (detailed requirements)
  2. PM immediately commits: `git add prompts/issue-X-spec.md && git commit -m "Add spec for Issue X"`
  3. PM creates seed prompt and sends to CLI executor
  4. Executor reads spec, implements work, creates PR
  5. Spec is referenced in PR and remains in repo for future reference

### Session Artifacts (Gitignored)

- **Location:** `artifacts/walkthroughs/*.md`, `artifacts/session-handoffs/*.md`
- **Lifetime:** Exist only during current session; deleted after handoff
- **Gitignored:** Not committed to version control
- **Example:** Post-merge closure walkthrough (deleted after session ends)

### Commitment Discipline

Per the global CLAUDE.md standing rules (Promises must be persisted), any agreement to "always do X" must be written durable in the session that makes it — in project memory, this document, or the repo's governance docs — and confirmed to the maintainer. If the commitment can't be made durable as stated, the PM says so at promise-time, not later.

---

## Section 3: Durable Contracts & Gates

### Three Layers of Governance

**Layer 1: Global Contracts** (`~/.claude/CLAUDE.md`)
- Standing rules for ALL projects
- Examples: changelog discipline, merge signals, defensive external calls, durable session handoffs
- **PM responsibility:** Read and follow for all work
- **Link:** See your global CLAUDE.md for standing rules

**Layer 2: Project Contracts** (`.claude/projects/.../memory/*.md`)
- Project-specific rules and lessons learned
- Examples: branch protection, permissions pattern, executor pre-merge gate, issue creation project membership
- **PM responsibility:** Update memory when discovering new lessons; commit immediately
- **Memory files in this project:**
  - [[pm-artifact-commit-gate]] — Commit durable PM artifacts immediately after creation
  - [[executor-pre-merge-project-membership-gate]] — Verify all issues + PR in project before announcing GREEN LIGHT
  - [[issue-creation-project-membership]] — Add issues to project at creation time, not after
  - [[seed-prompt-durable-blocks]] — Every seed prompt must include all 6 required blocks

**Layer 3: Repository Docs** (`CONTRIBUTING.md`, `SECURITY.md`, etc.)
- Workflow expectations and safety rules
- **PM responsibility:** Link from prompts; don't duplicate
- **Link:** [CONTRIBUTING.md](../CONTRIBUTING.md) — full branch, PR, and merge workflow

### Pre-Merge Gates (Always Verify Before GREEN LIGHT)

Every pull request must satisfy these gates before the PM announces merge-readiness:

- ✅ **All CI checks pass** (quality, security, tests — all 6+ checks green)
- ✅ **Linked issues exist** (`Fixes #N` syntax; issue must be created before PR)
- ✅ **Linked issues are in project** (`gh issue view #N --json projectItems` must show project membership)
- ✅ **PR is in project** (check PR details sidebar in GitHub)
- ✅ **Metadata complete** (labels from `.github/labels.json`, milestone if issue has one, assignee set)
- ✅ **CHANGELOG.md updated** (per [CONTRIBUTING.md](../CONTRIBUTING.md) — add bullet in same PR as change)
- ✅ **Executor announced readiness** (via PM extract with all verification steps completed)

---

## Section 4: PM Session Responsibilities

### Before Work Begins

- [ ] Read CLAUDE.md (global standing rules)
- [ ] Read AGENTS.md or project equivalent (agent contracts)
- [ ] Read project memory files (governance lessons learned)
- [ ] Read CONTRIBUTING.md (workflow expectations)
- [ ] Understand current roadmap and blocking issues (see [planning/ROADMAP.md](planning/ROADMAP.md))
- [ ] Identify next PR-sized chunk (or wait for direction)

### During Work (For Each PR Specification)

- [ ] Create detailed specification in `prompts/[issue-number]-[slug].md`
  - Include: requirements, acceptance criteria, test cases, special considerations
  - Reference relevant issues, PRs, ADRs, and memory files
  - Include implementation checklist for executor
- [ ] **Commit immediately:** `git add prompts/[file].md && git commit -m "Add spec for Issue #N"`
  - Do not accumulate uncommitted prompt files
- [ ] If creating follow-up issues, create them with project membership:
  ```fish
  gh issue create --title "..." --body "..." \
    --add-project "macOS System Health Roadmap" \
    -a "@me"
  ```
- [ ] **Verify issue creation succeeded:**
  ```fish
  gh issue view <ISSUE_NUMBER> --json projectItems
  # Must show: "projectItems":[{"status":{"name":"Todo"},...}]
  # If missing: gh issue edit <ISSUE_NUMBER> --add-project "macOS System Health Roadmap"
  ```
- [ ] Create seed prompt with `--model` and `--effort` flags
- [ ] Include all 6 required blocks (see Section 5)
- [ ] **Verify seed prompt includes pre-merge gate checklist** (all items from Section 3)
- [ ] Send to CLI executor
- [ ] Monitor PM extract as executor progresses

### After Executor Announces Readiness (Pre-Merge Review)

- [ ] Read PM extract fully
- [ ] Verify all merge gates pass (see Section 3 checklist)
- [ ] Check project membership (both issues and PR must be in project)
- [ ] Check that CI workflow passed (all checks green)
- [ ] Verify metadata: labels, milestone, assignee
- [ ] Verify CHANGELOG.md was updated
- [ ] Announce GREEN LIGHT (or identify specific blockers)

### If Creating Governance Updates (Memory, Contracts)

- [ ] Write memory file or update existing one
  - Use format: brief rule/fact, then `**Why:**` line, then `**How to apply:**` line
  - Include links to related memories with `[[memory-name]]`
- [ ] Update `.claude/projects/.../memory/MEMORY.md` index immediately
  - Add one-line pointer: `- [Title](file.md) — one-line hook`
- [ ] **Commit immediately:** `git add MEMORY.md memory-file.md && git commit -m "..."`
  - Do not accumulate uncommitted memory files
- [ ] Document the lesson/rule and its origin (which issue, what went wrong)

### Before Session End (Clean-State Check)

- [ ] Run `git status`
- [ ] Should show one of:
  - "On branch main / nothing to commit, working tree clean" (ideal)
  - Only `artifacts/` untracked (session artifacts are OK; not committed)
- [ ] NO uncommitted prompt files or memory files
- [ ] Handoff document created (if work spans multiple sessions) and gitignored
- [ ] All durable artifacts committed

---

## Section 5: Executor Seed Prompt Pattern

Every PM seed prompt MUST include these 6 blocks in this order:

### Block 1: Durable Contracts (Read & Follow)

```
DURABLE CONTRACTS: Read and follow these before proceeding:
1. CLAUDE.md (global user instructions — standing rules for ALL projects)
2. AGENTS.md or equivalent (project-specific agent contracts)
3. CONTRIBUTING.md (repo workflow, merge gates, changelog discipline)
4. Memory files in .claude/projects/.../memory/ (cross-project lessons, gates, patterns)
```

### Block 2: Specification Reference

```
Read prompts/[ISSUE-SPEC].md fully — detailed requirements and checklists.
```

### Block 3: Progress Tracking (TodoWrite/TaskCreate)

```
PROGRESS TRACKING: Use TodoWrite immediately (before starting work):
- Create list matching spec checklist items
- Mark complete as you finish each item
- Update after major sections
- PM watches for blockers and can intervene
```

### Block 4: Model & Effort Flags

Must include `--model` and `--effort` flags in the seed prompt:

```fish
--model opus --effort high "..."
```

Choose model and effort appropriate to the work:
- **Model:** `sonnet` (default, most capable), `opus` (for complex tasks)
- **Effort:** `low` (mechanical), `medium` (routine), `high` (complex)

### Block 5: Pre-Merge Gate Reminder

```
Before announcing merge-readiness, verify:
- Project membership: gh issue view #N --json projectItems
- CI passes: all 6+ checks green
- CHANGELOG.md updated per CONTRIBUTING.md
- Metadata complete: labels, milestone, assignee
- All verification steps documented in PM extract
```

### Block 6: Post-Merge Cleanup Reminder

```
After merge announcement, executor performs cleanup:
- Pull main (fast-forward)
- Delete merged local and remote branches
- Verify clean working tree
- Produce handoff extract (if work originated from PM thread)
```

### Complete Example

```fish
--model opus --effort high "
DURABLE CONTRACTS: Read and follow these before proceeding:
1. CLAUDE.md (global user instructions — standing rules for ALL projects)
2. AGENTS.md or equivalent (project-specific agent contracts)
3. CONTRIBUTING.md (repo workflow, merge gates, changelog discipline)
4. Memory files in .claude/projects/.../memory/ (cross-project lessons, gates, patterns)

Read prompts/issue-42-detailed-spec.md fully — detailed requirements and checklists.

PROGRESS TRACKING: Use TodoWrite immediately (before starting work):
- Create list matching spec checklist items
- Mark complete as you finish each item
- Update after major sections
- PM watches for blockers and can intervene if execution deviates

Then proceed with implementation per spec. Before announcing merge-readiness:
- Verify project membership: gh issue view #N --json projectItems
- Verify CI passes (all 6+ checks green)
- Verify CHANGELOG.md updated per CONTRIBUTING.md
- Verify metadata (labels, milestone, assignee)
- All verification steps documented in PM extract

All verification steps must pass before announcing merge-readiness.
"
```

---

## Section 6: Lessons Learned & Governance Decisions

### Phase 1 Issues & Fixes (2026-07-20 to 2026-07-21)

| Issue | Root Cause | Durable Fix | Status |
|-------|-----------|-------------|--------|
| Uncommitted PM artifacts accumulate | No explicit commit gate after artifact creation | `pm-artifact-commit-gate.md` memory + Section 2 of this doc | Implemented |
| PRs lack project membership | Issues not in project at creation time | `issue-creation-project-membership.md` memory | Implemented |
| Pre-merge gates inconsistent | No documented verification checklist | `executor-pre-merge-project-membership-gate.md` memory + Section 3 gates | Implemented |
| Post-merge cleanup missed | No explicit executor responsibility documented | Section 4 PM session responsibilities + Section 5 seed prompt block 6 | Implemented |
| Governance automation failed silently | GitHub Actions workflow didn't trigger when preconditions weren't met | Documented workflow limitations; documented manual fallback gate verification | Documented |
| Metadata validation failures | PRs created before linked issues existed | Global CLAUDE.md rule: "GitHub metadata governance" + issue creation-time project membership | Implemented |

### Governance Milestones

- **PR #34 (#35, #36, #38):** Automate PR project membership and document workflow
- **PR #39:** Publish ADR 0001: report-only default and explicit maintenance mode
- **PR #40:** Commit durable PM artifacts and implement artifact commit gate
- **PR #41:** Merge PR #40 (seed prompt + PM-WORKFLOW.md documentation)

---

## See Also

- [CONTRIBUTING.md](../CONTRIBUTING.md) — Branch, PR, and merge workflow
- [CLAUDE.md](../../.claude/CLAUDE.md) — Global standing rules for all projects
- [SECURITY.md](../SECURITY.md) — Safety and privacy rules
- [Project board](https://github.com/users/Jared-Godar/projects/3) — Active engineering backlog
- [Roadmap](planning/ROADMAP.md) — Planned improvements toward v1.0

---

**This documentation is foundational governance — reference by all future PM work and executor prompts.**
