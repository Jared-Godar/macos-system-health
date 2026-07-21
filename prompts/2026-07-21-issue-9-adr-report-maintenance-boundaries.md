# Issue #9: Publish an ADR for Report and Maintenance Boundaries

**Tracking issue:** #9
**Branch:** `feature/adr-report-maintenance-boundaries`
**Milestone:** v1.0

---

## What This Does

Publishes an Architecture Decision Record (ADR) that documents the design decisions behind `system-health`'s two-mode architecture:
- **Report mode:** Read-only by default; safe to run repeatedly on any schedule
- **Maintenance mode:** Explicit opt-in; mutates the system in documented, predictable ways

This ADR clarifies the maintenance boundary for users, developers, and future contributors. It explains the "why" behind the design choices and sets the precedent for what belongs in each mode.

---

## Requirements

### What to Document in the ADR

1. **Decision Title:** "Implement read-only report mode and explicit-opt-in maintenance mode"

2. **Context:**
   - Problem: Automated health monitoring tools often perform mutations without clear user consent
   - Constraint: macOS has a diverse environment (Homebrew, Conda, pip, LaunchAgent, etc.)
   - Constraint: Users need visibility into their system state without side effects
   - Constraint: Some maintenance actions (like Homebrew update) are intentionally manual

3. **Decision (What We Chose):**
   - Report mode is the default and performs no mutations except:
     - Creating timestamped logs in `$LOG_DIR` (user-defined, private, intentional)
     - Creating environment backups in `$BACKUP_DIR` (snapshots for reference)
   - Maintenance mode requires explicit selection (`bin/system-health maintenance`)
   - Maintenance mode performs only documented mutations:
     - `brew update`, `brew upgrade`, `brew cleanup` (Homebrew)
     - `conda clean --all` (Conda)
     - Backup snapshot cleanup (old logs and snapshots)
   - Intentionally NOT automatic:
     - `conda update --all` (preserves pinned environments)
     - Mass pip upgrades (preserves project dependencies)
     - System software updates (user decision)

4. **Rationale:**
   - Read-only default is safer; accidental runs cause no damage
   - Explicit opt-in for maintenance requires deliberate user action (high-intent barrier)
   - Timestamped logs and backups enable recovery and audit trails
   - Some upgrades (Conda envs, pip projects) should remain manual to avoid breaking changes
   - LaunchAgent scheduling only runs report mode by default (maintenance requires manual trigger)

5. **Consequences:**
   - ✅ Users can safely schedule reports without fear of mutation
   - ✅ Maintenance is explicit and intentional
   - ✅ Logs and backups provide audit trail and recovery mechanism
   - ⚠️ Conda and pip upgrades require manual action (not automated)
   - ⚠️ Users must read documentation to understand the two modes (not self-evident)

6. **Alternatives Considered:**
   - **Single automatic mode:** Would be simpler but risky; users can't preview changes
   - **Opt-out maintenance (default-on):** Violates principle of least surprise
   - **Three modes (report, preview, apply):** More complex UX; added cognitive burden

---

### ADR Format & Location

**File:** `docs/ADRs/0001-report-and-maintenance-boundaries.md`

**Structure:**
```markdown
# ADR 0001: Report-Only Default with Explicit Maintenance Mode

## Status
Accepted

## Context
[as above]

## Decision
[as above]

## Rationale
[as above]

## Consequences
[as above]

## Alternatives Considered
[as above]

## Related Issues
#7, #24 (retention/cleanup implementation follows this ADR)
#11 (per-tool opt-in honors this boundary)

## References
- README.md (safety model section)
- SECURITY.md (threat model)
- CONTRIBUTING.md (maintenance workflow)
```

**Style:**
- Concise, technical language
- Focus on "why" not "how" (implementation details go in code comments)
- Avoid jargon; target audience is developers + operations engineers
- Link to related code and docs

---

### Create ADR Directory (if Not Exists)

If `docs/ADRs/` doesn't exist:
1. Create directory: `mkdir -p docs/ADRs/`
2. Create `docs/ADRs/README.md` with brief ADR index

