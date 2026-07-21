# Spec: Restore the operating contract to full strength (Issues #69 + #70)

**Closes:** #70 and #69 — one PR closes both
**Labels:** `type:docs`, `area:governance`, `priority:high`, `effort:large`, `status:ready`, `risk:high`
**Assignee:** Jared-Godar · **Milestone:** Remediation - Back to Step 0 · **Project:** macOS System Health Roadmap
**Sizing:** `--model opus --effort high` — Heavy. Judgment work on the repo's binding contract.

---

## 0. Read the durable contracts first (non-negotiable)

Before anything else, read and follow, in order:

1. **`AGENTS.md` in the working tree** — note: it is **already modified and uncommitted**. Read the
   working-tree version, not the committed one.
2. `CLAUDE.md` at the repo root.
3. `~/.claude/CLAUDE.md` — the maintainer's cross-project standing rules.
4. `CONTRIBUTING.md`.
5. Issues **#70** (authoritative scope) and **#69** (subsumed), plus **#68** (the incident).

**The rules that will bite you here:**

- **Done means done, with receipts.** Every claim carries its command and output. Label each as
  **done** / **relayed** / **queued** / **owed** / **not done**.
- **Four gated actions need per-instance go-ahead: push, open PR, merge, release-tag.** Stop and ask
  before `git push` and before `gh pr create`. Never merge.
- **No contract-lawyering.** Read every criterion for its high-quality spirit. Ambiguity resolves
  toward **more** rigor. If a criterion cannot be met, that is a **finding to report — never a
  criterion to quietly drop**. Do not add escape hatches.
- **Disclose every omission**, not the comfortable ones.

## 0b. Progress tracking (required)

Create a **TodoWrite** list immediately after reading this spec — one item per §4 step plus each
acceptance criterion in #70. Update it as you go.

---

## 1. Why this exists

`AGENTS.md` was authored in #55/PR #56 as a "layered operating contract," adapted from
`github-portfolio-modernization/AGENTS.md`. It shipped at **9,130 bytes against gpm's 17,476**, with
**6 standing commitments against gpm's 9 and ecg's 11**, and five rules present in *both* reference
repos silently absent. PR #56's disclosure section named only ECG-specific machinery it had skipped
— not the baseline rules it had dropped. Its verification receipt (`41 tests passed`) was the
pre-#64 non-enforcing suite.

The consequence landed on 2026-07-21: a PM thread overwrote a spec a launched executor was actively
working from (#68). Nothing in the contract or the tooling prevented it or made it visible.

## 2. Current state — read this before touching anything

**The port is already drafted in the primary checkout's working tree.** `git status` shows
`M AGENTS.md`: 9,130 → ~18,900 bytes, 6 → 14 standing commitments, +~180 lines.

Your job is to **verify, complete, and land it** — *not* to re-author it. Do not discard the draft.
If you disagree with something in it, say so and propose a change; do not silently rewrite.

**Work in the primary checkout, not a git worktree.** The uncommitted draft lives there; a worktree
would not see it.

## 3. Scope and deliverables

Authoritative checklist: **#70's acceptance criteria**. Summary:

1. **`AGENTS.md`** — verify every rule in #70 §A/§B/§C/§D is present, and §E (the PM-lane
   contradiction) is resolved with one unambiguous statement. No omissions: the omission list is
   closed and itemized in #70's "NOT porting" table.
2. **Spec convention** — `AGENTS.md` states that specs are authored at
   `artifacts/specs/<UTC-timestamp>-issue-<n>-<slug>.md` and tracked; the timestamp is the
   immutability mechanism; **`prompts/` is frozen** as the historical record, and nothing is copied
   into it.
3. **`.gitignore`** — remove `artifacts/` (and its subdirectory lines) so specs, walkthroughs, and
   handoffs are tracked. The maintainer's explicit decision: more transparent and better aligned
   with the repo's goals. `scripts/check --all` runs gitleaks, which gates this. Commit the existing
   `artifacts/` contents, including **this spec**.
4. **Hook to tracked settings** — move the spec-immutability `PreToolUse` hook from the gitignored
   `.claude/settings.local.json` into tracked `.claude/settings.json` (merge with the existing
   `permissions` block; do not replace it). Then delete the local copy so there is one source of
   truth. Three receipts required — see §5.
5. **Root `CLAUDE.md`** — add **specs-are-immutable-after-handoff** as a fourth non-negotiable.
6. **CHANGELOG** — entry under `[Unreleased]`.

## 4. Execution rails

Fish syntax, from the repo root. Each step is followed by its verification.

