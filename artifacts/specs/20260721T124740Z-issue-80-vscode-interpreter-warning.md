# Spec: Stop the Python interpreter warning in this repo (Issue #80)

**Closes:** #80 · **Milestone:** none (deliberate — tooling hygiene, not remediation work)
**Labels:** `type:bug`, `area:governance`, `priority:low`, `effort:small`, `status:ready`
**Assignee:** Jared-Godar · **Project:** macOS System Health Roadmap
**Sizing:** `--model sonnet --effort medium` — Light/Standard. Two small files plus a decision that
is already recommended; the judgment is narrow.

---

## 0. Read the durable contracts first (non-negotiable)

Before writing anything, read and follow, in order:

1. **`AGENTS.md` on `main`** — the binding contract, 22 standing commitments as of `5b5830b`.
2. `CLAUDE.md` at the repo root — 11 mirrored non-negotiables.
3. `~/.claude/CLAUDE.md` — the maintainer's cross-project standing rules.
4. `CONTRIBUTING.md`.
5. **Issue #80 in full** — it carries the diagnosis, the three routes, and the PM recommendation.

**The rules that will bite you on this specific task:**

- **Receipts expire on the next mutation.** Commit first, gate second, report third.
- **Four gated actions need per-instance go-ahead: push, open PR, merge, release-tag.** Stop and ask
  before `git push` and before `gh pr create`. Never merge.
- **No contract-lawyering.** A criterion that cannot be met is a **finding to report, never a
  criterion to drop**. In particular, criterion 4 below may not be verifiable from a CLI session —
  say so plainly rather than claiming it.
- **Disclose every omission**, not the comfortable ones.
- **Specs are immutable after handoff.** This file is read-only to you.
- **Always pass `-R Jared-Godar/macos-system-health`** on every `gh` write.

## 0b. Progress tracking

Maintain a live task list — one item per §4 step plus each acceptance criterion — moving each to
in-progress/done as you go. Use **TodoWrite** if available. If TodoWrite is unavailable, say so once,
then **re-post the full checklist as inline markdown at the top of every response that starts or
finishes a step**, marking `[x]` done / `[~]` in-progress / `[ ]` todo. Do not let more than one tool
batch pass without a refreshed checklist.

---

## 1. Intended outcome

Opening this repository in VS Code no longer raises a Python interpreter warning, and the fix travels
with the repository rather than living on one machine.

## 2. Current state and gap

A **User-scope** VS Code setting points at an interpreter that does not exist here:

```
python.defaultInterpreterPath = ${workspaceFolder}/.venv/bin/python
```

There is no `.venv` in this repo — it is a Bash project. The setting resolves correctly in
`ecg_anomaly_detection` (which has one) and to nothing here. An extension update forced a reload and
surfaced it, but it has been wrong all along. `${workspaceFolder}` is also unreliable in User scope:
VS Code cannot resolve it consistently, and it is ambiguous in multi-root workspaces.

This repo uses `python3` only as a **stubbed** binary in `tests/smoke.sh` and as a **checked** tool in
`bin/system-health` (reporting `python3 --version`). No Python source, no `requirements.txt`, no
`pyproject.toml`, no virtualenv. Nothing in development needs an interpreter selected.

**The complication:** `.vscode/` is gitignored, so a tracked settings file is not a drop-in.

```
$ git check-ignore -v .vscode/settings.json
.gitignore:10:.vscode/	.vscode/settings.json
```

## 3. Decision — route A, already chosen

The maintainer selected **route A**: negate the ignore for `settings.json` only, keeping `.vscode/`
ignored for personal editor state. Rationale: the defect is a property of the repository (a Bash
project with no interpreter), not of one machine, so the fix belongs in the repository — otherwise
every fresh clone and every cloud/cold-start session hits the same warning.

Routes B (keep it local and untracked) and C (do nothing) are recorded in #80 as rejected. Do not
revisit the choice; if you believe it is wrong, **report that as a finding** and stop.

## 4. Scope and deliverables

Scope expanded at the maintainer's request: ship the settings that are genuinely optimal for **this**
project, not only the interpreter fix. Each is evidence-backed below — **justify every key you
include in the PR body, and add nothing that is not on this list without saying why.**

1. **`.gitignore`** — add `!.vscode/settings.json` immediately after the `.vscode/` rule, with a
   one-line comment explaining why the exception exists. Order matters: a negation must follow the
   rule it negates.

