# job-slug

## Summary
What we're building and why. 2-4 sentences.

## Goal (optional — for long-running or multi-session work)
Condition: [what must be true for this job to be done — above and beyond the phase checklist]
Budget: [max turns or tokens — e.g., "30 turns"]
Budget used: [turns/tokens used so far]
Budget policy: [continue, shrink scope, or defer if budget is exceeded]
Evidence: [commands or artifacts that prove completion — e.g., "pytest tests/ → all pass"]

## Baseline
- Date: [when first verified]
- Verifier: [command that establishes truth]
- Result: [N tests, M failing {names}]
- Commit: [sha]
- Protocol: v2

## Research
- [verified] Finding with evidence (file:line, command output, doc ref)
- [assumed] Finding that needs confirmation — state what would verify it
- [open] Unresolved question

## Design
- Approach: [what we're doing]
- Assumptions: [load-bearing assumptions, each tagged [assumed] with what would confirm it]
- Alternatives: [what we considered, why rejected]
- Interfaces: [what surfaces change]
- Old contract: [what still speaks the old interface — must not break]
- Rollback: [how to undo if it goes wrong]

## Receipts
Every non-trivial decision traces to a source. Never silently inscribe a constraint nobody gave you.

| Decision | Source |
|---|---|
| [decision] | [verbatim user quote \| file:line \| "my judgment — rationale: …"] |

## Delegation Plan (optional — add/backfill when delegating non-trivial work)
Planned subagent lanes. Read-only lanes may run in parallel. Write lanes are serialized unless paths/contracts are provably disjoint and the reason is recorded here. Job-file writes stay parent-owned.

| ID | Phase | Agent | Objective | Scope / allowed paths | Forbidden paths | Dependencies | Gate | Status |
|---|---|---|---|---|---|---|---|---|
| [lane-id] | [phase] | [agent] | [single outcome] | [scope or paths] | [for write delegates] | [lane ids or none] | [observable check/evidence] | planned |

## Progress
Work one phase at a time. The first phase with status `pending`/`reopened` or an unchecked item is the active phase. Within that phase, Auto may delegate independent lanes and collect receipts, but it still owns phase state and verification. When every item in a phase passes, set its status to `passed` and let the next phase become active. For simple jobs, collapse to one phase.

### Phase 1: Research
Understand the problem. Gather facts: read code, search docs, ask questions. Populate `## Research` with findings tagged `[verified]` or `[assumed]` with source. Unanswered questions marked `[open]`. No code changes — just understanding.

- pass: Research section populated + every load-bearing claim tagged with source
- status: pending | passed | reopened
- [ ] [item]
- [ ] [item]

### Phase 2: Design
Decide the approach. Populate `## Design`: approach, alternatives (and why rejected), interfaces that change, old contract, rollback. Every non-trivial decision recorded in `## Receipts` with its source.

- pass: Design section complete + every decision has a Receipt
- status: pending | passed | reopened
- [ ] [item]

### Phase 3: Build
Implement one slice at a time. A slice is the smallest unit of behavior-complete work — never a stub. After each slice: cycle steps 4-5 (verify delta + review). If a slice can't be done properly, shrink it.

- pass: every slice passes its check
- status: pending | passed | reopened
- [ ] Slice: [what] — check: [observable check — e.g. "pytest tests/test_x.py passes"]
- [ ] Slice: [what] — check: [observable check]

### Phase 4: Verify
Run cycle steps 4-7 across the completed work: re-run full gate (report delta), reviewer, adversarial review, goal check. Prove nothing broke. If any failure or finding reveals an assumption from an earlier phase was wrong, re-open that phase — do not push forward with a cracked foundation.

- pass: delta reported + reviewer clean + adversarial review clean + goal-evaluator verdict recorded
- status: pending | passed | reopened
- [ ] Re-run full gate, report `baseline: N tests, M failing {…} → now: N' tests, M' failing {…}`
- [ ] Review clean (delegated to reviewer)
- [ ] Adversarial review clean (delegated to adversarial-reviewer)
- [ ] Goal-evaluator verdict recorded for the active phase or job goal, as appropriate

### Phase 5: Close
Write the disclosure to `## Closeout`. Public docs/protocol/config updates should already be included before Phase 4 review; if Close discovers or makes late public-surface changes, reopen Phase 4 and rerun reviewer/adversarial/goal gates before Closeout. If `## Goal` exists, run and record a final `job_goal` verdict before Closeout. Report completion.

- pass: public docs updated before Phase 4 review or Phase 4 reopened after late public-surface changes + final job_goal verdict `FULFILLED` when `## Goal` exists (or `BLOCKED` with explicit blocked disclosure) + Closeout written + job archived + any reusable lesson consolidated with bidirectional provenance checked
- status: pending | passed | reopened
- [ ] Docs updated before Phase 4 review, or Phase 4 reopened after late public-surface changes
- [ ] Final `job_goal` verdict is `FULFILLED`, if `## Goal` exists (or `BLOCKED` with explicit blocked disclosure)
- [ ] Disclosure written to `## Closeout`
- [ ] Job archived to `jobs/archive/`
- [ ] Lesson consolidated to `memory/` if this job yielded one (`Consolidated to:` line in Closeout)
- [ ] If a lesson was consolidated, provenance chain resolves both directions (`Source: jobs/archive/<slug>.md` in memory + `Consolidated to: memory/...` in Closeout, and both targets exist); otherwise record none

## Subagent Receipts (optional — accepted non-trivial delegation results)
Only record results Auto accepted after checking scope and evidence. A subagent's status is not proof until Auto verifies the relevant gate.

| ID | Agent | Status | Scope covered | Evidence | Changed paths | Parent decision | Verification |
|---|---|---|---|---|---|---|---|
| [lane-id] | [agent] | [passed/blocked/etc.] | [scope] | [file:line, URL, or command output] | [none or paths] | [accepted/rejected + why] | [parent-run gate] |

## Decisions
- [YYYY-MM-DD] [decision] — rationale

## Issues
- [ ] `[match-key]` [finding] — severity: blocking|high|advisory|note — status: open

## Follow-ups
- [ ] [out-of-scope item spotted during this job]

## Closeout
- **Verified:** what was actually run or read
- **Assumed:** what was reasoned but not confirmed
- **Goal:** FULFILLED | BLOCKED — <one-line final `job_goal` evidence; `NOT FULFILLED` reopens the relevant phase and is not valid for Closeout>
- **Couldn't verify:** what's unknowable from here — includes deliberately-skipped checks and why, plus what a cheap proxy did not cover
- **Most likely wrong:** what you'd bet against if forced
- **Consolidated to:** [memory/gotchas.md#N or memory/decisions.md#DEC-XXXX — only if this job yielded a reusable lesson and the bidirectional provenance check passed; omit otherwise]