### Step 1 — Confirm the draft is present, then branch

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git status --short
wc -c AGENTS.md
```

Expected: `M AGENTS.md` and a byte count near **18,900** (not 9,130). If you see 9,130, the draft is
missing — **stop and report**; do not proceed.

```fish
git fetch origin; and git switch -c govern/issues-69-70-contract-restore
git branch --show-current; and git status --short
```

The uncommitted `AGENTS.md` follows you onto the branch. Confirm it is still `M` after switching.

### Step 2 — Verify the draft against #70, rule by rule

Read `AGENTS.md` in full. For **each** rule in #70 §A, §B, §C, §D, confirm it is present and says
what the issue requires. Build the kept/adapted/omitted table as you go — it goes in the PR body.

```fish
grep -c '^- \*\*' AGENTS.md
sed -n '/## Standing commitments/,/## Roles/p' AGENTS.md | grep -c '^- \*\*'
```

Add anything missing. Report anything you judge wrong rather than silently changing it.

### Step 3 — `.gitignore`

Remove the `artifacts/` lines. Verify:

```fish
git check-ignore -v artifacts/specs/20260721T082016Z-issues-69-70-governance-port.md; or echo "NOT IGNORED - correct"
git status --short artifacts/ | head
```

### Step 4 — Hook into tracked settings

Merge the `hooks` block from `.claude/settings.local.json` into `.claude/settings.json`, preserving
the existing `permissions` object. Then remove `.claude/settings.local.json`.

### Step 5 — CLAUDE.md + CHANGELOG

Add the fourth non-negotiable to `CLAUDE.md`; add the `[Unreleased]` entry to `CHANGELOG.md`.

### Step 6 — Gate

```fish
scripts/check --all; echo "exit=$status"
```

Expected exit 0. Paste the tail.

### Step 7 — Commit

```fish
git add -A
git status --short
git commit -m "Restore the operating contract to full strength (#70, #69)"
git log --oneline -1
```

### Step 8 — STOP: push is gated

Report to the maintainer and wait for explicit go-ahead. Then:

```fish
git push -u origin (git branch --show-current)
git ls-remote --heads origin (git branch --show-current)
```

### Step 9 — STOP: opening the PR is gated

Wait for go-ahead, then use the metadata in §6.

## 5. Hook receipts — all three required

```fish
# (a) schema
jq -e '.hooks.PreToolUse[] | select(.matcher == "Write|Edit") | .hooks[] | select(.type=="command") | .command' .claude/settings.json

# (b) pipe-test both directions
set stored (jq -r '.hooks.PreToolUse[0].hooks[0].command' .claude/settings.json)
echo '{"tool_input":{"file_path":"/x/prompts/foo.md"}}' | bash -c "$stored"        # must emit a deny JSON
echo '{"tool_input":{"file_path":"/x/artifacts/specs/foo.md"}}' | bash -c "$stored" # must emit nothing
```

**(c) Live block:** attempt an actual `Write` to a file under `prompts/`, paste the refusal, and
confirm with `ls` that no file was created. An earlier revision of this criterion excused (c); that
escape hatch is **retracted**. If the hook genuinely will not fire in your session, **report that as
a finding** — do not drop the criterion.

## 6. PR metadata (all at creation time)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Restore the operating contract to full strength (#70, #69)" \
  --assignee Jared-Godar \
  --milestone "Remediation - Back to Step 0" \
  --label type:docs --label area:governance --label priority:high \
  --label effort:large --label status:ready --label risk:high \
  --body "Closes #70
Closes #69

<summary; the kept/adapted/omitted-because table with before/after byte and rule counts; all three
hook receipts; scripts/check output; anything you judged wrong in the draft and why>"
```

All six labels are confirmed present in `.github/labels.json` (PM-verified 2026-07-21). There is no
`area:testing` and no `status:in-progress` in this repo's schema.

Verify:

```fish
gh pr view (gh pr view --json number --jq .number) -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], closes69:(.body|test("Closes #69")), closes70:(.body|test("Closes #70"))}'
gh pr checks (gh pr view --json number --jq .number) -R Jared-Godar/macos-system-health --watch
```

**Always pass `-R Jared-Godar/macos-system-health` on every `gh` write.** The Bash tool's working
directory persists between calls; on 2026-07-21 a `cd` into a sibling repo caused a `gh issue edit`
to overwrite a **merged PR in the wrong repository**.

## 7. Checkpoints (all four)

1. **Branch ready** — branch name, draft confirmed present at ~18,900 bytes, clean otherwise.
2. **PR created (CRITICAL)** — PR number/URL, full metadata read-back, all three hook receipts, the
   kept/adapted/omitted table.
3. **CI green** — `gh pr checks` output.
4. **After merge** — PR `MERGED`, #69 and #70 `CLOSED`, `main` fast-forwarded, branch deleted, board
   Status `Done`.

Between 2 and 4 the PR is under merge **HOLD**. You do not merge and do not declare merge-readiness;
the PM re-runs a sample of your receipts and announces **GREEN LIGHT**.

## 8. Non-goals

- Not porting ECG wholesale. The omission list in #70 is closed and reasoned.
- Not changing `bin/system-health`, `lib/`, `tests/`, or CI workflow logic. This is governance only.
- Not re-authoring the `AGENTS.md` draft.

## 9. References

- #70 (authoritative scope), #69 (subsumed), #68 (incident), #67 (template conformance)
- #55 / PR #56 — where the gap was introduced
- `github-portfolio-modernization/AGENTS.md`, `ecg_anomaly_detection/AGENTS.md`
