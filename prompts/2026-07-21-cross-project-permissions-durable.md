# Claude Code Executor Task: Cross-Project Permissions Allowlist Durability (All 3 Projects)

## ⚠️ READ FIRST — Durable Contracts and Standing Rules

**ALWAYS:** Before executing any steps, read and follow:
1. **CLAUDE.md** (global user instructions — standing rules for ALL projects)
2. **AGENTS.md** or equivalent (project-specific agent contracts)
3. **CONTRIBUTING.md** (repo workflow and merge gates)
4. **Memory files** in `.claude/projects/*/memory/` (cross-project standing rules)
5. **GOVERNANCE.md** or equivalent (labels, milestones, versioning)

These contracts are **always means always** — they apply throughout execution, not just as context. If any conflict arises between this prompt and the durable contracts, the durable contract wins. Verify alignment before proceeding.

---

## Context (read first — you are an executor session)

Three repos have uncommitted `.claude/settings.json` files (permissions allowlist) created during this session's VSCode chat. These files are critical for minimizing permission prompts in VSCode and CLI executor sessions. They must be committed and pushed via PRs across all three projects to make them durable and available to all future sessions (including cloud agents and cold-start CLI runs).

**Changes pending (local, uncommitted):**
- macos-system-health: `.claude/settings.json` (new)
- ecg_anomaly_detection: `.claude/settings.json` (new)
- github-portfolio-modernization: `.claude/settings.json` (new) + `.gitignore` (modified, session artifact comment)

**Why this matters:** Settings files are not inherited from the user's global ~/.claude/settings.json when sessions start fresh (cloud agents, new CLI windows). By committing these project-level allowlists to main, all future sessions automatically pick up the permissions without requiring manual setup.

## Procedure

Execute three parallel PRs (one per repo), all with identical content and workflow. Same pattern for all: stage → branch → verify → commit → push → open draft PR.

### Part 1: macos-system-health

**Repository:** `Jared-Godar/macos-system-health`

**Changed files (verify they exist locally):**
- `.claude/settings.json` — comprehensive permissions allowlist (new file)

**Steps:**

1. Navigate to macos-system-health repo:
   ```fish
   cd ~/Code/portfolio/macos-system-health
   git fetch origin
   git switch main
   git pull --ff-only origin main
   ```

2. Verify pending changes exist:
   ```fish
   git status
   ```
   Expected: `.claude/settings.json` shows as untracked.

3. Create branch:
   ```fish
   git switch -c infrastructure/permissions-allowlist
   ```

4. Stage and review changes:
   ```fish
   git add .claude/settings.json
   git diff --cached .claude/settings.json | head -30
   ```
   Verify: categorical rules (Bash, Read, Edit, Write, etc.) are present, defaultMode: auto is set.

5. Commit:
   ```fish
   git commit -m "Add comprehensive permissions allowlist for executor sessions

Canonical .claude/settings.json with:
- Categorical permission rules (Bash, Read, Edit, Write, Glob, Grep, WebFetch, WebSearch, Skill)
- Project-specific paths for read/write scope
- defaultMode: auto to enable auto-approval of non-destructive operations

This eliminates permission prompts during normal executor work in VSCode and CLI,
consistent with global ~/.claude/settings.json pattern. Committed to make permissions
durable across all sessions (CLI, VSCode, cloud agents).

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
   ```

6. Push:
   ```fish
   git push origin infrastructure/permissions-allowlist
   ```

7. Open draft PR:
   ```fish
   gh pr create \
     --title "Add comprehensive permissions allowlist for executor sessions" \
     --body "## What
Add .claude/settings.json with canonical permissions configuration.

## Why
Sessions starting fresh (cloud agents, new CLI windows, VSCode on new machine) don't inherit user's global ~/.claude/settings.json. By committing project-level permissions, all future sessions automatically pick up the allowlist without manual setup.

## How
- Categorical rules: Bash, Read, Edit, Write, Glob, Grep, WebFetch, WebSearch, Skill
- Project paths: scoped to /Users/jaredgodar/Code/portfolio/macos-system-health/**
- defaultMode: auto enables auto-approval of matching operations

## Testing
- [x] Rules reviewed (git diff)
- [x] No code changes (settings only)
- [x] Consistent with cross-project canonical pattern

no changelog entry needed — infrastructure configuration only" \
     --draft \
     --label "type: chore,area: infrastructure"
   ```

