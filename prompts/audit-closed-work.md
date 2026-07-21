# Backward-facing audit of closed v1.0 work

**Type:** Retrospective quality audit (governance)
**Executor task:** Reconstruct the definition-of-done each closed issue *should* have had, verify
the delivered work against it with receipts, and file forward-facing issues for any real gap.

---

## Integrity constraint (read first, non-negotiable)

**Never edit a closed issue's body.** Rewriting closed history to look well-specified is
fabrication. The delivered work is judged against a *reconstructed* definition-of-done recorded
in a **new, dated audit document** — the closed issues and their PRs are read-only evidence.
Real gaps become **new** issues that link back to the original closed issue and PR. The past is
recorded, never retouched.

## Intended outcome

A committed, dated retrospective (`docs/audits/2026-07-21-closed-work-audit.md`) that, for each
in-scope closed issue, states: the reconstructed definition-of-done, the delivered artifacts,
a receipt-backed verdict (**Satisfied / Partial / Unverifiable**), and — for every Partial —
a linked follow-up issue capturing the remaining work. The board ends the audit with honest
gap tracking instead of hidden debt behind "closed."

## Current state and gap

Multiple v1.0 issues were closed while their issue bodies were one-line stubs (drafted quickly,
low-effort). "Done" was accepted without a spec-grade definition-of-done, so it is unknown
whether the delivered work actually covered what a proper spec would have required. One instance
is already confirmed: the permissions work (#29/#30) shipped a `.claude/settings.json` that does
not conform to the canonical pattern (tracked by the rewritten #31).

## Scope (risk-ranked — do not deep-audit all 19 closed issues)

**Tier 1 — behavioral / safety-affecting (deep audit, receipts required):**
`#7` log retention + maintenance dry-run · `#24` Brewfile/Conda backup retention ·
`#11` per-tool opt-in + timeouts · `#10` JSON output · `#20` scheduled full-history secret
scan · `#29` permissions allowlist.

**Tier 2 — contracts that gate behavior (light, concrete verification):**
`#6` v1.0 acceptance criteria · `#9` report/maintenance ADR · `#18` CONTRIBUTING + redaction
guarantee · `#23` branch protection.

**Tier 3 — process/docs (existence spot-check only, one line each):**
`#22, #34, #35, #36, #37, #40, #42, #44, #45`.

## Method / rubric (per in-scope issue)

1. Pull the as-closed issue body, the closing PR, its diff, tests, and CHANGELOG/README deltas.
2. Reconstruct the definition-of-done a proper 8-section spec would have demanded (see the
   issue/spec body standard).
3. Verify each reconstructed criterion against delivered artifacts **with a command + output**
   pasted as the receipt. No "looks done."
4. Assign a verdict: **Satisfied / Partial (itemized gaps) / Unverifiable**.
5. For every Partial, open a **new** issue to the 8-section standard, correctly labeled per the
   type-aware policy, linked to the original closed issue and PR. Do not duplicate a gap already
   tracked (e.g. permissions is tracked by #31 — reference it, don't refile).

## Specific scrutiny targets (derived during PM scoping — CONFIRM or REFUTE with receipts; these are hypotheses, not findings)

- **#7 — hypothesis to test:** `SYSTEM_HEALTH_DRY_RUN` / `--dry-run` may gate only the log/backup
  *cleanup* deletions, while `maintenance --dry-run` still executes `brew update/upgrade/cleanup`
  and `conda clean`. The ISSUES.md Phase 2 spec required `maintenance --dry-run` to print planned
  mutations and **never execute** those commands, with negative tests proving it. Confirm whether
  that behavior and its negative test exist; if the dry-run only covers cleanup, that is a real
  gap → file it.
- **#11 — two hypotheses to test:** (a) timeout *enforcement* may be implemented but lack a
  regression test that forces a real timeout (slow stub) and asserts the `timed_out` state; the
  JSON field's mere presence is not proof of enforcement. (b) Confirm the timeout mechanism is
  macOS-portable — base macOS ships no `timeout` binary; verify the code path used at runtime is
  the portable one and not a dependency on an absent binary. Each unconfirmed item → a gap issue.
- **#10:** confirm tests cover JSON validity, `schema_version`, required fields, timestamp
  format, AND redaction (no private paths in JSON output), not just field presence.
- **#24:** confirm backups are pruned by age/count while the current and unrelated files are
  preserved, with report-mode deleting nothing.
- **#20:** confirm the scan is genuinely scheduled (cron) over full history (`fetch-depth: 0`)
  and actually invokes gitleaks.
- **#29:** confirm/annotate the already-known conformance gap; reference #31, do not refile.
- **Tier 2:** #6 acceptance doc actually enumerates the criteria; #9 ADR enumerates the permitted
  mutations; #18 names the redaction guarantee and points to its tests; #23 branch protection
  matches the documented solo-maintainer intent.

## Deliverables

1. `docs/audits/2026-07-21-closed-work-audit.md` — table: closed issue → reconstructed DoD →
   delivered (receipt) → verdict → follow-up #. Author it via a topic branch + PR (do not commit
   to `main` directly).
2. New forward-facing issues (8-section standard, labeled per the type-aware policy, in the
   project, milestoned) for each confirmed Partial, linked to the original closed issue + PR.
3. A short summary comment on this audit's tracking issue listing every verdict and every
   follow-up filed.

## Acceptance criteria

- [ ] No closed issue body edited (integrity constraint honored)
- [ ] Every Tier-1 and Tier-2 issue has a receipt-backed verdict in the audit doc
- [ ] Tier-3 issues each have a one-line existence spot-check
- [ ] Each hypothesis above is explicitly confirmed or refuted with a command + output
- [ ] Every Partial has a linked, standard-format, correctly-labeled follow-up issue
- [ ] No duplicate of an already-tracked gap (e.g. #31)
- [ ] Audit doc landed via PR (branch → PR → gates), not direct to `main`
- [ ] `scripts/check --all` green for the doc PR

## References

- `docs/planning/ISSUES.md` — the phase specs that define each issue's intended DoD
- Issue/spec body standard (project memory) — the 8-section structure for gap issues
- Type-aware label policy (#54) — labels for the new gap issues
- `SECURITY.md` — redaction guarantee under audit for #10/#18
