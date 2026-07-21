# Spec: Encode the type-aware label policy, then gate PRs on it (Issues #54, #51)

**Closes:** #54, #51 · **Milestone:** Remediation - Back to Step 0
**Labels:** `area:governance`, `priority:high`, `type:feature`, `effort:medium`, `status:ready`, `risk:high`
**Assignee:** Jared-Godar · **Project:** macOS System Health Roadmap
**Sizing:** `--model opus --effort high`

> **Sizing rationale, stated honestly.** By the `AGENTS.md` ladder this reads as **Standard
> (`sonnet high`)** — single-repo script/CI/test work with defined scope — and that would be a
> defensible call. The recommendation is one rung up for one specific reason: **a label gate that
> is wrong in the permissive direction is indistinguishable from a working one.** It reports
> green, every PR passes, and nobody learns it never checked anything. That is the
> "manufactures confidence" failure class from #85, and it is why the negative tests in AC10–AC12
> are load-bearing rather than decorative. Downgrade to `sonnet high` if you'd rather; the spec
> does not depend on the tier.

> **PLACEMENT NOTE — read first.** This spec is already at its canonical path,
> `artifacts/specs/20260721T164206Z-issues-54-51-label-policy-and-gate.md`, untracked on `main`.
> **You do not need to copy or move it. Commit it with your PR.**

---

## 0. Read the durable contracts first (non-negotiable)

Before writing anything, read and follow, in order:

1. **`AGENTS.md` on `main`** — the binding contract. Note § "Model and effort sizing",
   § "Definition of done", § "Canonical work-item flow", and § "Local environment".
2. `CLAUDE.md` at the repo root — the eleven mirrored non-negotiables.
3. `~/.claude/CLAUDE.md` — the maintainer's cross-project standing rules.
4. `CONTRIBUTING.md`.
5. **Issues #54 and #51 in full — including the PM correction comments dated 2026-07-21.**
   The correction on #54 changes a deliverable; do not work from the original body alone.

**The rules that will bite you on this specific task:**

- **Receipts expire on the next mutation.** A `scripts/check` result is a fact about one tree
  state. `git add`, `git commit`, and `git update-index` all void it. Order is **mutate → commit →
  gate → report**, every time.
- **Four gated actions need per-instance go-ahead: push, open PR, merge, release-tag.** Ask, stop,
  wait. **Never merge**, and never declare merge-readiness — the PM announces GREEN LIGHT.
- **No contract-lawyering.** A criterion you cannot meet is a **finding to report, never a
  criterion to quietly drop**. If AC13 turns out to be impossible, say so with evidence.
- **Calibrated claims.** Anything you did not run is unverified — say so in the same sentence as
  the claim. §9 below marks which commands in this spec the PM actually ran.
- **Specs are immutable after handoff.** This file is read-only to you. If it is wrong, report it.
- **Always pass `-R Jared-Godar/macos-system-health`** on every `gh` write. The working directory
  persists across tool calls and an untargeted write has already landed in the wrong repository
  once.

## 0b. Progress tracking

Maintain a live task list — one item per §5 step plus each numbered acceptance criterion — moving
each to in-progress/done as you go. Use **TodoWrite** if available. If TodoWrite is unavailable,
say so once, then **re-post the full checklist as inline markdown at the top of every response
that starts or finishes a step**, marking `[x]` done / `[~]` in-progress / `[ ]` todo. Do not let
more than one tool batch pass without a refreshed checklist.

---

## 1. Intended outcome

"Correctly labeled" stops being a judgment call and becomes a checkable property. A machine-
readable policy defines the type-aware required set; a CI check reads that policy and fails any PR
that does not satisfy it, with a message naming exactly what is missing.

## 2. Current state and gap

### 2a. Nothing enforces the label policy, and the policy is not written down

`.github/labels.json` defines the schema. Nothing reads it:

```
$ ls .github/label-policy.json scripts/check-label-policy
ls: .github/label-policy.json: No such file or directory
ls: scripts/check-label-policy: No such file or directory
```

