# First public GitHub push

Date: 2026-06-30

This checklist documents the process used to review and publish the repository with fresh Git history. Commands use Fish shell syntax.

## 1. Authenticate GitHub CLI

- [x] Reauthenticate the intended GitHub account:

  ```fish
  gh auth logout -h github.com -u Jared-Godar
  gh auth login -h github.com -p https -w
  gh auth status
  ```

The login command opens GitHub in a browser.

## 2. Confirm the public repository URL

- [x] Confirm the README clone command uses:

  ```text
  https://github.com/Jared-Godar/macos-system-health.git
  ```

- [x] Run the complete local verification suite:

  ```fish
  scripts/check --all
  ```

## 3. Stage and review the public files

- [x] Stage files and inspect their status:

  ```fish
  git add .
  git status --short
  ```

The staged list must not contain:

- `.DS_Store`
- `private-notes/`
- `system-health-public.code-workspace`
- Logs, reports, backups, credentials, or environment files

- [x] Review exactly what will enter history:

  ```fish
  git diff --cached --check
  git diff --cached --stat
  git diff --cached
  git ls-files
  ```

## 4. Create the first commit

- [x] Commit the reviewed snapshot:

  ```fish
  git commit -m "Initial public release"
  ```

The pre-commit hook automatically runs syntax validation, linting, smoke tests, and secret scanning. Do not bypass it with `--no-verify`.

- [x] Confirm the commit and working-tree state:

  ```fish
  git log --oneline --decorate -1
  git status --short
  ```

## 5. Create and push the public repository

- [x] Create the repository and push `main`:

  ```fish
  gh repo create Jared-Godar/macos-system-health \
      --public \
      --source=. \
      --remote=origin \
      --description "Privacy-conscious macOS health reporting and maintenance automation in Bash" \
      --push
  ```

- [x] Confirm the remote:

  ```fish
  git remote -v
  git status --short
  ```

## 6. Verify the first CI run

- [x] List and watch the first workflow run:

  ```fish
  gh run list --limit 5
  gh run watch
  ```

If `gh run watch` needs a run identifier:

```fish
gh run watch (gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
```

## 7. Finish the GitHub presentation

- [x] Open the repository:

  ```fish
  gh repo view --web
  ```

- [x] Add the topics `macos`, `bash`, `homebrew`, `conda`, `system-health`, and `automation`.

  ```fish
  gh repo edit Jared-Godar/macos-system-health \
      --add-topic macos \
      --add-topic bash \
      --add-topic homebrew \
      --add-topic conda \
      --add-topic system-health \
      --add-topic automation
  ```

- [x] Verify the topics:

  ```fish
  gh repo view Jared-Godar/macos-system-health \
    --json repositoryTopics \
    --jq '.repositoryTopics[].name'
  ```

- [x] Open the repository security settings:

  ```fish
  open https://github.com/Jared-Godar/macos-system-health/settings/security_analysis
  ```

- [x] Enable or confirm the security controls:

  - [x] Secret scanning
  - [x] Push protection
  - [x] Dependabot alerts
  - [x] Dependabot security updates
  - [x] Private vulnerability reporting
  - [x] CodeQL default setup for GitHub Actions

- [x] Confirm GitHub recognizes the MIT license.
- [x] Enable release immutability.
- [x] Streamline repository collaboration and merge settings.
- [ ] Add a privacy-reviewed social preview image.
- [x] Wait for the first CI run to pass before creating the `v0.1.0` release.

## 8. Post-publication cleanup

- [x] Commit and push the reviewed CI and Dependabot improvements.
- [x] Confirm the follow-up quality workflow passes without the original runner annotations.
- [x] Review and merge the first Dependabot pull request.
- [x] Protect `main` with an active branch ruleset requiring pull requests and the `checks` status.
- [ ] Create `v0.1.0` only after the release-readiness checklist is complete.
