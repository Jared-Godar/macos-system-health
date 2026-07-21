# Claude Code Executor Task: Cross-Project Durable Contracts Enforcement (ecg #269, github-portfolio-modernization #71)

## ⚠️ READ FIRST — Durable Contracts and Standing Rules

**ALWAYS:** Before executing any steps, read and follow:
1. **CLAUDE.md** (global user instructions — standing rules for ALL projects)
2. **AGENTS.md** or equivalent (project-specific agent contracts)
3. **CONTRIBUTING.md** (repo workflow and merge gates)
4. **Memory files** in `.claude/projects/*/memory/` (cross-project standing rules, lessons learned)
5. **GOVERNANCE.md** or equivalent (labels, milestones, versioning)

These contracts are **always means always** — they apply throughout execution, not just as context. If any conflict arises between this prompt and the durable contracts, the durable contract wins. Verify alignment before proceeding.

---

## Context (read first — you are an executor session)

Two repos have pending, uncommitted changes from the durable contract enforcement pass (2026-07-20). These changes must be committed, pushed, and merged via PR in both repos. This is a follow-up to macos-system-health work (already committed 95120f9).

**Changes pending:**
- ecg_anomaly_detection: `.gitignore` comment clarified, CONTRIBUTING.md post-merge closure section added
- github-portfolio-modernization: AGENTS.md executor session clause updated (durable contract reading mandated)

**Issues to close:**
- ecg_anomaly_detection #269 (to be created via commit message)
- github-portfolio-modernization #71 (to be created via commit message)

## Procedure

Execute two sequential PRs, one per repo. Same pattern: branch, verify changes, commit with issue reference, push, open draft PR.

### Part 1: ecg_anomaly_detection

**Repository:** `Jared-Godar/ecg_anomaly_detection`

**Changed files (verify they exist and have changes):**
- `.gitignore` — session artifact storage comment expanded
- `CONTRIBUTING.md` — post-merge closure pass section added, executor prompts durable contracts section added

**Steps:**

1. Navigate to ecg_anomaly_detection repo, sync main:
   ```bash
   cd ~/Developer/portfolio/ecg_anomaly_detection
   git fetch origin
   git switch main
   git pull --ff-only origin main
   ```

2. Verify pending changes exist:
   ```bash
   git status
   ```
   Expected: `.gitignore` and `CONTRIBUTING.md` show as modified (or untracked if not staged).

3. Create branch: `governance/durable-contracts-enforcement`

4. Stage and review changes:
   ```bash
   git diff .gitignore CONTRIBUTING.md
   ```
   Verify: comments explain session artifact storage pattern, post-merge closure steps are clear, executor prompt durable contracts section present.

5. Commit:
   ```bash
   git commit -m "Document durable contracts and post-merge automation

Add/clarify .gitignore comment explaining session artifact storage pattern
(tracked artifacts in prompts/docs vs. session-specific in artifacts/).

Add executor prompts durable contracts section to CONTRIBUTING.md: all executor
specs must begin by reading CLAUDE.md, AGENTS.md, memory files, and governance
docs. Durable contracts are binding throughout execution.

Add post-merge closure pass section documenting the canonical workflow: verify
merge, pull main, delete branches, preserve session artifacts, verify clean state.

Cross-project canonical rule enforcement (macos-system-health already committed).

Fixes #269"
   ```

6. Push:
   ```bash
   git push origin governance/durable-contracts-enforcement
   ```

7. Open draft PR:
   ```bash
   gh pr create \
     --title "Document durable contracts enforcement and post-merge automation (fixes #269)" \
     --body "## What
Add/clarify .gitignore comment, add durable contracts section to CONTRIBUTING.md,
document post-merge closure pass as canonical SOP.

## Why
Executor sessions must always read and follow durable contracts (CLAUDE.md, AGENTS.md,
memory files, governance docs). This is now explicit and mandatory across all repos.
Post-merge closure (verify, pull, delete branches, preserve artifacts) is canonical
and must be documented in every project.

## How
- Enhanced .gitignore comment (session artifact storage pattern)
- Added executor prompts durable contracts section to CONTRIBUTING.md
- Added post-merge closure pass section to CONTRIBUTING.md
- Consistent with macos-system-health and github-portfolio-modernization

## Testing
- [x] Changes reviewed (git diff)
- [x] No functional changes (documentation only)

Fixes #269" \
     --draft \
     --label "type:chore,area:governance"
   ```

8. Verify and report:
   ```bash
   gh pr view <PR_NUMBER> --json number,title,url,labels
   ```

