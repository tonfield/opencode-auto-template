# add-grid-search

## Summary
Add a parameter grid search runner to the backtester for automated strategy optimization. The runner sweeps combinations of entry/exit parameters and reports best performers by PnL, Sharpe, and max drawdown.

## Goal
Condition: GridRunner produces a ranked results table for the demo grid_config and all existing backtester tests still pass.
Budget: 20 turns
Budget used: 0 turns
Budget policy: Surface the overage and recommend continue, shrink scope, or defer if the budget is exceeded.
Evidence: `uv run pytest` → all pass, `uv run python -m backtester.grid --demo` → results table printed

## Baseline
- Date: 2026-06-13
- Verifier: uv run pytest
- Result: 47 tests, 3 failing {test_replay_bounds, test_empty_chain, test_date_edge}
- Commit: abc1234
- Protocol: v2

## Research
- [verified] backtester/replay.py:89 — StrategyRunner accepts a dict of parameters and dispatches by strategy_type [verified — read the dispatch at line 127]
- [verified] simulator/config.py:34 — StrategyConfig is flat dict with per-strategy sections. Parameter sweep would add a grid_config key [verified — read config loader]
- [assumed] All strategies share the same parameter schema — would confirm by reading config validation at config.py:89

## Design
- Approach: Add GridRunner class in backtester/ that reads `grid_config` from simulator config. It expands parameter combinations with itertools.product, runs StrategyRunner per combo, and collects results.
- Assumptions: [assumed] itertools.product handles the demo 3×3 grid without memory issues (would confirm by profiling); [assumed] CSV output is sufficient vs. a database (would confirm by checking result-set size in production)
- Alternatives:
  - Option A: Modify StrategyRunner in-place — rejected, would break existing single-run behavior
  - Option B: External runner script — rejected, needs access to internal replay state
- Interfaces: New `grid_config` key in StrategyConfig. GridRunner outputs results CSV to `results/<run_name>/grid_results.csv`.
- Old contract: Existing StrategyConfig users unaffected — `grid_config` is optional and defaults to None.
- Rollback: Delete `grid_config` key from configs and GridRunner.py. No schema migration needed.

## Receipts
| Decision | Source |
|---|---|
| itertools.product for expansion | my judgment — simplest approach for the demo 3x3 grid while still handling arbitrary parameter counts |
| CSV output (not parquet) | my judgment — human-readable, sufficient for <10k rows; switch is trivial later |
| Reuse existing kv/config client | simulator/config.py:34 — already exports the loader GridRunner needs |

## Delegation Plan
| ID | Phase | Agent | Objective | Scope / allowed paths | Forbidden paths | Dependencies | Gate | Status |
|---|---|---|---|---|---|---|---|---|
| R1 | Research | repo-search | Map StrategyRunner dispatch and config loader | `backtester/`, `simulator/config.py`, `tests/` | n/a | none | Findings cited in `## Research` | completed |
| T1 | Design | test-strategist | Recommend focused grid-runner checks | test manifests and existing test layout | n/a | R1 | Slice checks named in Phase 3 | completed |
| B1 | Build | patch-implementer | Add GridRunner expansion tests | `tests/test_grid.py` | production code | R1,T1 | `pytest tests/test_grid.py::test_expansion` passes | completed |

## Progress

### Phase 1: Research — pass: every load-bearing claim tagged with file:line source
- status: passed
- [x] Map call sites and existing patterns
- [x] Capture findings in `## Research` with citations

### Phase 2: Design — pass: Design section complete + every decision has a Receipt
- status: passed
- [x] Populate `## Design` (Approach, Alternatives, Interfaces, Old contract, Rollback)
- [x] Populate `## Receipts` for non-trivial decisions

### Phase 3: Build — pass: every Slice has a failable check
- status: passed
- [x] Slice: GridRunner class with parameter expansion — pass: `pytest tests/test_grid.py::test_expansion` passes, 3x3 grid yields 9 combos
- [x] Slice: Integrate with existing StrategyRunner dispatch — pass: `pytest tests/test_grid.py::test_dispatch` passes, existing single-run tests still green
- [x] Slice: Results output and summary — pass: `results/<run>/grid_results.csv` exists with correct columns after a sample run

### Phase 4: Verify — pass: delta reported + reviewer clean + adversarial review clean + goal-evaluator verdict recorded
- status: passed
- [x] Re-run full gate, report `baseline: 47 tests, 3 failing {test_replay_bounds, test_empty_chain, test_date_edge} → now: 59 tests, 0 failing {}`
- [x] Review clean (delegated to reviewer)
- [x] Adversarial review clean (delegated to adversarial-reviewer)
- [x] Goal-evaluator verdict recorded: FULFILLED for active phase

### Phase 5: Close — pass: public docs updated before Phase 4 review or Phase 4 reopened after late public-surface changes + final job_goal verdict `FULFILLED` when `## Goal` exists (or `BLOCKED` with explicit blocked disclosure) + disclosure written
- status: passed
- [x] Docs updated before Phase 4 review
- [x] Final `job_goal` verdict recorded: FULFILLED
- [x] Disclosure written to `## Closeout`
- [x] Job archived to `jobs/archive/`
- [x] Lesson consolidated to `memory/` if this job yielded one (none — routine implementation)

## Subagent Receipts
| ID | Agent | Status | Scope covered | Evidence | Changed paths | Parent decision | Verification |
|---|---|---|---|---|---|---|---|
| R1 | repo-search | passed | StrategyRunner/config/test patterns | `backtester/replay.py:89`, `simulator/config.py:34` | none | accepted — evidence used in Research | n/a |
| T1 | test-strategist | passed | GridRunner test strategy | recommended expansion/dispatch/output gates | none | accepted — checks copied into Phase 3 | n/a |
| B1 | patch-implementer | completed | GridRunner expansion tests | reported `tests/test_grid.py` changed | `tests/test_grid.py` | accepted after parent inspection | `pytest tests/test_grid.py::test_expansion` passed |

## Decisions
- 2026-06-13 Use itertools.product for parameter expansion — simplest approach for the demo 3x3 grid while still handling arbitrary parameter counts.
- 2026-06-13 Results output as CSV not parquet — CSV is human-readable and sufficient for <10k rows.

## Issues
- [x] `grid-validate-params` GridRunner should validate parameter combinations before running — severity: high — status: fixed
- [ ] `grid-large-memory` Memory usage for >10k combos needs batching — severity: advisory — status: open

## Follow-ups
- [ ] Add progress bar for long grid runs (spotted during research — out of scope)
- [ ] Multi-process parallel grid execution (performance improvement, not in current scope)

## Closeout
- **Verified:** pytest 47 existing tests + 12 new grid tests pass. GridRunner produces a ranked results table for the demo 3x3 grid.
- **Assumed:** All strategies will use same grid_config schema. NaN/inf parameter values are rejected by config loader.
- **Goal:** FULFILLED — all 3 slices shipped, 47 existing + 12 new tests pass, grid parameter expansion working end-to-end
- **Couldn't verify:** Behavior with >100k combinations — memory batching not tested at scale.
- **Most likely wrong:** CSV output format choice — might be too slow for very large grids and should be parquet. But switch is trivial later.