---

## Implementation Checklist

- [ ] **Create ADR file:** `docs/ADRs/0001-report-and-maintenance-boundaries.md`
  - [ ] Status: Accepted
  - [ ] All six sections: Context, Decision, Rationale, Consequences, Alternatives, References
  - [ ] Clear explanation of two-mode architecture
  - [ ] Rationale for mutations that ARE included vs. excluded
  - [ ] Consequences section balances benefits and tradeoffs

- [ ] **Create ADR index (if new):** `docs/ADRs/README.md`
  - [ ] Brief intro to what ADRs are (one paragraph)
  - [ ] Numbered list of ADRs with one-line description

- [ ] **Link from docs:** Update `docs/README.md` to link to ADRs section
  - [ ] Add "Architecture Decisions" section with pointer to ADRs

- [ ] **Link from main README:** Add reference in `README.md` Safety Model section
  - [ ] "See ADR 0001 for detailed rationale behind the two-mode architecture"

- [ ] **Update CONTRIBUTING.md (if needed):**
  - [ ] Any clarifications about maintenance boundary for future contributors

- [ ] **Update CHANGELOG.md:**
  - Add under `[Unreleased] ### Added`:
    ```
    - Docs: Architecture Decision Record (ADR 0001) documenting report and maintenance
      boundaries (#9).
    ```

- [ ] **Testing:**
  - [ ] Run `scripts/check --all` (no code changes, should pass immediately)
  - [ ] Verify all markdown files are well-formed (no broken links, valid structure)
  - [ ] Manual review: ADR is readable, technically accurate, and decision is justified

---

## Verification Checklist (for PR)

- [ ] ADR file exists at `docs/ADRs/0001-report-and-maintenance-boundaries.md`
- [ ] All six ADR sections are present and complete
- [ ] ADR explains why report mode is read-only (rationale is clear)
- [ ] ADR explains which mutations maintenance mode includes (explicit list)
- [ ] ADR explains why certain upgrades are intentionally manual (conda, pip)
- [ ] Consequences section balances benefits and tradeoffs
- [ ] Links to related issues (#7, #24, #11, etc.)
- [ ] `docs/ADRs/README.md` exists with ADR index
- [ ] `docs/README.md` updated with link to ADRs
- [ ] `README.md` updated with ADR reference in Safety Model section
- [ ] CHANGELOG.md updated per CONTRIBUTING.md
- [ ] All markdown links are valid (no 404s)
- [ ] `scripts/check --all` passes

---

## Notes

### ADR Purpose in This Project

This ADR serves as:
1. **Design rationale** for contributors (why these decisions exist)
2. **User documentation** (why report vs. maintenance modes exist and how they differ)
3. **Governance record** (decisions that block or inform future features)

### What NOT to Include

- Implementation details (how `bin/system-health` works — that's in code comments)
- Changelog entries (belongs in CHANGELOG.md, not ADR)
- Specific version numbers or dates beyond ADR acceptance
- Personal opinions; focus on technical rationale

### Related Decisions

This ADR informs:
- Issue #11 (per-tool opt-in must respect report/maintenance boundary)
- Issue #7 (retention/cleanup only runs in maintenance mode)
- Future notification work (report output should not mutate; notifications are separate)

---

## Branch & Workflow

1. **Branch:** `feature/adr-report-maintenance-boundaries`
2. **Commits:** 1–2 logical commits (ADR file + docs updates)
3. **Pre-push:** `scripts/check --all` passes
4. **PR template:** Link issue #9, confirm ADR is readable and technically sound
5. **Labels:** `documentation`, `area:governance`
6. **Milestone:** `v1.0`

---

## Links

- Issue #9: https://github.com/Jared-Godar/macos-system-health/issues/9
- Milestone v1.0: https://github.com/Jared-Godar/macos-system-health/milestone/1
- Related issues: #7, #24, #11 (features that follow this ADR)

---

**Executor:** This is a documentation-only task. Read the spec fully, draft the ADR, ensure it's technically sound and well-written, then open the PR. All verification steps must pass before merge readiness.
