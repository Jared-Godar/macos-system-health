# Issues #34–#36: Project Metadata Automation & Documentation

**Tracking issues:** #34, #35, #36
**Branch:** `feature/project-metadata-automation`
**Milestone:** v1.0

---

## What This Does

Closes the governance gap discovered during PR #33 closure by:
1. **Automating** PR project membership via GitHub Actions workflow
2. **Documenting** project workflow expectations in CONTRIBUTING.md
3. **Reminding** users via PR template checkbox to verify project membership

Result: Future PRs are auto-added to the project; no manual workarounds needed.

---

## Requirements

### Issue #34: GitHub Actions Workflow (`add-pr-to-project.yml`)

**File:** `.github/workflows/add-pr-to-project.yml`

**Trigger:**
- `pull_request: [opened, reopened]`
- Runs on workflow `push` to allow testing of workflow itself

**Logic:**
1. Check if PR body or title contains `Fixes #N` (using regex: `Fixes #(\d+)`)
2. Extract issue number from link
3. Query GitHub Projects API: is issue #N in "macOS System Health Roadmap" project?
4. If **yes**: Add PR to same project with status **"Todo"** (or "In Progress" if workflow allows)
5. If **no** or issue not found: Log and exit gracefully (no-op, workflow passes)

**Implementation notes:**
- Use `github.event.pull_request.body` and `github.event.pull_request.title` to find issue link
- Use GitHub Projects API v2 (not deprecated v1): find project by name and owner
- Add PR to project using `projectsV2.addDraftIssue` or equivalent mutation
- Handle permissions: ensure token has `read:project` + `write:project` scopes
- Error handling: workflow must pass even if project API fails (graceful degradation)

**Testing:**
- Manually create a test PR linking an issue in the project; verify it auto-adds
- Create a test PR linking an issue NOT in the project; verify it exits gracefully

**Workflow file structure:**
```yaml
name: Auto-add PR to Project
on:
  pull_request:
    types: [opened, reopened]

jobs:
  add-to-project:
    runs-on: ubuntu-latest
    steps:
      - name: Add PR to project
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            # Extract issue number from PR body/title
            # Query project for membership
            # Add PR if issue is in project
```

---

### Issue #35: CONTRIBUTING.md Update

**File:** `CONTRIBUTING.md`

**Location:** New section under "Branch, pull request, and merge workflow"

**Content to add:**

```markdown
## Project Tracking

Every pull request that links a tracked issue must be added to the
"macOS System Health Roadmap" project.

- Project membership is **automatically verified** by a GitHub Actions
  workflow that runs when the PR is opened.
- If automation fails (rare), manually add the PR to the project before merge.
- Verify both the linked issue(s) and the PR have consistent status
  (e.g., both "Todo" or both "In Progress").

**Verification checklist:**
- [ ] PR links an issue using `Fixes #N` syntax
- [ ] Linked issue is in the "macOS System Health Roadmap" project
- [ ] PR has been added to the project (check PR details sidebar)
```

**Notes:**
- Keep it brief (3–5 sentences + checklist)
- Mention that automation is standard, manual add is fallback
- Emphasize consistency (both issue + PR should have matching status)

---

### Issue #36: PR Template Update

**File:** `.github/pull_request_template.md`

**Addition:** New section at end of template

```markdown
## Project Tracking

- [ ] This PR has been added to the "macOS System Health Roadmap"
      project (auto-verified by CI workflow)
