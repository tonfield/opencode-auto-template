# OpenCode Auto memory

These docs hold durable knowledge for this OpenCode Auto configuration repo. They are for both humans and AI agents working on the agent system itself.

## Recommended reading order

1. [`README.md`](../README.md) — user-facing setup and overview.
2. [`AGENTS.md`](../AGENTS.md) — policy reference for the job system.
3. [`agents/auto.md`](../agents/auto.md) — operational protocol for the Auto primary agent.
4. [`memory/decisions.md`](./decisions.md) — accepted project-level decisions.
5. [`memory/gotchas.md`](./gotchas.md) — recurring pitfalls and invariants.

## Authority rules

- Root `AGENTS.md` and `agents/auto.md` define the current operating protocol.
- `memory/decisions.md` records durable choices that should survive individual jobs.
- `memory/gotchas.md` records repeatable failure modes and safe practices.
- `jobs/` in this repo is local Auto work state and remains gitignored; project repos initialized from `project/` may track their own `jobs/*.md` files.
