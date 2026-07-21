# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records (ADRs) that document significant design decisions in the `system-health` project. ADRs capture the context, decision, and rationale behind important architectural choices, making them a resource for contributors and future maintainers to understand the "why" behind the system's design.

## ADRs

1. **[ADR 0001: Report-Only Default with Explicit Maintenance Mode](0001-report-and-maintenance-boundaries.md)** — Documents the two-mode architecture: read-only report mode (default) and explicit-opt-in maintenance mode. Explains the rationale for the maintenance boundary and why certain actions (Conda/pip upgrades, system updates) are intentionally manual.
