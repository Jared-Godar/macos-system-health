# `prompts/` is a frozen historical record (frozen 2026-07-21)

**Do not add, edit, or copy specs here, and do not read these files as current exemplars.**

This directory holds executor seed prompts and specs authored **before 2026-07-21**. As of that
date it is frozen: it is the historical record of how work was handed off in the pre-`AGENTS.md`
era, kept for provenance, not a live working area.

## Why it is frozen

- **Specs are immutable after handoff.** Once a spec has been handed to another session — or to the
  maintainer to launch — it is read-only; a revision goes to a *new* dated file, never an in-place
  edit. Freezing the whole directory makes that immutability structural rather than a rule someone
  must remember. See `AGENTS.md` § Standing commitments ("Specs are immutable after handoff") and
  § "How these rules reach every session".
- **A `PreToolUse` hook enforces it.** The tracked `.claude/settings.json` denies `Write`/`Edit` on
  any path matching `*/prompts/*`, with one deliberate carve-out: **this `README.md`**, so the
  freeze can be documented in place. The carve-out is a single filename; it does not make any
  historical spec writable. (A `git mv` *out* of `prompts/` is a shell command, not `Write`/`Edit`,
  so relocating a file is not blocked — moving is fine; writing in place is not.)

## Where specs live now

New specs are authored at:

```
artifacts/specs/<UTC-timestamp>-issue-<n>-<slug>.md
```

tracked in the repo, with the timestamp as the immutability mechanism — a revision lands at a new
path and cannot overwrite its predecessor. The living, copy-from template is
[`artifacts/specs/TEMPLATE.md`](../artifacts/specs/TEMPLATE.md); it was moved out of this frozen
directory (issue #67) precisely so it stays maintainable. A conformance check in `scripts/check`
asserts every tracked spec opens with the durable-contracts block.

## If you are a future session browsing this directory

Read the files here as *what was done then*, not *how to do it now*. For the current contract, read
`AGENTS.md`; for the current spec shape, copy `artifacts/specs/TEMPLATE.md`.