The required set lives only in `CONTRIBUTING.md` prose (lines 116–135) and in agent memory. PRs
have merged with incomplete metadata; the cross-project rule in `~/.claude/CLAUDE.md` exists
because of one such failure in a sibling repo.

### 2b. Measured baseline — 7 of 23 open issues violate the proposed policy

```
open issues: 23
would FAIL the type-aware policy (feature/bug with no risk:*): 7
  #12 type:feature   Add signed release artifacts and checksums
  #13 type:feature   Add credential-free notification provider interface
  #31 type:feature   Add comprehensive permissions allowlist for executor sessions
  #67 type:feature   Rebuild the executor spec template outside frozen prompts/
  #88 type:bug       Live task-list cadence is required by contract but enforced by nothing
  #89 type:bug       Agent-authored GitHub writes are indistinguishable from the maintainer's
  #92 type:bug       Continuity-walkthrough refresh rule collides with PR-only
```

**You are not fixing these.** The gate is PR-scoped; the issue backfill is #53, which is pure
metadata and PM-executed after this ships. They are quoted here so you know the gate has real
work to do and so you can sanity-check your logic against a known-bad set.

### 2c. #54 as written is unshippable — `risk:low` does not exist

```
$ python3 -c "import json;print(json.load(open('.github/labels.json'))['schema']['risk'])"
{'description': 'Potential impact or severity', 'values': ['high', 'medium']}
```

The matrix requires RISK for `type:feature` and `type:bug`, but only `high` and `medium` exist. A
genuinely low-risk feature must then be mislabeled `risk:medium` — inflating the risk signal until
it means nothing, which is the exact filtering failure #54 exists to fix — or fail the gate.

**Decided by the PM: add `risk:low`.** Every other ordinal category carries three values
(`priority` 3, `effort` 3, `status` 3); `risk` at 2 is the outlier, and its own description
describes a scale. This is a deliverable here, not a follow-up.

Do **not** add `confidence:high` by symmetry. `confidence` (`low`, `unconfirmed`) is correctly
two-valued — `labels.json` guidelines describe those as identifying "exploratory or unvalidated
work", i.e. flags where absence means confident.

### 2d. Label counts in both issue bodies are wrong

```
schema-governed labels : 24        <- area 4, priority 3, type 4, effort 3,
labels[] entries       : 32           status 3, risk 2, confidence 2, housekeeping 3
orphans (no schema category): 8
    'bug' 'enhancement' 'documentation' 'good first issue'
    'question' 'invalid' 'wontfix' 'github_actions'
```

#54 and #52 both say "28 labels." The real figure is **24 schema-governed** (25 after `risk:low`),
plus 8 GitHub stock defaults sitting outside the schema. Three of the orphans — `bug`,
`enhancement`, `documentation` — duplicate `type:bug`/`type:feature`/`type:docs`.

**The orphans are out of scope here.** Deleting a label strips it from every issue carrying it;
that needs usage counts and its own decision. Tracked in **#93**. Your policy file must *recognize*
them (so the drift warning does not fire on every PR) without *requiring* them — see AC4.

### 2e. The gate must lint itself, and that is not automatic

`scripts/check` lints an **explicit array** with no globbing. This bit us in #83: a script under
`scripts/` is *not* covered just by living there.

```bash
EXECUTABLE_FILES=(bin/system-health bin/install-schedule bin/configure-email scripts/check \
  scripts/install-hooks scripts/install-quality-tools tests/smoke.sh .githooks/pre-commit .githooks/pre-push)
```

`scripts/check-label-policy` must be added to `EXECUTABLE_FILES`, and must therefore also be
committed `100755` or `assert_committed_modes` fails the gate before anything else runs.

## 3. Deliverables

1. **`risk:low`** added to `.github/labels.json` (schema `values` **and** the `labels[]` array,
   with a description and a color consistent with `risk:medium`/`risk:high`) **and** created on
   the live repository. Both, or the file and reality disagree — which is #93's whole subject.
