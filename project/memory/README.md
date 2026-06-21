# [Project Name] memory

These docs are for both humans and AI agents working on this project.

## Recommended reading order
1. [Overview or architecture doc](./[overview-doc].md)
2. [Decision log](./decisions.md)
3. [Gotchas](./gotchas.md)

## Standard docs

| Doc | Purpose | Update when |
|---|---|---|
| `memory/README.md` | Doc map, reading order, authority, fast lookup | The docs set or ownership guidance changes |
| `memory/decisions.md` | Accepted project-level decisions and supersessions | A new durable decision is accepted or superseded |
| `memory/gotchas.md` | Recurring pitfalls, invariants, change-impact warnings | A repeat mistake, hidden constraint, or file-coupling rule is discovered |

## Authority rules
- `AGENTS.md` holds project operating rules, conventions, and commands.
- `memory/` holds reusable project knowledge.
- `jobs/` holds job-local work and state.
- Docs describe accepted current truth, not speculative design.

## Fast lookup

| If you are asking... | Start here |
|---|---|
| What is the project map? | `[overview doc]` |
| What decisions are deliberate? | [`memory/decisions.md`](./decisions.md) |
| What easy-to-miss rules apply? | [`memory/gotchas.md`](./gotchas.md) |
| Where should new knowledge go? | This file first, then the most relevant linked doc |
