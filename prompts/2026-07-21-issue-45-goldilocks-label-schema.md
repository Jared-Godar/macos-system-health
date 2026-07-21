# Issue #45: Implement Goldilocks Label Schema for GitHub Projects

**Tracking issue:** #45  
**Branch:** `feature/goldilocks-label-schema`  
**Milestone:** Phase 2 (infrastructure)

---

## What This Does

Creates and implements a standardized GitHub label schema across macos-system-health (and documents pattern for ecg_anomaly_detection and github-portfolio-modernization) to enable GitHub Projects dashboarding, filtering, and workflow tracking.

---

## Label Schema Design (28 total)

### AREA (4 labels) — Keep existing
- `area:governance` — Repo workflow, permissions, contracts, governance
- `area:reporting` — Report output, email, formatting
- `area:scheduling` — LaunchAgent, cron, timing
- `area:script` — Core script logic, features

### PRIORITY (3 labels) — Keep existing
- `priority:high` — Should land in next milestone
- `priority:medium` — Worth doing, not urgent
- `priority:low` — Nice to have, defer freely

### TYPE (4 labels) — Refactor + add
**NEW:**
- `type:feature` — New feature or capability
- `type:bug` — Something isn't working
- `type:docs` — Documentation improvements
- `type:community-contribution` — Community-requested or community-driven

**TO ARCHIVE/MIGRATE:**
- Archive: `bug`, `enhancement`, `documentation` (replace with type: schema)
- Keep: `type:community-contribution`

### EFFORT (3 labels) — NEW
- `effort:small` — 1–2 days work
- `effort:medium` — 3–5 days work
- `effort:large` — 1+ weeks work

**Purpose:** Resource planning, capacity estimation, GitHub Projects filtering

### STATUS (3 labels) — NEW
- `status:ready` — Ready to start, no blockers
- `status:blocked` — External dependency or blocker (waiting on external input)
- `status:stalled` — In progress but waiting (waiting on review, decision, unblock)

**Purpose:** Workflow tracking in GitHub Projects, identifying bottlenecks

### RISK (2 labels) — NEW
- `risk:high` — Security, data, production impact; affects multiple users
- `risk:medium` — Affects workflow but not critical; contained impact

**Purpose:** Risk-aware prioritization, enables risk vs. priority matrix in Projects

### CONFIDENCE (2 labels) — NEW
- `confidence:low` — Needs validation, exploration, research
- `confidence:unconfirmed` — Community-reported, not verified by maintainer

**Purpose:** Track uncertainty, identify research tasks, mark exploratory work

### HOUSEKEEPING (3 labels) — Minimal set
- `dependencies` — Pull requests that update a dependency file (keep existing)
- `duplicate` — This issue or PR already exists (keep existing)
- `help-wanted` — Extra attention is needed (NEW: replaces `help`)