2. **`.github/label-policy.json`** — the authoritative required-label matrix. Proposed shape below;
   refine it if you must, but record why in the PR body.
3. **`scripts/check-label-policy`** — a Bash 3.2 script whose **policy evaluation is pure and
   offline-testable**, separated from the GitHub fetch. See §3a; this split is what makes AC10–AC12
   possible and is not optional.
4. **`.github/workflows/label-policy-gate.yml`** — runs the script against the PR's labels on
   `opened`, `edited`, `synchronize`, `labeled`, `unlabeled`, `ready_for_review`.
5. **Negative tests in `tests/smoke.sh`** using the existing `test_*` / `run_test` /
   `assert_contains` harness, with `run_test` lines added at the tail.
6. **`scripts/check` updated** — `scripts/check-label-policy` added to `EXECUTABLE_FILES`.
7. **A one-paragraph `CONTRIBUTING.md` pointer** to `.github/label-policy.json` as the source of
   truth, stating the type-aware rule in a sentence. **Not** the 24-label selection guide — that is
   #52, deferred to #78 by the maintainer on 2026-07-21. Prose that points cannot contradict the
   machine definition; prose that duplicates it can.
8. **CHANGELOG** entry under `[Unreleased]`.

### 3a. Required design: pure logic, injected I/O

The script must evaluate a label set given as input, with no network:

```
scripts/check-label-policy --labels "type:feature,area:governance,priority:high,effort:medium,status:ready,risk:high"
```

…and a thin path that fetches a PR's labels and feeds that same evaluator:

```
scripts/check-label-policy --pr 94
```

Everything in AC10–AC12 exercises the first form. If evaluation and fetching are entangled, the
negative tests need network and a token, and they will be quietly skipped or deleted by the next
person. Do not entangle them.

### 3b. Proposed policy file shape

```json
{
  "version": "1.0",
  "description": "Type-aware required-label matrix. Source of truth for the PR gate (#51).",
  "always_required": ["area", "priority", "type", "effort", "status"],
  "required_for_types": {
    "risk": ["type:feature", "type:bug"]
  },
  "optional": ["confidence", "housekeeping"],
  "recognized_unschemed": [
    "bug", "enhancement", "documentation", "good first issue",
    "question", "invalid", "wontfix", "github_actions"
  ]
}
```

`recognized_unschemed` exists so the drift warning does not fire on GitHub's stock defaults while
#93 decides their fate. Name it whatever you like; the behavior is the requirement.

## 4. Non-goals

- **Not** relabeling the 7 violating open issues — that is #53, PM-executed after this lands.
- **Not** writing the 24-label selection guide — that is #52, deferred to #78.
- **Not** deleting the 8 orphan labels or resolving `help wanted` vs `help-wanted` — that is #93.
- **Not** flipping branch protection yourself. See AC13 and §5 Step 6.
- **Not** enforcing labels at issue-creation time.
- **Not** touching `bin/`, `lib/`, or any product behavior. This repo is under a
  governance-before-product hold.
- **Not** adding a runtime dependency beyond `bash` + `jq`. `jq` is present on `macos-15` runners
  and at `/usr/bin/jq` locally (verified 1.7.1-apple), but guard it with the existing `require`
  idiom anyway.

## 5. Execution rails

Fish syntax, from the repository root. Each step is followed by its verification.

### Step 1 — Sync and branch

```fish
cd /Users/jaredgodar/Code/portfolio/macos-system-health
git fetch origin; and git switch main; and git merge --ff-only origin/main
git status --short; and git log --oneline -1
git switch -c feat/issues-54-51-label-policy-gate
git status --short artifacts/specs/
```

Expected: `main` at `60780f0` or later; the only untracked file under `artifacts/specs/` is this
spec. It follows you onto the branch and is committed in Step 5.

### Step 2 — Add `risk:low` (file and live repo)

The live creation is a metadata write, not a gated action — no approval needed.

