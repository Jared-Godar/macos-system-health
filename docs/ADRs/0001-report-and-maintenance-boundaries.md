# ADR 0001: Report-Only Default with Explicit Maintenance Mode

## Status

Accepted

## Context

Automated health monitoring tools often perform mutations (system changes) without clear user consent or visibility. This creates two problems:

1. **Surprise mutations**: Users expect read-only monitoring tools to observe state, not change it. Undocumented side effects erode trust.
2. **Diverse environments**: macOS supports multiple package managers (Homebrew, Conda, pip) and configuration systems (LaunchAgent, dotfiles). Some users may not use all of them; mutations in unused subsystems still consume resources and carry risk.
3. **Recovery uncertainty**: When automated maintenance fails or causes side effects, users need clear audit trails and backups to recover or investigate.

System health monitoring should prioritize user intent and control. Users need:
- Visibility into system state (reports)
- Confidence that monitoring is read-only by default
- Explicit opt-in for maintenance actions
- Clear documentation of what each action does and why some actions are intentionally manual

## Decision

We implement a two-mode architecture:

### Report Mode (Default, Read-Only)

Report mode is the default and performs no mutations except:
- **Logging**: Creating timestamped log files in `$LOG_DIR` (user-defined, intentional)
- **Backup snapshots**: Creating environment snapshots in `$BACKUP_DIR` (references only, no mutations of those environments)

Report mode is suitable for:
- Scheduled automated runs (e.g., LaunchAgent every morning)
- Ad-hoc monitoring and health checks
- Integration with monitoring systems that expect read-only behavior

### Maintenance Mode (Explicit Opt-In)

Maintenance mode requires explicit user invocation: `bin/system-health maintenance`

Maintenance mode performs only documented mutations:
- **Homebrew**: `brew update`, `brew upgrade`, `brew cleanup`
- **Conda**: `conda clean --all` (removes unused packages)
- **Backup cleanup**: Deleting old log and snapshot files (retention-based)

### Intentionally NOT Automatic

The following actions require manual user intervention and are not performed by either mode:

- **`conda update --all`**: Conda environments are often pinned to specific versions for reproducibility. Mass updates risk breaking development environments and research workflows.
- **Mass pip upgrades**: Project dependencies are pinned for stability. Blanket pip upgrades can introduce incompatibilities without testing.
- **System software updates**: macOS software updates (OS, security) require careful planning, testing, and user discretion. This tool does not attempt to manage them.

## Rationale

### Why Read-Only Default?

Read-only is safer than mutation-by-default. If a read-only tool is run unexpectedly (e.g., cron misfire, manual typo), it observes state without causing damage. This principle is called "fail safe" in security: the default state is the safest one.

### Why Explicit Maintenance Opt-In?

Explicit invocation creates an "intent barrier." The user must consciously decide to run maintenance, not stumble into it. This aligns with principle of least surprise: `bin/system-health` does routine health checks; `bin/system-health maintenance` explicitly changes the system.

### Why Logs and Backups in Report Mode?

Logging is read-only from a practical perspective (it doesn't change user-facing systems). Backups are recovery aids that improve safety, not risky actions. Both are side effects we accept because they enable:
- Audit trails (what changed, when, why)
- Recovery (restore a previous snapshot if something goes wrong)
- Transparency (users can inspect what was observed)

### Why Exclude Conda and pip Upgrades?

Many workflows depend on pinned environments:
- **Conda**: Research and ML projects pin library versions for reproducibility. A mass update could break months of work.
- **pip (projects)**: Application and research code relies on specific dependency versions. Breaking changes in transitive dependencies are common.

These should remain manual decisions, not automated risks.

### Why Exclude System Updates?

macOS software updates are high-impact and require:
- Backup before updating
- Testing on a single machine before rolling out across a team
- Time planning (some updates require reboots)

Automating them without deep system understanding risks bricking machines or breaking workflows. This is user-level policy, not tool-level behavior.

## Consequences

### Benefits

✅ **Safety**: Read-only default means accidental runs cause no harm.
✅ **Transparency**: Logs and backups provide audit trails and recovery paths.
✅ **Control**: Users decide when maintenance happens; no surprise mutations.
✅ **Stability**: Pinned environments (Conda, pip) stay stable unless explicitly upgraded.

### Tradeoffs

⚠️ **Manual effort**: Conda and pip upgrades require user action; they are not automated.
⚠️ **Documentation burden**: Users must read docs to understand the two modes; they are not self-evident from the tool name.
⚠️ **LaunchAgent limitation**: Scheduled runs can only perform reports, not maintenance (by design).

## Alternatives Considered

### Single Automatic Mode
A tool that always performs updates (Homebrew, Conda, pip, cleanup) would be simpler:
- ✅ Single entry point
- ❌ No ability to preview changes before applying
- ❌ No opt-in; risky for automation pipelines
- ❌ Violates principle of least surprise

### Opt-Out Maintenance (Default-On)
Maintenance-by-default with an opt-out flag would automate the most common cases:
- ✅ Homebrew updates happen automatically
- ❌ Violates principle of least surprise (users expect read-only monitoring)
- ❌ Difficult to audit ("why did my brew update run at 2am?")
- ❌ Not safe for shared systems or automated deployments

### Three Modes (Report, Preview, Apply)
Report only → Preview changes → Apply changes would maximize control:
- ✅ Three-step verification before applying
- ❌ Added complexity and cognitive burden
- ❌ More CLI surface area to learn and document
- ❌ Overkill for most workflows

## Related Issues

- [#7](https://github.com/Jared-Godar/macos-system-health/issues/7) Retention/cleanup implementation follows this ADR (cleanup only runs in maintenance mode)
- [#24](https://github.com/Jared-Godar/macos-system-health/issues/24) Retention policy enforcement follows maintenance-only boundary
- [#11](https://github.com/Jared-Godar/macos-system-health/issues/11) Per-tool opt-in honors this boundary

## References

- [README.md](../../README.md) — Safety model section
- [SECURITY.md](../../SECURITY.md) — Threat model
- [CONTRIBUTING.md](../../CONTRIBUTING.md) — Maintenance workflow