**TO ARCHIVE:**
- `good` (unused)
- `question` (use in comments, not labels)
- `wontfix` (document in issue, don't label)
- `invalid` (document in issue, don't label)
- `github_actions` (move logic to PR descriptions)

---

## Implementation Checklist

### Phase 1: Create Labels
- [ ] Create 12 new labels:
  ```bash
  gh label create effort:small --description "1–2 days work" --color "7FBA00"
  gh label create effort:medium --description "3–5 days work" --color "F2CC0C"
  gh label create effort:large --description "1+ weeks work" --color "FFA500"
  gh label create status:ready --description "Ready to start, no blockers" --color "0366d6"
  gh label create status:blocked --description "Blocked on external dependency" --color "d73a4a"
  gh label create status:stalled --description "In progress but waiting" --color "e99695"
  gh label create risk:high --description "Security, data, production impact" --color "B60205"
  gh label create risk:medium --description "Affects workflow but contained" --color "FB8500"
  gh label create confidence:low --description "Needs validation or exploration" --color "A89968"
  gh label create confidence:unconfirmed --description "Community-reported, unverified" --color "D4A574"
  gh label create type:feature --description "New feature or capability" --color "1F883D"
  gh label create type:bug --description "Something isn't working" --color "D1242F"
  ```
- [ ] Verify all 12 created: `gh label list | grep -E "effort:|status:|risk:|confidence:|type:"`

### Phase 2: Create labels.json (Durable Governance)
- [ ] Create `.github/labels.json` documenting schema:
  ```json
  {
    "labels": [
      {
        "name": "effort:small",
        "description": "1–2 days work",
        "color": "7FBA00",
        "category": "effort"
      },
      // ... all 28 labels with descriptions and categories
    ],
    "schema": {
      "area": "Subsystem or component",
      "priority": "Urgency and importance",
      "type": "Type of work",
      "effort": "Estimated effort (new)",
      "status": "Workflow status (new)",
      "risk": "Impact risk level (new)",
      "confidence": "Confidence/validation level (new)"
    }
  }
  ```

### Phase 3: Retroactively Label Existing Issues/PRs
- [ ] Script or manually apply labels to all open and closed issues based on:
  - **Effort:** Estimate from issue description, scope, complexity
  - **Status:** Closed = `status:ready` (completed); open without blockers = `status:ready`; open with blockers = `status:blocked`
  - **Risk:** From issue impact (security, data, production) or area
  - **Confidence:** From issue clarity (well-defined vs. exploratory)
  - **Type:** From issue title and body (feature, bug, docs, community)

**Suggested approach:**
```bash
# For each issue #N:
gh issue view N --json labels,body,state | \
  jq -r '.state, .body' | \
  # Determine effort, risk, status, confidence based on body and state
  # Apply appropriate labels
  # gh issue edit N --add-label "effort:X,risk:Y,status:Z"
```

- [ ] Batch process open issues (likely 8–15 to label)
- [ ] Batch process closed issues/PRs in Phase 1 (PRs #27, #28, #33, #38, #39, #41, #43, plus related closed issues)

### Phase 4: Update Documentation
- [ ] Update `CONTRIBUTING.md`:
  ```markdown
  ## Labels & Issue Classification
  
  Issues are labeled for filtering, dashboarding, and workflow tracking:
  - **AREA:** Component (governance, reporting, scheduling, script)
  - **PRIORITY:** Urgency (high, medium, low)
  - **TYPE:** Work type (feature, bug, docs, community-contribution)
  - **EFFORT:** Estimated size (small, medium, large)
  - **STATUS:** Workflow state (ready, blocked, stalled)
  - **RISK:** Impact level (high, medium)
  - **CONFIDENCE:** Validation level (low, unconfirmed)
  
  See .github/labels.json for full schema.
  ```

- [ ] Update `docs/README.md` with reference to labels governance

### Phase 5: Update Memories & Governance
- [ ] Create memory file: `label-schema-goldilocks.md`
  - Documents the schema and rationale
  - Links to .github/labels.json
  - Provides examples of when to use each label
  
- [ ] Update `.claude/projects/.../memory/MEMORY.md` with link to label schema

- [ ] Update `CONTRIBUTING.md` to reference memory and schema

### Phase 6: Archive Unused Labels
- [ ] Archive (hide, don't delete) unused defaults:
  - `bug` (use `type:bug`)
  - `enhancement` (use `type:feature`)
  - `documentation` (use `type:docs`)
  - `good` (unused)
  - `question` (use comments)
  - `wontfix` (document in issue)
  - `invalid` (document in issue)
  - `github_actions` (move to PR description)
  - `help` (use `help-wanted`)

---

## Verification Checklist (for PR)

- [ ] All 12 new labels created and visible: `gh label list`
- [ ] `.github/labels.json` exists with all 28 labels documented
- [ ] All open issues labeled (at least area + priority + type + effort + status)
- [ ] All Phase 1 closed issues/PRs retroactively labeled (sample 5+ to verify)
- [ ] CONTRIBUTING.md updated with label guidelines
- [ ] Memory file created and linked in MEMORY.md
- [ ] No orphaned/unused labels remain active
- [ ] CHANGELOG.md updated per CONTRIBUTING.md
- [ ] `scripts/check --all` passes

---

## Notes

### Why Goldilocks Schema?
- **Not too simple** (current 19 labels insufficient for dashboarding)
- **Not too complex** (ecg repo may have 50+; this is ~28, manageable)
- **Just right** (sufficient for effort/risk/status filtering + Projects views)

### Retroactive Labeling Strategy
- Use issue/PR body, scope, and complexity to estimate effort
- Use issue area and impact to estimate risk
- Use issue clarity to assess confidence
- Be pragmatic: if effort is unclear, use `effort:medium` default
- Document decisions in commit message for future reference

### Cross-Project Standardization
This schema can be applied to ecg_anomaly_detection and github-portfolio-modernization after macos-system-health is validated. Update would be simple (copy .github/labels.json, add to CONTRIBUTING.md, retroactively label).

---

## Links

- Issue #45: https://github.com/Jared-Godar/macos-system-health/issues/45
- GitHub Projects documentation: https://docs.github.com/en/issues/planning-and-tracking-with-projects

---

**Executor:** This is a governance + operational task. Create labels, retroactively apply to existing issues/PRs, document schema, and update memories/docs. All verification steps must pass before announcing merge readiness.