```fish
gh label create risk:low -R Jared-Godar/macos-system-health \
  --description "<match the tone of the other risk descriptions>" --color "<see below>"

gh label list -R Jared-Godar/macos-system-health --limit 200 --json name --jq '.[].name' | grep '^risk:'
```

Read the existing `risk:high`/`risk:medium` entries in `labels.json` for the color convention and
description style; do not invent a scheme. Then update `labels.json` — **both** `schema.risk.values`
and the `labels[]` array — and verify:

```fish
python3 -c "
import json; d=json.load(open('.github/labels.json'))
print('schema:', d['schema']['risk']['values'])
print('labels[]:', [l['name'] for l in d['labels'] if l['name'].startswith('risk:')])
"
```

Expected: `['high','medium','low']` and all three present in `labels[]`.

### Step 3 — Policy file, script, workflow, tests, and the `scripts/check` wiring

Implement deliverables 2–7. Design notes that will save you a cycle:

- **Bash 3.2 only.** No `mapfile`, no `declare -A`, no `${var^^}`, no namerefs, no `**` globstar.
  `scripts/install-quality-tools` uses a `case` statement in place of an associative array — follow
  that precedent. CI invokes the gate as `/bin/bash scripts/check --all`, which pins every layer to
  the system 3.2.57.
- **`git update-index --chmod=+x scripts/check-label-policy`** — `assert_committed_modes` reads the
  *index*, so a working-tree `chmod` alone will not satisfy it.
- **Test count changes.** `tests/smoke.sh` currently reports **42 passed**. Adding tests changes that
  number. State the new count in the PR body so a reviewer can tell a new test from a lost one.
- **The workflow needs `permissions: pull-requests: read`** and `GH_TOKEN` in the environment for
  any `gh` call.

### Step 4 — Exercise the gate against known-bad input before trusting it

Prove the evaluator rejects as well as accepts. At minimum, run the three AC10–AC12 cases by hand
and paste the output. A gate that has only ever been shown passing has not been tested.

### Step 5 — Commit, then gate on the committed state

```fish
git add -A
git status --short
git commit -m "Encode the type-aware label policy and gate PRs on it (#54, #51)"
scripts/check --all >/tmp/g.log 2>&1; echo "gate exit=$status"
git show --check HEAD >/dev/null 2>&1; echo "show --check exit=$status"
tail -3 /tmp/g.log
```

Expected: both `exit=0`, and the tail showing the new smoke-test count.

### Step 6 — STOP: push is gated

Request approval. After pushing, confirm CI is green **and** report the new check's exact context
name — that string is what branch protection would need, and it is the **job key**, not the
workflow `name:`. This repo's existing required context is `checks`, which is `lint.yml`'s job key
with no job-level `name:`. Getting this wrong is how you block every future PR.

```fish
gh pr checks <pr> -R Jared-Godar/macos-system-health
gh api repos/Jared-Godar/macos-system-health/commits/(git rev-parse HEAD)/check-runs \
  --jq '[.check_runs[].name]'
```

### Step 7 — STOP: opening the PR is gated

## 6. PR metadata (all at creation time)

```fish
gh pr create -R Jared-Godar/macos-system-health \
  --title "Encode the type-aware label policy and gate PRs on it (#54, #51)" \
  --assignee Jared-Godar \
  --milestone "Remediation - Back to Step 0" \
  --label area:governance --label priority:high --label type:feature \
  --label effort:medium --label status:ready --label risk:high \
  --body "Closes #54
Closes #51

<the policy file's final shape and any deviation from §3b with reasoning; the risk:low decision and
both receipts (labels.json + gh label list); the pure/IO split and why; the AC10-AC12 negative-test
output verbatim; the new smoke-test count vs 42; scripts/check output from the COMMITTED state; the
CI run receipt; the exact check-run context name; and the branch-protection step recorded as OWED
with the command the maintainer will run>"
```

All six labels are confirmed present in `.github/labels.json` (PM-verified 2026-07-21). Both issues
carry the `Remediation - Back to Step 0` milestone, so the PR does too.

