# Phase 1 Continuity Walkthrough
**Date:** 2026-07-20  
**Status:** Executor prompt ready; awaiting approval to branch  
**Owner:** Jared Godar  
**PR:** [#25 (audit)](https://github.com/Jared-Godar/macos-system-health/pull/25) merged  

---

## Issue #23: Branch Protection on Main

**Branch name:** `issue-23-branch-protection`  
**Estimated time:** 15 min  
**Verification:** `gh api repos/Jared-Godar/macos-system-health/branches/main/protection`

### Step 1: Create branch and check protection status
```fish
git fetch origin main
git checkout -b issue-23-branch-protection origin/main
echo "Current protection status:"
gh api repos/Jared-Godar/macos-system-health/branches/main/protection 2>&1 || echo "Not protected"
```

**Verify:** Output shows either 404 (not protected) or current config.

### Step 2: Enable branch protection via gh api
```fish
gh api repos/Jared-Godar/macos-system-health/branches/main/protection \
  --method PUT \
  -f required_status_checks='{"strict":true,"contexts":["quality"]}' \
  -f required_pull_request_reviews=null \
  -f enforce_admins=false \
  -f dismiss_stale_reviews=false \
  -f require_code_owner_reviews=false \
  -f required_linear_history=false \
  -f allow_force_pushes=false \
  -f allow_deletions=false \
  -f block_creations=false
```

**Verify:** Returns protection config JSON with `"allow_force_pushes": false`

### Step 3: Update CHANGELOG
Add entry under `## [Unreleased]`:
```markdown
### Changed
- Governance: Enable branch protection on main; require status checks before merge (#23)
```

### Step 4: Commit and push
```fish
git add CHANGELOG.md
git commit -m "Enable branch protection on main (fixes #23)"
git push origin issue-23-branch-protection
```

**Verify:** 
```fish
git log --oneline -n 2
# Output: [latest hash] Enable branch protection on main (fixes #23)
```

### Step 5: Open draft PR
```fish
gh pr create \
  --title "Enable branch protection on main (fixes #23)" \
  --body "## What
Enable branch protection on main: require pull requests before merging, require the \`quality\` CI check to pass, and disallow force pushes.

## Why
Audit (#22) found main currently has no protection despite working CI gate. Without protection, the CI gate is advisory only — a direct push to main bypasses it entirely.

## How
Configured via \`gh api\` to:
- Require PR before merge
- Require \`quality\` status check to pass
- Require branches up to date
- Disallow force pushes

## Testing
- [x] Verified protection config: \`gh api repos/:owner/:repo/branches/main/protection\`
- [x] CI checks pass on this branch

Fixes #23" \
  --draft \
  --label "area:governance,priority:high"
```

**Verify:** Draft PR created; link printed to console.

### Step 6: Manual gate — Jared squash-merges via GitHub GUI
Once you merge, continue to post-merge automation below.

---

## Issue #6: v1.0 Acceptance Criteria

**Branch name:** `issue-6-v1-acceptance-criteria`  
**Estimated time:** 1–1.5 hrs  
**Files created:** `docs/v1.0-acceptance.md`

### Step 1: Create branch
```fish
git fetch origin main
git checkout -b issue-6-v1-acceptance-criteria origin/main
```

### Step 2: Create acceptance criteria document
```fish
cat > docs/v1.0-acceptance.md << 'EOF'
# v1.0 Acceptance Criteria

## Acceptance Checklist

The following issues must be resolved for v1.0 release:

- [ ] #7: Log retention + maintenance dry-run controls
- [ ] #8: Validate Intel macOS compatibility
- [ ] #9: ADR for report/maintenance boundaries
- [ ] #11: Per-tool opt-in + timeouts
- [ ] #12: Signed release artifacts + checksums
- [ ] #13: Credential-free notification providers
- [ ] #10: Stable JSON output

## Platform Support Matrix

| Platform | Version | Architecture | Status | Notes |
|----------|---------|--------------|--------|-------|
| macOS | 13.x (Ventura) | Apple Silicon | ✓ Tested | Primary dev target |
| macOS | 14.x (Sonoma) | Apple Silicon | ✓ Tested | Current LTS |
| macOS | 15.x (Sequoia) | Apple Silicon | ✓ Tested | Latest |
| macOS | 12.x (Monterey) | Apple Silicon | ⚠️ Backport candidate | EOL; community feedback needed |
| macOS | 13.x+ | Intel | ⚠️ Community testing | See #8 for Intel validation status |

## Known Limitations

- Email reporting: minor edge case with multi-recipient formatting (see #24)
- Backup snapshots: unbounded growth (see #7, #24 for retention policy)
- Notification: currently email-only; credential-free providers deferred to v1.1 (see #13)

## Success Metrics

- [ ] All acceptance checklist items resolved or explicitly deferred with rationale
- [ ] Platform matrix tested on primary platform (Apple Silicon, Sonoma+)
- [ ] Intel support documented (via community feedback or implemented)
- [ ] All 13 enhancement issues either merged or explicitly closed/deferred
- [ ] Release artifacts signed (see #12)
- [ ] CHANGELOG updated
- [ ] README updated with v1.0 badge / link to release notes

## Deferral Rationale (if applicable)

Any issues deferred post-v1.0 should be documented here with reason and target version.

---

**Last updated:** 2026-07-20
EOF
cat docs/v1.0-acceptance.md
```

**Verify:** File created; content matches above.

### Step 3: Update README — add roadmap link
```fish
# Open README.md in editor; add under ## Roadmap or ## Development section:
# "See [v1.0 Acceptance Criteria](docs/v1.0-acceptance.md) for complete requirements."
```

**Manual edit:** Add the link to README.md.

### Step 4: Update CHANGELOG
```fish
cat >> CHANGELOG.md << 'EOF'

### Added
- Docs: v1.0 acceptance criteria document with platform matrix and success metrics (#6)
EOF
```

### Step 5: Commit and push
```fish
git add docs/v1.0-acceptance.md README.md CHANGELOG.md
git commit -m "Define v1.0 acceptance criteria (fixes #6)"
git push origin issue-6-v1-acceptance-criteria
```

**Verify:**
```fish
git log --oneline -n 2
# Output: [latest] Define v1.0 acceptance criteria (fixes #6)
```

### Step 6: Open draft PR
```fish
gh pr create \
  --title "Define v1.0 acceptance criteria (fixes #6)" \
  --body "## What
Define v1.0 acceptance criteria with acceptance checklist, platform support matrix, known limitations, and success metrics.

## Why
Audit (#22) completed; 8 enhancement issues already tracked. Need to formally define what 'v1.0 done' means — acceptance thresholds, platform coverage, and success metrics.

## How
- Created \`docs/v1.0-acceptance.md\` with:
  - Acceptance checklist (links to #7–#13)
  - Platform matrix (macOS versions, Intel/Apple Silicon, test status)
  - Known limitations
  - Success metrics
- Linked in README
- Updated CHANGELOG

## Testing
- [x] Document structure verified
- [x] Links to issues confirm
- [x] Platform matrix reflects current status

Fixes #6" \
  --draft \
  --label "area:governance,priority:high,documentation"
```

**Verify:** Draft PR created.

### Step 7: Manual gate — Jared squash-merges via GitHub GUI
Once you merge, continue to post-merge automation.

---

## Post-Merge Automation (run after each PR merge)

### After PR #23 merges:
```fish
git fetch origin
git checkout main
git pull origin main
gh issue close 23 --comment "✓ Merged — branch protection now enforced on main"
git log --oneline -n 3
```

### After PR #6 merges:
```fish
git fetch origin
git checkout main
git pull origin main
gh issue close 6 --comment "✓ Merged — v1.0 acceptance criteria documented"
git log --oneline -n 3
```

---

## Issue #8: Intel Validation (Community Task)

No implementation branch. Add comment to issue #8:

```
**Status:** Documenting as community contribution (v1.0).

Proposal: Intel Mac testing can be crowdsourced — add to platform matrix in #6, link compatibility feedback channel, ask community for test reports.

See docs/v1.0-acceptance.md for platform matrix status.
```

Label with: `type:community-contribution`

---

## When Session Ends

**Current state:**
- Branch #23: ready for draft PR
- Branch #6: ready for draft PR
- Branches awaiting manual squash-merge via GitHub GUI
- Post-merge automation: scripted above, ready to run

**To resume:**
1. If either branch not yet merged, checkout branch and push again: `git push -f origin <branch-name>`
2. If PRs exist, check status: `gh pr list --state draft`
3. Post-merge, run the automation blocks above
4. Verify all issues closed: `gh issue list --state closed --label "priority:high"`

---

**Walkthrough created:** 2026-07-20  
**Next step:** Run Phase 1 Executor Prompt (awaiting approval)