8. Verify and report:
   ```fish
   gh pr view (gh pr list --limit 1 --json number --jq -r '.[0].number') --json number,title,url,labels
   ```

### Part 2: ecg_anomaly_detection

**Repository:** `Jared-Godar/ecg_anomaly_detection`

**Changed files (verify they exist locally):**
- `.claude/settings.json` — comprehensive permissions allowlist (new file)

**Steps:**

1. Navigate to ecg_anomaly_detection repo:
   ```fish
   cd ~/Developer/portfolio/ecg_anomaly_detection
   git fetch origin
   git switch main
   git pull --ff-only origin main
   ```

2. Verify pending changes exist:
   ```fish
   git status
   ```
   Expected: `.claude/settings.json` shows as untracked.

3. Create branch:
   ```fish
   git switch -c infrastructure/permissions-allowlist
   ```

4. Stage and review changes:
   ```fish
   git add .claude/settings.json
   git diff --cached .claude/settings.json | head -30
   ```
   Verify: categorical rules and defaultMode: auto present.

5. Commit (same message as Part 1):
   ```fish
   git commit -m "Add comprehensive permissions allowlist for executor sessions

Canonical .claude/settings.json with:
- Categorical permission rules (Bash, Read, Edit, Write, Glob, Grep, WebFetch, WebSearch, Skill)
- Project-specific paths for read/write scope
- defaultMode: auto to enable auto-approval of non-destructive operations

This eliminates permission prompts during normal executor work in VSCode and CLI,
consistent with global ~/.claude/settings.json pattern. Committed to make permissions
durable across all sessions (CLI, VSCode, cloud agents).

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
   ```

6. Push:
   ```fish
   git push origin infrastructure/permissions-allowlist
   ```

7. Open draft PR:
   ```fish
   gh pr create \
     --title "Add comprehensive permissions allowlist for executor sessions" \
     --body "## What
Add .claude/settings.json with canonical permissions configuration.

## Why
Sessions starting fresh (cloud agents, new CLI windows, VSCode on new machine) don't inherit user's global ~/.claude/settings.json. By committing project-level permissions, all future sessions automatically pick up the allowlist without manual setup.

## How
- Categorical rules: Bash, Read, Edit, Write, Glob, Grep, WebFetch, WebSearch, Skill
- Project paths: scoped to /Users/jaredgodar/Developer/portfolio/ecg_anomaly_detection/**
- defaultMode: auto enables auto-approval of matching operations

## Testing
- [x] Rules reviewed (git diff)
- [x] No code changes (settings only)
- [x] Consistent with cross-project canonical pattern

no changelog entry needed — infrastructure configuration only" \
     --draft \
     --label "type: chore,area: infrastructure"
   ```

8. Verify and report:
   ```fish
   gh pr view (gh pr list --limit 1 --json number --jq -r '.[0].number') --json number,title,url,labels
   ```

### Part 3: github-portfolio-modernization

**Repository:** `Jared-Godar/github-portfolio-modernization`

**Changed files (verify they exist locally):**
- `.claude/settings.json` — comprehensive permissions allowlist (new file)
- `.gitignore` (modified) — session artifact comment clarification

**Steps:**

1. Navigate to github-portfolio-modernization repo:
   ```fish
   cd ~/Code/portfolio/github-portfolio-modernization
   git fetch origin
   git switch main
   git pull --ff-only origin main
   ```

2. Verify pending changes exist:
   ```fish
   git status
   ```
   Expected: `.claude/settings.json` (untracked) and `.gitignore` (modified).

3. Create branch:
   ```fish
   git switch -c infrastructure/permissions-allowlist
   ```

4. Stage and review changes:
   ```fish
   git add .claude/settings.json .gitignore
   git diff --cached | head -50
   ```
   Verify: settings.json has categorical rules; .gitignore comment is clear.