Verify:

```fish
set pr (gh pr view -R Jared-Godar/macos-system-health --json number --jq .number)
gh pr view $pr -R Jared-Godar/macos-system-health \
  --json number,labels,milestone,assignees,projectItems,body \
  --jq '{number, labels:[.labels[].name], milestone:.milestone.title, assignees:[.assignees[].login], projects:[.projectItems[].title], closes54:(.body|test("Closes #54")), closes51:(.body|test("Closes #51"))}'
gh pr checks $pr -R Jared-Godar/macos-system-health --watch
```

Expected: six labels, milestone `Remediation - Back to Step 0`, assignee `Jared-Godar`, project
membership present, both `closes*` true, all checks green.

## 7. Checkpoints

1. **Branch ready** — branch name, clean tree, `main` synced, spec placed.
2. **`risk:low` landed** — both receipts from Step 2.
3. **Negative tests passing (CRITICAL)** — verbatim AC10–AC12 output, before any push request.
4. **PR created (CRITICAL)** — number/URL, full metadata read-back, the check-run context name.
5. **CI green** — `gh pr checks` output.
6. **After merge** — PR `MERGED`, #54 and #51 `CLOSED`, `main` fast-forwarded, branch deleted,
   `status:ready` stripped from both, board Status `Done` for both issues and the PR.

Between 4 and 6 the PR is under merge **HOLD**. You do not merge and do not declare merge-readiness;
the PM re-runs a sample of your receipts and announces **GREEN LIGHT**.

## 8. Numbered acceptance criteria

