# Executor Seed Prompt Template

This template shows how to structure executor seed prompts with TodoWrite tracking for PM visibility.

---

## Copy-Paste Template

```fish
--model opus --effort high "
Read prompts/[ISSUE-NAME-AND-NUMBER].md fully.

PROGRESS TRACKING: Use TodoWrite to create and update a discrete task list as you work:
- Create the list immediately after reading this prompt (7-10 items matching the spec checklist)
- Mark each item complete as you finish it
- Add new items if the spec uncovers unanticipated work
- Update the list after each logical milestone (implementation, testing, changelog, PR opened)

The PM will watch this list and can intervene if execution deviates.

Then proceed with the spec. All verification steps must pass locally before opening the PR.
"
```

---

## TodoWrite Item Examples (Adapt to Your Spec)

Create these as initial items; executor refines them based on the specification:

```
- [ ] Read specification fully
- [ ] Create branch and verify clean working tree
- [ ] Implement core feature (first module/function)
- [ ] Implement supporting feature (second module)
- [ ] Add test cases for feature 1
- [ ] Add test cases for feature 2
- [ ] Run full test suite locally (scripts/check --all)
- [ ] Update CHANGELOG.md per requirements
- [ ] Open PR with all metadata (labels, issue links, milestone)
- [ ] Verify CI passes
- [ ] Prepare PM extract summarizing work & merge readiness
```

---

## Where TodoWrite Instruction Goes

1. **After `--model` and `--effort` flags** but before the detailed specification reference
2. **Before** any instruction that starts implementation (to ensure list is created before work starts)
3. **Concise:** 3–4 sentences, not a novel (spec file has the details)

---

## What PM Sees

As the executor works, the PM can query the TodoWrite state to see:
- What's in progress
- What's done
- What's about to happen
- If execution is stuck or deviating

**Result:** PM can course-correct early instead of discovering issues only at PR review.

---

## Integration with This Project

All future executor seed prompts in `prompts/` should follow this pattern. Example:

- `prompts/2026-07-20-issues-7-24-retention-cleanup.md` — **current prompt for Issues #7+#24** (will be updated with TODO tracking for future reference)
- `prompts/[next-issue].md` — **future prompts must include TODO instruction block**

---

## Pre-Merge Gate: Project Membership Verification

Before announcing GREEN LIGHT (merge-readiness), executor MUST verify:

```fish
# Verify linked issue(s) are in project
gh issue view <ISSUE_NUMBER> --json projectItems

# Verify PR is in project
gh pr view <PR_NUMBER> --json projectItems
```

Both commands should show `"projectItems":[{"title":"macOS System Health Roadmap",...}]` (non-empty).

If either is missing, manually add to project:

```fish
gh issue edit <ISSUE_NUMBER> --add-project "macOS System Health Roadmap"
gh pr edit <PR_NUMBER> --add-project "macOS System Health Roadmap"
```

**See:** `executor-pre-merge-project-membership-gate.md` in memory for full gate checklist.

---

## Notes

- **TodoWrite creation:** Executor creates the list at start, not PM
- **List updates:** Executor updates as they progress (mark items complete)
- **Specification file:** Should live in `prompts/[issue-name].md` (detailed requirements, checklists, etc.)
- **Seed prompt:** The `--model --effort "..."` invocation that points to the spec and includes TODO instruction
- **Pre-merge gate:** Always verify project membership before announcing GREEN LIGHT
- **Issue creation:** When creating follow-up issues, use `--add-project` flag at creation time