2. **`.vscode/settings.json`**, containing:

   **(a) The interpreter fix.** Stop the Python extension hunting for a `.venv` that does not exist.
   Choose the keys — candidates are overriding `python.defaultInterpreterPath` to a real system
   interpreter and/or `python.terminal.activateEnvironment: false`.

   **(b) `files.associations` for the seven extensionless Bash files.** Verified — every one carries
   `#!/usr/bin/env bash` but has no extension, so language detection is not guaranteed and ShellCheck
   integration and syntax highlighting may not engage:

   ```
   bin/system-health   bin/install-schedule   bin/configure-email
   scripts/check       scripts/install-hooks
   .githooks/pre-commit   .githooks/pre-push
   ```

   These are exactly the files in `scripts/check`'s `SHELL_FILES` array. Map them to `shellscript`.
   Prefer glob patterns over listing every file where a glob is unambiguous, so new hooks and scripts
   are covered automatically.

   **(c) Protect intentional trailing whitespace in Markdown — the non-obvious one.** `.gitattributes`
   carries `artifacts/** -whitespace` precisely because markdown **hard line breaks** (trailing double
   spaces) are intentional there; three tracked files depend on them:

   ```
   artifacts/session-handoffs/2026-07-20-phase1-governance-cleanup.md
   artifacts/session-handoffs/2026-07-21T0256Z-governance-close-stale-issues.md
   artifacts/walkthroughs/2026-07-20-phase1-continuity.md
   ```

   If the editor trims trailing whitespace on save, opening any of those silently destroys their
   rendering — the exact thing PR #75 added `.gitattributes` to preserve. Disable trimming for
   Markdown (`"[markdown]": { "files.trimTrailingWhitespace": false }`). This is safe for non-artifact
   Markdown too: accidental trailing whitespace outside `artifacts/` is still caught by
   `git diff --check` / `git show --check` in `scripts/check` and by the pre-push guard.

   **(d) `files.eol: "\n"`.** The repo is Unix-only (macOS host, Bash tooling); a CRLF file would trip
   the gate. Cheap insurance.

   **Explicitly out of scope** unless you can justify it from repo evidence: formatters, linters,
   themes, `editor.rulers`, markdownlint configuration, and any language settings beyond
   Shell/Markdown/Python-suppression. There is no `.editorconfig`, no markdownlint config, and no
   formatter in the toolchain — do not invent one here.

3. **`CONTRIBUTING.md`** — a short note that the repo ships a small, deliberate VS Code settings file,
   what each setting is for, and specifically that the Markdown trailing-whitespace setting pairs with
   `.gitattributes`. A future reader must not "clean up" either half in isolation.

4. **CHANGELOG** entry under `[Unreleased]`.

## 5. Execution rails

Fish syntax, from the repo root. Each step followed by its verification.

### Step 1 — Sync and branch, before any edit

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git status --short; and git log --oneline -1
git switch -c fix/issue-80-vscode-interpreter
git branch --show-current
```

Expected: clean tree, `main` at `5b5830b` or later.

### Step 2 — Implement

### Step 3 — Verify the ignore negation works in BOTH directions

This is the criterion most likely to be silently half-done:

```fish
git check-ignore -v .vscode/settings.json; or echo "settings.json NOT ignored - correct"
touch .vscode/_scratch-probe.json
git check-ignore -v .vscode/_scratch-probe.json
rm .vscode/_scratch-probe.json
```

Expected: `settings.json` **not** ignored, and the probe file **still ignored**. Paste both. If the
probe file is also un-ignored, the negation is too broad — fix it.

### Step 4 — Gate, on the committed state

```fish
git add -A
git status --short
git commit -m "Ship a deliberate VS Code interpreter setting (#80)"
scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"
tail -1 /tmp/g.log
```

Expected both `exit=0`. **Commit first, gate second, report third.**

### Step 5 — STOP: push is gated

Report and wait for explicit go-ahead. Then push and verify the remote ref.

### Step 6 — STOP: opening the PR is gated

Wait for go-ahead, then use §6.

## 6. PR metadata (all at creation time)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Ship a deliberate VS Code interpreter setting (#80)" \
  --assignee Jared-Godar \
  --label type:bug --label area:governance --label priority:low \
  --label effort:small --label status:ready \
  --body "Closes #80

<which settings keys you chose and why each is necessary; the Step 3 both-directions receipt;
whether the warning was actually verified gone or could not be checked from a CLI session;
scripts/check output from the committed state>"
```

**No `--milestone`** — #80 is deliberately unmilestoned as tooling hygiene rather than remediation
work. All five labels are confirmed present in `.github/labels.json` (PM-verified 2026-07-21).

Verify:

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], closes:(.body|test("Closes #80"))}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

Expected: five labels, **milestone null**, assignee `Jared-Godar`, `projects` containing
`macOS System Health Roadmap`, `closes` true, all checks green.

## 7. Checkpoints (all four)

1. **Branch ready** — branch name, clean tree, `main` synced.
2. **PR created (CRITICAL)** — PR number/URL, full metadata read-back, the Step 3 receipt, your
   settings-key justification.
3. **CI green** — `gh pr checks` output.
4. **After merge** — PR `MERGED`, #80 `CLOSED`, `main` fast-forwarded, branch deleted, `status:*`
   stripped from #80, board Status `Done`.

Between 2 and 4 the PR is under merge **HOLD**. You do not merge and do not declare merge-readiness;
the PM re-runs a sample of your receipts and announces **GREEN LIGHT**.

## 8. Non-goals

- Not adding formatting, linting, or theme settings. One deliberate setting, not a config suite.
- Not un-ignoring `.vscode/` wholesale.
- **Not touching the maintainer's User-scope VS Code settings or `~/.claude`.** Whether to remove or
  relocate the broken `${workspaceFolder}` entry is his call and outside this repo.
- Not modifying `bin/system-health`'s `python3` health check or the `tests/smoke.sh` stub.

## 9. Dependencies

Independent of the governance queue. **Not blocked by #74** — that gate covers *user-facing code*, and
this changes only developer tooling config (`.gitignore`, `.vscode/`, a CONTRIBUTING note). It does
not touch `bin/`, `lib/`, or `tests/` behavior. If the maintainer reads #74 as covering this too, it
waits; the PM has flagged that reading rather than assuming.

## 10. References

- **#80** — diagnosis, the three routes, and why A was chosen
- `.gitignore:10`; `tests/smoke.sh` (python3 stub); `bin/system-health` (python3 health check)
- `AGENTS.md` on `main` at `5b5830b`