### Part 2: github-portfolio-modernization

**Repository:** `Jared-Godar/github-portfolio-modernization`

**Changed files (verify they exist and have changes):**
- `AGENTS.md` — executor session clause updated to mandate durable contract reading

**Steps:**

1. Navigate to github-portfolio-modernization repo, sync main:
   ```bash
   cd ~/Code/portfolio/github-portfolio-modernization
   git fetch origin
   git switch main
   git pull --ff-only origin main
   ```

2. Verify pending changes:
   ```bash
   git status
   ```
   Expected: `AGENTS.md` shows as modified.

3. Create branch: `governance/executor-durable-contracts`

4. Review changes:
   ```bash
   git diff AGENTS.md
   ```
   Verify: executor session clause now mandates reading durable contracts before proceeding.

5. Commit:
   ```bash
   git commit -m "Mandate durable contract reading in executor sessions

Update AGENTS.md executor session clause to explicitly require reading and
following all durable contracts before execution:
- CLAUDE.md (global standing rules)
- AGENTS.md (project-specific contracts)
- CONTRIBUTING.md (repo workflow)
- Memory files (cross-project rules, lessons learned)
- GOVERNANCE.md (labels, milestones)

If any conflict arises between a prompt and durable contracts, the durable
contract wins. All executor specs must begin with explicit instruction to read
these contracts.

Cross-project canonical rule enforcement.

Fixes #71"
   ```

6. Push:
   ```bash
   git push origin governance/executor-durable-contracts
   ```

7. Open draft PR:
   ```bash
   gh pr create \
     --title "Mandate durable contract reading in executor sessions (fixes #71)" \
     --body "## What
Update AGENTS.md executor session clause to explicitly require reading and following
all durable contracts (CLAUDE.md, AGENTS.md, memory files, governance docs) before
executing any work.

## Why
Executor prompts can become stale; durable contracts live in version control and
evolve with the project. The 'always means always' principle requires that every
session reads the latest contracts before proceeding.

## How
- Enhanced executor sessions clause in AGENTS.md
- Clarified that durable contracts are binding throughout execution
- Stated that all executor specs must begin with explicit contract reading instruction
- Consistent with macos-system-health and ecg_anomaly_detection

## Testing
- [x] Changes reviewed (git diff)
- [x] No functional changes (documentation only)

Fixes #71" \
     --draft \
     --label "type:chore,area:governance"
   ```

8. Verify and report:
   ```bash
   gh pr view <PR_NUMBER> --json number,title,url,labels
   ```

## Deliverables (both repos)

**ecg_anomaly_detection:**
1. Branch `governance/durable-contracts-enforcement` pushed ✓
2. `.gitignore` and `CONTRIBUTING.md` committed ✓
3. Draft PR created (link in verification) ✓
4. Labels: type:chore, area:governance ✓

**github-portfolio-modernization:**
1. Branch `governance/executor-durable-contracts` pushed ✓
2. `AGENTS.md` committed ✓
3. Draft PR created (link in verification) ✓
4. Labels: type:chore, area:governance ✓

## Workflow requirements

**For both repos:**
- Branches from synced main
- Commit messages cite the issue number (#269 or #71)
- Draft PRs (Jared squash-merges manually via GitHub GUI)
- Labels include `type:chore` and `area:governance`
- No functional changes (documentation only)
- Changes must be staged/ready before starting (verify with `git status`)

## Verification (report each)

**ecg_anomaly_detection #269:**
- Sync complete (git pull --ff-only succeeded) ✓
- Changes verified (git diff showed .gitignore and CONTRIBUTING.md) ✓
- Branch created and pushed ✓
- Commit message includes #269 ✓
- Draft PR created (link) ✓
- Labels: type:chore, area:governance ✓

**github-portfolio-modernization #71:**
- Sync complete (git pull --ff-only succeeded) ✓
- Changes verified (git diff showed AGENTS.md) ✓
- Branch created and pushed ✓
- Commit message includes #71 ✓
- Draft PR created (link) ✓
- Labels: type:chore, area:governance ✓

Report PR links and verification checks back to PM thread. Both PRs remain DRAFT awaiting manual squash-merge via GitHub GUI.

## Safety rules (must NOT happen)

- No changes beyond .gitignore, CONTRIBUTING.md, AGENTS.md
- No commits to main; no merging
- No scope creep (durable contracts documentation only)
- Both repos must be in clean state before starting (sync main first)
- If either repo shows no pending changes, halt and report to PM
