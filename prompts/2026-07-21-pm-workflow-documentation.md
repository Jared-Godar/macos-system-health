# PM Workflow Documentation

**Artifact:** `docs/PM-WORKFLOW.md`
**Purpose:** Durable governance documentation for PM processes; referenced by executors and future PM sessions
**Scope:** Not tied to specific issues; foundational process documentation

---

## What to Document

Create `docs/PM-WORKFLOW.md` that comprehensively documents the PM role, artifact lifecycle, and governance gates. This serves as both:
1. **Reference for executors** (how PM hands off work)
2. **Checklist for PM sessions** (what to do before closing out)
3. **Governance record** (decisions and processes that persist)

---

## Content Structure

### Section 1: Overview
- **What is the PM role in this project?**
  - Proposes PR-sized chunks of work (informed by issues, roadmap, dependencies)
  - Creates durable specifications (`prompts/*.md` files with detailed requirements + checklists)
  - Creates durable governance (`memory/*.md` files documenting contracts and lessons learned)
  - Coordinates with executors (via seed prompts) and verifies their work (via PM extracts)
  - Maintains clean state (artifacts committed, no accumulation)

- **Division of labor (quick reference table)**
  | Role | Task | Example |
  |------|------|---------|
  | **PM** | Propose work | "Next chunk: Issues #10+#11, feature bundle" |
  | **PM** | Create spec | Write `prompts/issue-X-detailed-spec.md` |
  | **PM** | Create seed prompt | `--model opus --effort high "Read spec...use TodoWrite..."` |
  | **PM** | Review PM extract | "All checks passed, GREEN LIGHT" |
  | **Executor** | Execute spec | Create branch, implement, test, open PR |
  | **Executor** | Verify locally | Run `scripts/check --all` before announcing readiness |
  | **Executor** | Announce readiness | PM extract with merge-readiness status |
  | **PM** | Approve merge | Confirm gates + announce GREEN LIGHT |
  | **Executor** | Post-merge cleanup | Fetch main, delete branches, verify state |

### Section 2: PM Artifact Lifecycle

**Key principle:** Durable PM artifacts are committed to version control; session artifacts are gitignored.

#### Durable Artifacts (Committed)
- **Location:** `prompts/*.md` (executor specifications), `.claude/projects/.../memory/*.md` (governance)
- **Lifetime:** Persist across sessions; discovered by future work
- **Commit gate:** Must be committed immediately after creation (not accumulated as uncommitted)
- **Example lifecycle:**
  1. PM creates `prompts/issue-X-spec.md` (detailed requirements)
  2. PM immediately commits: `git add prompts/issue-X-spec.md && git commit -m "Add spec for Issue X"`
  3. PM creates seed prompt and sends to CLI executor
  4. Executor reads spec, implements work, creates PR
  5. Spec is referenced in PR and remains in repo for future reference

#### Session Artifacts (Gitignored)
- **Location:** `artifacts/walkthroughs/*.md`, `artifacts/session-handoffs/*.md`
- **Lifetime:** Exist only during current session; deleted after handoff
- **Gitignored:** Not committed to version control
- **Example:** Post-merge closure walkthrough (deleted after session ends)

### Section 3: Durable Contracts & Gates

**Three layers of governance:**

1. **Global Contracts** (`~/.claude/CLAUDE.md`)
   - Standing rules for ALL projects
   - Examples: changelog discipline, merge signals, defensive external calls
   - **PM responsibility:** Read and follow for all work

2. **Project Contracts** (`.claude/projects/.../memory/*.md`)
   - Project-specific rules and lessons learned
   - Examples: branch protection, permissions pattern, executor pre-merge gate
   - **PM responsibility:** Update memory when discovering new lessons

3. **Repository Docs** (`CONTRIBUTING.md`, `SECURITY.md`, etc.)
   - Workflow expectations and safety rules
   - **PM responsibility:** Link from prompts; don't duplicate

**Gates before announcing merge-readiness (always verify):**
- ✅ All CI checks pass (quality, security, tests)
- ✅ Linked issues exist and are in project
- ✅ PR is in project with correct status
- ✅ Metadata complete (labels, milestone, assignee)
- ✅ CHANGELOG.md updated per CONTRIBUTING.md
- ✅ Executor announced readiness (via PM extract)

### Section 4: PM Session Responsibilities

**Before work begins:**
- [ ] Read CLAUDE.md, AGENTS.md, project memory files, CONTRIBUTING.md
- [ ] Understand current roadmap and blocking issues
- [ ] Identify next PR-sized chunk (or wait for direction)

**During work (for each PR spec):**
- [ ] Create detailed specification in `prompts/[issue].md`
- [ ] **Commit immediately:** `git add prompts/[file].md && git commit -m "..."` (do not accumulate uncommitted changes)
- [ ] If creating follow-up issues, create them with: `gh issue create ... --add-project "macOS System Health Roadmap" -a "@me"`
- [ ] **Verify issue creation succeeded:**
  ```fish
  gh issue view <ISSUE_NUMBER> --json projectItems
  # Must show: "projectItems":[{"status":{"name":"Todo"},...}]
  # If missing: gh issue edit <ISSUE_NUMBER> --add-project "macOS System Health Roadmap"
  ```
- [ ] Create seed prompt with `--model` and `--effort` flags
- [ ] Include all 6 required blocks (durable contracts, spec reference, TodoWrite, gates, cleanup)
- [ ] **Verify seed prompt includes pre-merge gate checklist** (project membership, CI checks, metadata, changelog)
- [ ] Send to CLI executor
- [ ] Monitor PM extract as executor progresses

