# Issue #40: Commit Durable PM Artifacts and Implement Commit Gate

**Tracking issue:** #40
**Branch:** `housekeeping/commit-pm-artifacts`
**Milestone:** v1.0

---

## What This Does

Cleans up accumulated uncommitted PM artifacts and commits the durable governance fix that prevents future accumulation.

---

## Scope: Files to Commit

### 1. Executor Prompt Specifications (4 files)
These are durable PM artifacts that live in version control:
- `prompts/2026-07-20-issues-7-24-retention-cleanup.md` (spec for Issues #7+#24, used in PR #33)
- `prompts/2026-07-21-issue-9-adr-report-maintenance-boundaries.md` (spec for Issue #9, used in PR #39)
- `prompts/2026-07-21-issues-34-36-governance-automation-and-docs.md` (spec for Issues #34-36, used in PR #38)
- `prompts/EXECUTOR-SEED-PROMPT-TEMPLATE.md` (updated template with pre-merge gate + notes)

### 2. Governance Memory File (1 file)
- `.claude/projects/-Users-jaredgodar-Code-portfolio-macos-system-health/memory/pm-artifact-commit-gate.md`
  (Durable contract: PM must commit artifacts immediately after creation)

### 3. Memory Index (1 file)
- `.claude/projects/-Users-jaredgodar-Code-portfolio-macos-system-health/memory/MEMORY.md`
  (Updated to link new pm-artifact-commit-gate entry)

---

## Implementation Checklist

- [ ] **Create feature branch:**
  ```fish
  git checkout -b housekeeping/commit-pm-artifacts
  ```

- [ ] **Verify files exist and are untracked:**
  ```fish
  git status
  ```
  Should show all 4 prompt files as untracked (`??`)

- [ ] **Stage all files:**
  ```fish
  git add prompts/2026-07-20-issues-7-24-retention-cleanup.md \
          prompts/2026-07-21-issue-9-adr-report-maintenance-boundaries.md \
          prompts/2026-07-21-issues-34-36-governance-automation-and-docs.md \
          prompts/EXECUTOR-SEED-PROMPT-TEMPLATE.md \
          .claude/projects/-Users-jaredgodar-Code-portfolio-macos-system-health/memory/pm-artifact-commit-gate.md \
          .claude/projects/-Users-jaredgodar-Code-portfolio-macos-system-health/memory/MEMORY.md
  ```

- [ ] **Verify staged changes:**
  ```fish
  git status
  ```
  Should show 6 files ready to commit (A = added)

- [ ] **Commit with proper message:**
  ```fish
  git commit -m "Add executor seed prompt specifications and implement PM commit gate

- Issue #7+#24: executor prompt spec for log/backup retention (PR #33)
- Issue #9: executor prompt spec for ADR (PR #39)
- Issue #34-#36: executor prompt spec for project automation (PR #38)
- Template: standardized seed prompt format with pre-merge gate verification
- Governance: PM artifact commit gate (memory) enforcing immediate commit of durable specs

Prevents uncommitted PM artifacts from accumulating. Durable artifacts (prompts/,
memory files) must be committed immediately after creation per new gate.

Fixes #40

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
  ```

- [ ] **Push branch:**
  ```fish
  git push -u origin housekeeping/commit-pm-artifacts
  ```

- [ ] **Open PR:**
  ```fish
  gh pr create \
    --title "Commit durable PM artifacts and implement artifact commit gate (#40)" \
    --body "Commits durable PM executor prompt specifications and governance memory file.

## What's being committed:
- 4 executor prompt specifications (reused across PRs #33, #38, #39)
- 1 governance memory file (pm-artifact-commit-gate.md)
- Updated MEMORY.md index

## Why:
PM artifacts were created but left uncommitted, accumulating as untracked changes.
New gate ensures future PM sessions commit durable artifacts immediately.

## Verification:
- All CI checks pass
- Durable artifacts now tracked in version control
- Memory file implements gate for future sessions
- Working tree clean after merge

Fixes #40" \
    --head housekeeping/commit-pm-artifacts \
    --base main \
    --label "documentation,area:governance" \
    --milestone "v1.0" \
    --assignee "@me"
  ```

- [ ] **Verify CI passes:**
  ```fish
  gh pr checks <PR_NUMBER>
  ```
  All checks should pass (markdown, gitleaks, quality)

- [ ] **Run local verification:**
  ```fish
  scripts/check --all
  ```
  Should pass before announcing merge readiness

---

## Verification Checklist (for PR)

- [ ] All 4 prompt specification files committed
- [ ] pm-artifact-commit-gate.md memory file committed
- [ ] MEMORY.md updated with link to new gate
- [ ] Commit message references Issue #40 (Fixes #40)
- [ ] PR metadata complete (labels, milestone, assignee)
- [ ] CI checks all pass (6/6)
- [ ] `scripts/check --all` passes locally
- [ ] Working tree clean after staging all files

---

## Notes

- **Why this is a housekeeping task:** No new features or bug fixes; purely governance/cleanup
- **Why it needs a PR:** Branch protection requires all main commits to come via PR
- **Durable artifact definition:** Files in `prompts/` and `.claude/projects/.../memory/` that persist across sessions and are meant to be discovered/referenced by future work
- **Session artifact definition:** Files in `artifacts/` that are gitignored; only exist during a session for handoff/walkthrough purposes

---

## Links

- Issue #40: https://github.com/Jared-Godar/macos-system-health/issues/40
- Related memory gate: `pm-artifact-commit-gate.md`
- Related prompts: All specifications in `prompts/` directory

---

**Executor:** This is a straightforward housekeeping task. Stage the untracked files, commit with the message template above, open PR, verify CI, announce merge readiness. All verification steps must pass before merge.
