# Security and privacy audit

Date: 2026-06-30

## Scope

The review covered the original working tree, tracked Git history, shell behavior, generated logs/backups, scheduler configuration, and the files staged conceptually for this standalone public repository. Checks included manual review, ShellCheck, credential-pattern searches, personal path/email searches, and Git-history searches.

## Findings

### Critical — credential in a local notes file

The parent working tree contained what appeared to be a Google app password in an untracked maintenance-notes file. The project copy was redacted, all existing Google app passwords were revoked, and a replacement was stored in a private 1Password vault. The file was not found in the examined Git history.

### High — parent repository is unsuitable for publication as this project

- [x] The parent repository contains unrelated notebooks, notes, images, archived scripts, personal paths, and an existing history. Some files have credential-related indicators that require separate review. Publish only this standalone directory through a new repository with fresh history.
  - [x] *Created new folder with only the scripts and documentation to go to github*

### Medium — original reports collected personal machine data

- [x] The original script logged hardware serial information, `PATH`, user/shell context, working directory, and Conda paths. The public version omits these fields. Package and environment names can still reveal workstation details, so reports must be redacted before sharing.

### Medium — configuration and scheduling were workstation-specific

-[x] The original files embedded an email address, username, and absolute paths. The public version uses environment variables, command discovery, paths under the current user's Library, and a relocatable LaunchAgent installer.

### Medium — report mode performed a network mutation

- [x] The original report mode ran `brew update`. The public report exports `HOMEBREW_NO_AUTO_UPDATE=1`; update, upgrade, and cleanup occur only in explicit maintenance mode.

### Low — generated data permissions and locking

- [x] The public version sets `umask 077` before creating logs/backups and uses an atomic per-user lock directory. A stale lock can require manual removal; the runbook documents recovery.

## Residual risks

- Package-manager output and environment names can disclose installed software and project names.
- Homebrew upgrade is a broad mutation and may break dependent tools.
- Email security depends on the user's `msmtp` configuration and mail provider.
- Pattern-based secret scanning cannot prove that no secret exists.

## Release decision

The exposed app password has been revoked. Complete the remaining [publication checklist](PUBLICATION_CHECKLIST.md) before publishing this standalone repository with its fresh history.