**After executor announces readiness (pre-merge review):**
- [ ] Read PM extract fully
- [ ] Verify all merge gates pass (see Section 3)
- [ ] Check project membership (issues + PR in project)
- [ ] Announce GREEN LIGHT (or identify blockers)

**If creating governance updates (memory, contracts):**
- [ ] Write memory file or update existing one
- [ ] Update MEMORY.md index immediately
- [ ] **Commit immediately** (do not accumulate)
- [ ] Document the lesson/rule and its origin

**Before session end (clean-state check):**
- [ ] Run `git status`
- [ ] Should show: "On branch main / nothing to commit, working tree clean"
- [ ] OR only `artifacts/` untracked (session artifacts are OK)
- [ ] No uncommitted prompt files or memory files
- [ ] Handoff document created (if needed) and gitignored

### Section 5: Executor Seed Prompt Pattern

Every PM seed prompt must include:

1. **Durable contracts block** (read CLAUDE.md, AGENTS.md, memory, CONTRIBUTING.md)
2. **TodoWrite instruction** (create list, update as you progress, PM watches)
3. **Specification reference** (pointer to detailed `prompts/[issue].md` file)
4. **Model and effort flags** (`--model <model> --effort <effort>`)
5. **Pre-merge gate reminder** (verify project membership, CI checks, metadata)
6. **Post-merge cleanup reminder** (pull main, delete branches, verify state)

**Example structure:**
```fish
--model opus --effort high "
Read durable contracts (CLAUDE.md, AGENTS.md, memory files, CONTRIBUTING.md).

Read prompts/[ISSUE-SPEC].md fully — detailed requirements and checklists.

PROGRESS TRACKING: Use TodoWrite immediately (before starting work):
- Create list matching spec checklist items
- Mark complete as you finish each item
- PM watches for blockers

Then proceed with implementation per spec. Before announcing merge-readiness:
- Verify project membership (gh issue view #N --json projectItems)
- Verify CI passes (all 6+ checks green)
- Verify CHANGELOG.md updated
- Verify metadata (labels, milestone, assignee)

All verification steps must pass before announcing GREEN LIGHT.
"
```

### Section 6: Lessons Learned & Governance Decisions

**Issues discovered during Phase 1 (2026-07-20 to 2026-07-21):**

| Issue | Root Cause | Durable Fix | Status |
|-------|-----------|-------------|--------|
| Uncommitted PM artifacts accumulate | No explicit commit gate after artifact creation | `pm-artifact-commit-gate.md` memory + this doc | Implemented |
| PRs lack project membership | Issues not in project at creation time | `issue-creation-project-membership.md` memory | Implemented |
| Pre-merge gates inconsistent | No documented verification checklist | `executor-pre-merge-project-membership-gate.md` memory | Implemented |
| Post-merge cleanup missed | No explicit executor responsibility documented | Updated seed prompt template | Implemented |
| Governance automation failed silently | Workflow didn't trigger when preconditions weren't met | Documented workflow limitations; manual fallback in gate | Documented |

---

## Implementation Checklist

- [ ] **Create file:** `docs/PM-WORKFLOW.md`
- [ ] **Section 1:** Overview + division of labor table
- [ ] **Section 2:** Artifact lifecycle (durable vs. session, commit gate)
- [ ] **Section 3:** Durable contracts (3 layers) + pre-merge gates
- [ ] **Section 4:** PM session responsibilities (checklist at each stage)
- [ ] **Section 5:** Seed prompt pattern (required blocks)
- [ ] **Section 6:** Lessons learned table
- [ ] **Link from docs/README.md:** Add section "PM Workflow & Governance"
- [ ] **Link from CONTRIBUTING.md:** Add reference to PM-WORKFLOW.md where relevant
- [ ] **Verify markdown:** No broken links, proper formatting

---

## Verification Checklist (for PR)

- [ ] `docs/PM-WORKFLOW.md` exists with all 6 sections
- [ ] Artifact lifecycle is clear (durable vs. session, commit gate)
- [ ] Division of labor table is accurate
- [ ] All three contract layers documented
- [ ] PM session responsibilities checklist is actionable
- [ ] Seed prompt pattern includes all 6 required blocks
- [ ] Lessons learned table references memory files
- [ ] All internal links work (to CLAUDE.md, memory, etc.)
- [ ] All external links work (to GitHub issues, milestones, etc.)
- [ ] Markdown formatting passes `scripts/check --all`
- [ ] Documentation cross-linked from docs/README.md and CONTRIBUTING.md

---

## Notes

- **Audience:** PM sessions (current + future), executors reading PM guidance, contributors understanding project governance
- **Tone:** Technical, actionable, reference-style (not narrative)
- **Maintenance:** Update when governance changes or new lessons learned; link from memory files
- **Examples:** Include real examples from Phase 1 (Issues #7, #24, #34-#36, #9)

---

## Links

- Related memory: `pm-artifact-commit-gate.md`, `executor-pre-merge-project-membership-gate.md`, `executor-prompt-todo-tracking.md`
- Related docs: CLAUDE.md (global contracts), CONTRIBUTING.md (workflow), SECURITY.md (safety)
- Phase 1 lessons: PR #33, #38, #39, #40

---

**This documentation is foundational governance — reference by all future PM work and executor prompts.**
