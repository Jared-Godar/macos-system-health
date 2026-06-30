# Security policy

## Supported versions

Security fixes are applied to the latest release on the default branch.

## Reporting a vulnerability

Do not open a public issue containing credentials, logs, usernames, hostnames, environment names, or workstation paths. Use GitHub private vulnerability reporting after it is enabled in the repository settings.

Revoke any exposed credential before reporting it. Include a minimal reproduction and describe impact without attaching an unredacted report.

## Data handling

Reports remain local unless `SYSTEM_HEALTH_EMAIL` is configured. Reports may list software and Conda environment names. New files are created with user-only permissions, but users remain responsible for their email transport, backup destination, and issue attachments.