```

**Notes:**
- Checkbox is for human verification, not strictly enforced
- References the automation from issue #34
- Placed near existing checklist sections (Changelog, testing verification)

---

## Implementation Checklist

- [ ] **Issue #34 — Workflow:**
  - [ ] Create `.github/workflows/add-pr-to-project.yml`
  - [ ] Implement issue-number extraction logic (regex)
  - [ ] Implement project lookup (by name "macOS System Health Roadmap")
  - [ ] Implement PR add logic (API call with proper token scope)
  - [ ] Test: PR linking in-project issue auto-adds
  - [ ] Test: PR linking out-of-project issue gracefully no-ops
  - [ ] Test: malformed `Fixes` link gracefully no-ops

- [ ] **Issue #35 — CONTRIBUTING.md:**
  - [ ] Add "Project Tracking" section to workflow documentation
  - [ ] Include brief explanation, automation note, fallback instructions
  - [ ] Add verification checklist (3 items)
  - [ ] Review for tone (should fit adjacent documentation)

- [ ] **Issue #36 — PR Template:**
  - [ ] Add "Project Tracking" section to `.github/pull_request_template.md`
  - [ ] Use checkbox format consistent with existing template
  - [ ] Reference automation

- [ ] **Testing (all three issues):**
  - [ ] Run `scripts/check --all` locally (passes lint, syntax, tests)
  - [ ] Create a test PR linking a v1.0 issue to trigger workflow
  - [ ] Verify test PR auto-adds to project
  - [ ] Verify test PR shows checkbox in template
  - [ ] Merge test PR and verify project status transitions (if applicable)

---

## Changelog

Add to `[Unreleased] ### Added` section:

```markdown
- Governance: GitHub Actions workflow to auto-add PRs to "macOS System
  Health Roadmap" project when they link tracked issues (#34).
- Docs: Project tracking workflow documentation in CONTRIBUTING.md (#35).
- Docs: Project tracking verification checklist in PR template (#36).
```

---

## Branch & Workflow

1. **Branch:** `feature/project-metadata-automation`
2. **Commits:** Logical units (workflow, docs, template updates)
3. **Pre-push:** `scripts/check --all` passes
4. **PR template:** Link issues (#34, #35, #36), confirm automation works, reference workflow test
5. **Labels:** `documentation`, `area:governance`
6. **Milestone:** `v1.0`

---

## Verification Checklist (for PR)

- [ ] Workflow file is syntactically valid YAML
- [ ] Workflow runs on PR opened/reopened events
- [ ] Test PR linking in-project issue is auto-added to project
- [ ] Test PR linking out-of-project issue doesn't error (graceful no-op)
- [ ] Workflow logs are clear and helpful (no confusing error messages)
- [ ] CONTRIBUTING.md section is brief, clear, and consistent with adjacent docs
- [ ] PR template checkbox is present and formatted correctly
- [ ] CHANGELOG.md updated in this PR
- [ ] All existing checks pass (`scripts/check --all`)

---

## Notes

### Workflow Implementation Tips

- **GitHub Actions environment:** Use `github-script` action with GraphQL queries for best API support
- **Project lookup:** Query by project name (case-sensitive): `repository.projectsV2(first: 10)` filtered by name
- **Issue extraction:** Use regex `/Fixes\s+#(\d+)/i` to find issue number (case-insensitive)
- **Error handling:** Log failures but don't fail the workflow; project membership is nice-to-have, not blocking
- **Token scopes:** `GITHUB_TOKEN` may need explicit `read:project` + `write:project` permissions; check workflow permissions section

### Testing PR

Once you create the workflow, open a test PR linking issue #34 or #35 (which are in v1.0 project). Verify it auto-adds. This test PR can be closed after verification; it's just to confirm automation works.

---

## Links

- Issue #34: https://github.com/Jared-Godar/macos-system-health/issues/34
- Issue #35: https://github.com/Jared-Godar/macos-system-health/issues/35
- Issue #36: https://github.com/Jared-Godar/macos-system-health/issues/36
- Milestone v1.0: https://github.com/Jared-Godar/macos-system-health/milestone/1
- Related (PR #33 closure that discovered this gap): https://github.com/Jared-Godar/macos-system-health/pull/33

---

**Executor:** Use this as your detailed spec. Read it fully before starting. All verification steps must pass locally and in the test PR before opening the final PR for merge.
