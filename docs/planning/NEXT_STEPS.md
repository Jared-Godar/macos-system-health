# Immediate Next Steps

>20260630

- [x] 1. **Review and merge [Dependabot PR #1](https://github.com/Jared-Godar/macos-system-health/pull/1).** It upgrades actions/checkout from v6 to v7, and all checks pass.
- [x] 2. **Add a branch ruleset for `main` requiring the `quality / checks` status check.**
  - [x] Open the repository ruleset settings:

  ```fish
  open https://github.com/Jared-Godar/macos-system-health/settings/rules
  ```

  - [x] Choose New ruleset → New branch ruleset and configure:
    - [x] Name: `Protect main`
    - [x] Enforcement: Active
    - [x] Target branch: Default branch
    - [x] Restrict deletions: enabled
    - [x] Block force pushes: enabled
    - [x] Require a pull request before merging: enabled
      - [x] Required approvals: 0 for this solo project
      - [x] Require conversation resolution: enabled
    - [x] Require status checks: enabled
      - [x] Add required check: checks
      - [x] Require branches to be up to date: enabled
    - [x] Require linear history: enabled
    - [x] Signed commits: leave disabled for now
  - [x] Do not require CodeQL because it may legitimately skip when a change contains no analyzable workflow content.
  - [x] Verify the active ruleset through the GitHub API.
  - Direct pushes to `main` are now blocked; future work uses a branch and pull request.

- [x] 3. **Update documentation state:**
  - [x] Mark the follow-up commit and CI run complete in `docs/planning/PUBLICATION_CHECKLIST.md`.
  - [x] Mark post-publication cleanup complete in `docs/planning/FIRST_GITHUB_PUSH.md`.
  - [x] Remove “Add automated smoke tests” from `docs/planning/ROADMAP.md`.

- [ ] 4. **Complete and document one live integration cycle:**
  - [x] Report mode
  - [ ] Maintenance mode
  - [ ] LaunchAgent installation
  - [ ] Immediate scheduled trigger
  - [x] Email delivery
  - [ ] LaunchAgent removal/reinstallation

- [ ] 5. **Publish v0.1.0 once that integration cycle is confirmed.**

---

## Live Test Results

- [x] Run report mode successfully with zero issues and one expected outdated-package warning.
- [x] Confirm local report permissions are owner-only.
- [x] Confirm report email delivery.
- [x] Identify a privacy gap where `conda doctor` printed an absolute Conda installation path.
- [x] Create the privacy-fix branch:

  ```fish
  git switch -c fix/redact-report-paths
  ```

- [x] Centralize home-directory and Conda-base path redaction for logged and emailed command output.
- [x] Add regression coverage reproducing both path leaks.
- [x] Confirm the retest log contains `[conda base]` and no personal path indicators.
- [x] Confirm the emailed retest report contains `[conda base]` rather than the absolute path.
- [ ] Merge the privacy fix before proceeding to maintenance mode.