**Policy definition (#54)**

- **AC1.** `risk:low` exists in `.github/labels.json` — in `schema.risk.values` **and** in
  `labels[]` with a description and color — and on the live repository. Both receipts shown.
- **AC2.** `.github/label-policy.json` exists, is valid JSON, and encodes: `always_required` =
  AREA, PRIORITY, TYPE, EFFORT, STATUS; RISK required when TYPE is `type:feature` or `type:bug`;
  CONFIDENCE and HOUSEKEEPING optional.
- **AC3.** Every schema category and label the policy names exists in `.github/labels.json`,
  verified by a command whose output is shown — not by inspection.
- **AC4.** The 8 unschemed GitHub defaults are recognized by the policy (no drift warning) without
  being required. Their fate stays with #93.

**Gate implementation (#51)**

- **AC5.** `scripts/check-label-policy` exists, is committed `100755`, and evaluates a label set
  passed as input with **no network access** (§3a).
- **AC6.** A separate code path fetches a PR's labels and feeds the same evaluator.
- **AC7.** `scripts/check-label-policy` is present in `EXECUTABLE_FILES` in `scripts/check`, so it
  is `bash -n`'d, ShellCheck'd, and mode-checked. Show the diff.
- **AC8.** `.github/workflows/label-policy-gate.yml` triggers on `pull_request` for `opened`,
  `edited`, `synchronize`, `labeled`, `unlabeled`, and `ready_for_review`.
- **AC9.** On failure the message itemizes each missing required category **and** names the valid
  labels for it, pointing at `.github/label-policy.json`. On success it lists the satisfied
  categories in one line. Show both messages.

**Negative tests — the load-bearing ones**

- **AC10.** A `type:feature` label set with **no `risk:*`** FAILS. This is the exact class that
  slipped through before; it is the single most important test in this PR.
- **AC11.** A `type:docs` label set with no `risk:*` PASSES.
- **AC12.** A label set missing an `always_required` category (e.g. no `effort:*`) FAILS, and the
  message names `effort` specifically.
- **AC13.** All three run inside `tests/smoke.sh` via `run_test`, pass in the committed tree, and
  the new total test count is stated against the previous **42**.

**Integration and closure**

- **AC14.** `scripts/check --all` is green **on the committed state**, with the output pasted and
  the commit SHA it ran against named.
- **AC15.** CI `quality` is green on the pushed branch, with the run receipt.
- **AC16.** The new check's exact **context name** (job key) is reported, with the command that
  produced it.
- **AC17.** Branch protection is **not** modified by this PR. The step is recorded as **OWED** in
  the PR body, with the exact `gh api` command the maintainer will run, and the explicit note that
  it should be flipped only after one PR has been observed green under the new check. A misnamed
  required context blocks every future PR including its own fix.
- **AC18.** `CONTRIBUTING.md` carries a pointer paragraph to `.github/label-policy.json` — the
  type-aware rule in one sentence, no duplicated selection guide.
- **AC19.** CHANGELOG entry under `[Unreleased]`.
- **AC20.** Every deliberately-omitted or deferred item is named explicitly in the PR body: the 7
  violating issues (#53), the selection guide (#52 → #78), the orphan labels (#93), branch
  protection (AC17).

## 9. Verification status of the commands in this spec

The #81 spec shipped worked examples nobody had run. This table says which is which.

| Command / claim | Status |
|---|---|
| `ls` showing `label-policy.json` and `check-label-policy` absent | **PM-VERIFIED** 2026-07-21 |
| The 7-violator list and `open issues: 23` | **PM-VERIFIED** — computed from `gh issue list` |
| `risk` schema = `['high','medium']`; 24/32/8 label breakdown | **PM-VERIFIED** |
| `jq` at `/usr/bin/jq` = 1.7.1-apple | **PM-VERIFIED** locally; **UNVERIFIED** on `macos-15` runners |
| `EXECUTABLE_FILES` contents and the no-globbing behavior | **PM-VERIFIED** — read from `scripts/check` on `main` |
| `tests/smoke.sh` reports 42 passed | **PM-VERIFIED** from the #64 walkthrough and PR #90's transcript; **not re-run this session** |
| Existing branch-protection contexts `["GitGuardian Security Checks","checks"]` | **PM-VERIFIED** via `gh api` |
| `gh label create` invocation in Step 2 | **PM-UNVERIFIED** — never run; flags are from the CLI docs |
| The §3b policy file shape | **PM-UNVERIFIED** — a proposal, not a tested artifact |
| The `check-runs` command in Step 6 | **PM-UNVERIFIED** — the shape of its output is assumed |
| That a new workflow's context name equals its job key | **PM-UNVERIFIED here**, but consistent with `checks` in this repo. Confirm empirically in Step 6 rather than trusting it. |

## 10. Dependencies and sequencing

- **#54 → #51 → #53.** Definition, then enforcement, then backfill. #53 is metadata-only and
  PM-executed after this merges; it needs `risk:low` to exist, which is why AC1 is in this PR.
- **#93** (labels.json ↔ live drift, 8 orphans) was filed 2026-07-21 while scoping this. It is
  deliberately **not** bundled — deleting labels is destructive and needs usage counts first.
- **#52** is deferred to **#78**'s `docs/governance/` layer by maintainer decision, 2026-07-21.
  This PR ships only the pointer paragraph.
- **#62** is the other open branch-protection item (`strict:false`). Do not touch it here; AC17
  keeps this PR out of branch protection entirely.

## 11. References

- **#54** — type-aware policy, **plus the PM correction comment of 2026-07-21** (`risk:low`, label
  counts, deferral). **#51** — the gate. **#53** — backfill. **#52** — SOP, deferred. **#93** — drift.
- `.github/labels.json` (schema v1.0, 32 entries) · `scripts/check` (`EXECUTABLE_FILES`,
  `assert_committed_modes`) · `tests/smoke.sh` (`run_test` harness) ·
  `.github/workflows/lint.yml` (job key `checks`, the context-name precedent)
- `scripts/install-quality-tools` — the Bash-3.2 `case`-instead-of-assoc-array precedent
- `AGENTS.md` § "Definition of done", § "Model and effort sizing", § "Canonical work-item flow"
- #83 — why a script under `scripts/` is not automatically linted · #85 — why a silently
  permissive gate is worse than no gate
