# AGENTS.md — DM Screen App

## Project

DM Screen App — A desktop/tablet DM screen for tabletop RPGs with initiative tracking, entity management, roll tracking, and multi-system support.

**Core value:** The DM's single source of truth at the table: initiative order, entity details, and roll history — organized by game system, extensible by the user.

**Repository:** `/Users/zacharyreyes/Documents/GitHub/SaveState`

## Workflow

Run phases in order. Each phase: discuss → plan → execute → verify → complete.

```
/clear

/gsd-discuss-phase 1  — gather context and clarify approach
/gsd-plan-phase 1     — create detailed plan
/gsd-execute-phase 1  — execute plans
/gsd-verify-work      — verify deliverables
/gsd-complete-milestone (when all phases done)
/gsd-progress          — check current state
```

## Phase Overview

| Phase | Name | Status |
|-------|------|--------|
| 1 | Initiative & Core Layout | Pending |
| 2 | Entity Detail View | Pending |
| 3 | Game System & Entity Builders | Pending |
| 4 | Roll Tracker & Search | Pending |
| 5 | Cross-Platform Polish | Pending |
| 6 | Networking Architecture | Pending |

## Requirements

See: `.planning/REQUIREMENTS.md`

**44 requirements** across 6 phases. All mapped.

## Key Constraints

- **Platform**: macOS, Linux, Windows, iPadOS (no phone scaling)
- **Storage**: Local-only (no cloud)
- **Networking**: Architecture only in v1 (future LAN host/client)

## Workflow Settings

| Setting | Value |
|---------|-------|
| Mode | yolo |
| Granularity | standard |
| Execution | Parallel |
| Git Tracking | Yes |
| Research | No |
| Plan Check | Yes |
| Verifier | Yes |
| Nyquist Validation | Yes |
