# [Project Name]

## Project Overview
- [what this repo is, stack, runtime, purpose]

## Project Structure
- `[path]` - [what lives here]
- `jobs/` - job files (one per job, tracks research, design, progress, closeout)
- `memory/` - shared project knowledge base (gotchas, decisions)

## Commands
- Dev: `[command]`
- Test: `[command]`
- Lint: `[command]`

## Conventions
- [repo-specific coding, naming, architectural conventions]

## Verification
- [how to verify changes in this repo]

## Gotchas
- [setup quirks, environment assumptions, easy-to-miss constraints]

## Safe Parallelism
- Read-only delegation lanes: [safe areas agents may inspect in parallel]
- Safe disjoint edit lanes: [paths/contracts that can be edited independently]
- Keep serialized: job files, shared config, package/lock files, migrations, generated artifacts, and other high-coupling surfaces

## Job System
- Non-trivial work uses job files at `jobs/[slug].md`. Auto creates them via Decompose (Step 0) for complex requests; `/job <slug>` switches between existing jobs.
- Job files use Protocol v2: Baseline with Protocol version, Receipts (every decision traces to a source), optional Delegation Plan for non-trivial subagent lanes, phase-grouped Progress (each phase has a pass condition), optional Subagent Receipts for accepted delegated outputs, and Closeout disclosure. Completed jobs move to `jobs/archive/`; closeout consolidates reusable lessons to `memory/` with provenance checked.
- The Auto agent follows the verification protocol as an orchestrator: clarify, establish baselines, decompose work into safe lanes, delegate read-only lanes in parallel where useful, assign bounded write lanes with explicit paths only through a foreground write-capable subagent path, verify child output before accepting it, report deltas, tag claims `[verified]`/`[assumed]`, check impact, delegate to reviewer (every code-change turn and job Phase 4 Verify), run adversarial review at verification boundaries for completed durable work, delegate to goal-evaluator (every non-urgent turn), close with a disclosure. Depth scales naturally with the work. Urgent production incidents use the compressed incident path documented by the root Auto protocol. Auto also applies two continuous lenses alongside the cycle — critical thinking (question the premise, surface uncertainty and trace claims, steel-man the opposite, pre-mortem non-trivial actions) and simplicity (stop at the first rung that holds, prefer deletion over addition, match the effort to the work); see `agents/auto.md §Critical Thinking` and `§Simplicity`. Both run inside the existing steps, not as new gates; both are lazy in their own domain, never about correctness.
