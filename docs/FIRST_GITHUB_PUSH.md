# First public GitHub push

Date: 2026-06-30

This checklist documents the process used to review and publish the repository with fresh Git history. Commands use Fish shell syntax.

## 1. Authenticate GitHub CLI

- [ ] Reauthenticate the intended GitHub account:

  ```fish
  gh auth logout -h github.com -u Jared-Godar
  gh auth login -h github.com -p https -w
  gh auth status
  ```

The login command opens GitHub in a browser.

## 2. Confirm the public repository URL

- [ ] Confirm the README clone command uses:

  ```text
  https://github.com/Jared-Godar/macos-system-health.git
  ```

- [ ] Run the complete local verification suite:

  ```fish
  scripts/check --all
  ```

## 3. Stage and review the public files

- [ ] Stage files and inspect their status:

  ```fish
  git add .
  git status --short
  ```

The staged list must not contain:

- `.DS_Store`
- `private-notes/`
- `system-health-public.code-workspace`
- Logs, reports, backups, credentials, or environment files

- [ ] Review exactly what will enter history:

  ```fish
  git diff --cached --check
  git diff --cached --stat
  git diff --cached
  git ls-files
  ```

## 4. Create the first commit

- [ ] Commit the reviewed snapshot:

  ```fish
  git commit -m "Initial public release"
  ```

The pre-commit hook automatically runs syntax validation, linting, smoke tests, and secret scanning. Do not bypass it with `--no-verify`.

- [ ] Confirm the commit and working-tree state:

  ```fish
  git log --oneline --decorate -1
  git status --short
  ```

## 5. Create and push the public repository

- [ ] Create the repository and push `main`:

  ```fish
  gh repo create Jared-Godar/macos-system-health \
      --public \
      --source=. \
      --remote=origin \
      --description "Privacy-conscious macOS health reporting and maintenance automation in Bash" \
      --push
  ```

- [ ] Confirm the remote:

  ```fish
  git remote -v
  ```

## 6. Verify the first CI run

- [ ] List and watch the first workflow run:

  ```fish
  gh run list --limit 5
  gh run watch
  ```

If `gh run watch` needs a run identifier:

```fish
gh run watch (gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
```

## 7. Finish the GitHub presentation

- [ ] Open the repository:

  ```fish
  gh repo view --web
  ```

- [ ] Add the topics `macos`, `bash`, `homebrew`, `conda`, `system-health`, and `automation`.
- [ ] Enable secret scanning and push protection.
- [ ] Enable private vulnerability reporting.
- [ ] Enable Dependabot alerts and security updates.
- [ ] Add a privacy-reviewed social preview image.
- [ ] Confirm GitHub recognizes the MIT license.
- [ ] Wait for the first CI run to pass before creating the `v0.1.0` release.