5. Commit:
   ```fish
   git commit -m "Add comprehensive permissions allowlist and clarify session artifact storage

Changes:
- Add .claude/settings.json with canonical permissions configuration
- Clarify .gitignore comment on session artifact storage (tracked vs session-specific)

Why: Settings files committed to repo ensure all future sessions (CLI, VSCode, cloud agents)
automatically pick up the permissions allowlist without manual setup. Solves permission
prompts in fresh-start sessions.

Permissions include categorical rules (Bash, Read, Edit, Write, Glob, Grep, WebFetch,
WebSearch, Skill) and project-scoped paths with defaultMode: auto for non-destructive
operations.

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
   ```

6. Push:
   ```fish
   git push origin infrastructure/permissions-allowlist
   ```

7. Open draft PR:
   ```fish
   gh pr create \
     --title "Add permissions allowlist and clarify session artifact storage" \
     --body "## What
- Add .claude/settings.json with canonical permissions configuration
- Clarify .gitignore session artifact storage documentation

## Why
Settings files committed to repo ensure all future sessions (CLI, VSCode, cloud agents) automatically pick up the permissions allowlist. Eliminates permission prompts in fresh-start scenarios.

## How
- Categorical rules: Bash, Read, Edit, Write, Glob, Grep, WebFetch, WebSearch, Skill
- Project paths: scoped to /Users/jaredgodar/Code/portfolio/github-portfolio-modernization/**
- defaultMode: auto for auto-approval of non-destructive operations
- Enhanced .gitignore with explicit session artifact storage pattern

## Testing
- [x] Settings reviewed (git diff)
- [x] No code changes (settings/docs only)
- [x] Consistent with canonical cross-project pattern

no changelog entry needed — infrastructure configuration only" \
     --draft \
     --label "type: chore,area: infrastructure"
   ```

8. Verify and report:
   ```fish
   gh pr view (gh pr list --limit 1 --json number --jq -r '.[0].number') --json number,title,url,labels
   ```

## Deliverables (all repos)

1. Branch `infrastructure/permissions-allowlist` pushed to each repo
2. `.claude/settings.json` committed with canonical permissions
3. `.gitignore` clarified in github-portfolio-modernization
4. Draft PR created for each repo with full metadata
5. Labels: `type: chore`, `area: infrastructure`

## Workflow requirements

**For all three repos:**
- Branches from synced main
- Commit messages cite the permissions allowlist work
- Draft PRs (Jared squash-merges manually via GitHub GUI)
- Labels include `type: chore` and `area: infrastructure`
- No code changes (settings/documentation only)
- Changes must be staged/ready before starting (verify with `git status`)

## Verification (report each)

**macos-system-health:**
- Sync complete (git pull --ff-only succeeded) ✓
- Changes verified (git diff showed .claude/settings.json) ✓
- Branch created and pushed ✓
- Draft PR created (link) ✓
- Labels: type:chore, area:infrastructure ✓

**ecg_anomaly_detection:**
- Sync complete (git pull --ff-only succeeded) ✓
- Changes verified (git diff showed .claude/settings.json) ✓
- Branch created and pushed ✓
- Draft PR created (link) ✓
- Labels: type:chore, area:infrastructure ✓

**github-portfolio-modernization:**
- Sync complete (git pull --ff-only succeeded) ✓
- Changes verified (git diff showed .claude/settings.json and .gitignore) ✓
- Branch created and pushed ✓
- Draft PR created (link) ✓
- Labels: type:chore, area:infrastructure ✓

Report PR links and verification checks back to PM thread. All PRs remain DRAFT awaiting manual squash-merge via GitHub GUI.

## Safety rules (must NOT happen)

- No changes beyond .claude/settings.json and .gitignore
- No commits to main; no merging
- No scope creep (infrastructure/permissions only)
- All three repos must be in clean state before starting (sync main first, verify with git status)
- All three repos must have matching commit messages (same permissions work across all)
- If any repo shows no pending changes, halt and report to PM
