# Immediate Next Steps

>20260630

- [ ] 1. **Review and merge [Dependabot PR #1](https://github.com/Jared-Godar/macos-system-health/pull/1).** It upgrades actions/checkout from v6 to v7, and all checks pass.
- [ ] 2. **Add a branch ruleset for `main` requiring the `quality / checks` status check.** Branch protection was not confirmed.
- [ ] 3. **Update documentation state:**
  - [ ] Mark the follow-up commit and CI run complete in `docs/planning/PUBLICATION_CHECKLIST.md`.
  - [ ] Mark post-publication cleanup complete in `docs/planning/FIRST_GITHUB_PUSH.md`.
  - [ ] Remove “Add automated smoke tests” from `docs/planning/ROADMAP.md`.
- [ ] 4. **Complete and document one live integration cycle:**
  - [ ] Report mode
  - [ ] Maintenance mode
  - [ ] LaunchAgent installation
  - [ ] Immediate scheduled trigger
  - [ ] Email delivery
  - [ ] LaunchAgent removal/reinstallation
- [ ] **Publish v0.1.0 once that integration cycle is confirmed.**
