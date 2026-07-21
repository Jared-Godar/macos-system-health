# CLAUDE.md

The operating contract for this repo is **`AGENTS.md`** — read it and follow it.
This file exists only because Claude Code reliably auto-loads `CLAUDE.md`, while
its auto-load of `AGENTS.md` is tool/version dependent. It mirrors the three
non-negotiables so they hold even if `AGENTS.md` is never opened; it is a safety
net, not a second contract. `~/.claude/CLAUDE.md` (cross-project standing rules)
still applies and is not restated here.

- **Done means done, with receipts.** Report an action complete only if it was
  executed and verified this session. Distinguish plainly: done (receipt) /
  relayed / queued / owed / not done. Announcing a mechanism is not the behavior.
- **Four gated actions.** These need the maintainer's explicit per-instance
  go-ahead: **push**, **open PR**, **merge** (GUI, only on the PM's GREEN LIGHT),
  and **release-tag**. Everything else agreed in `AGENTS.md` is standing authorization.
- **Model-tier flag.** A session cannot change its own model/effort mid-run. If it
  detects it is on a downgraded tier for the work (especially a PM/governance
  thread), it flags that to the maintainer immediately rather than pushing through.
