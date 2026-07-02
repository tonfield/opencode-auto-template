# OpenCode Auto decisions

Accepted project-level decisions. Reflect current truth — edit in place when a decision is refined; history is preserved in git (`git log -p memory/decisions.md`), so commit each substantive edit with a message summarizing the change. When a decision is created or refined from job closeout, include `Source: jobs/archive/<slug>.md`.

## DEC-0001 — Keep config-repo job files local
- Date: 2026-06-15
- Status: accepted
- Context: This repo is both an OpenCode configuration and a project template. Auto may create local job files while improving the config itself, but those job records are not part of the distributed template contract.
- Decision: Root `jobs/` in this config repo stays gitignored. Project repos initialized from `project/` may track `jobs/*.md` so job state can be shared with that project's team.
- Consequences: Keep root `.gitignore` scoped to this repo's `jobs/`; keep `/init` guidance that unignores Markdown job files in downstream project repos.
- Related: `.gitignore`, `commands/init.md`, `README.md`, `project/`

## DEC-0002 — Preserve allow-all primary-agent permissions
- Date: 2026-06-15
- Status: accepted
- Context: Auto is intended to be a proactive primary agent for trusted local development, and the current config grants broad tool access.
- Decision: Keep root `opencode.json` permissions broad (`allow`) for bash, edit/write, web, MCP, Morph, and external directories.
- Consequences: Safety must come from the protocol: rollback before destructive/outward actions, scoped job files, verification, review, and disclosure. Do not silently harden permissions without a new product decision.
- Related: `opencode.json`, `agents/auto.md`, `AGENTS.md`

## DEC-0003 — Use overrides for vulnerable transitive npm dependencies
- Date: 2026-06-15
- Status: accepted
- Context: `npm audit` reported vulnerabilities in `diff` through `@morphllm/morphsdk` and `uuid` through `node-notifier`, while the direct packages did not publish fixed versions.
- Decision: Preserve the notifier and Morph plugins, align `@opencode-ai/plugin` with the installed OpenCode version, and use npm `overrides` for `diff` and `uuid` so audit can pass without removing current behavior.
- Consequences: Re-test plugin startup after future upstream releases; remove overrides if direct dependencies publish compatible fixed versions.
- Related: `package.json`, `package-lock.json`, `opencode.json`

## DEC-0004 — Make adversarial review mandatory at verification boundaries
- Date: 2026-06-15
- Status: accepted
- Context: Risk-based adversarial review made the independent ground-truth check optional, but the protocol treats adversarial review as a primary way to verify completed work.
- Decision: Run `adversarial-reviewer` at the verification boundary for completed durable work on the default non-urgent path: job Phase 4 Verify and no-job durable-change closeout. Keep it available earlier on demand, but do not require it after every Build slice.
- Consequences: Quality is preserved by a mandatory independent review of integrated work, while Build slices stay lean with focused verification plus standard reviewer. Urgent incident work must record the skipped adversarial check in disclosure and follow up afterward when durable state changed.
- Related: `agents/auto.md`, `templates/job-template.md`, `README.md`, `project/SAMPLE-JOB.md`

## DEC-0005 — Make Auto an orchestration-first primary agent
- Date: 2026-06-16
- Status: accepted
- Context: Auto previously did most work itself while delegating specific searches, patches, and review gates. The intended operating model is now for Auto to keep the big-picture job state while subagents perform more bounded research, implementation, impact mapping, test strategy, and review work.
- Decision: Keep Auto as the only primary agent, but make it orchestration-first: it decomposes work into lanes, delegates safe lanes, records `## Delegation Plan` and `## Subagent Receipts` for non-trivial delegated work, and retains final authority over baselines, merge decisions, verification deltas, impact checks, and disclosure.
- Consequences: Read-only lanes may run in parallel. Write lanes remain serialized unless paths/contracts are provably disjoint and the job records why parallel writes are safe. Subagent output remains advisory until Auto verifies scope, evidence, and gates.
- Related: `agents/auto.md`, `agents/impact-mapper.md`, `agents/test-strategist.md`, `templates/job-template.md`, `README.md`

## DEC-0006 — Make critical thinking a named, structural part of the Auto cycle
- Date: 2026-06-21
- Status: accepted
- Context: Auto's autonomy framing was action-primary ("proceed autonomously," "act, don't over-deliberate," "never end on a promise"). Effective for momentum, but it under-leveraged the highest-value form of agent initiative: epistemic initiative — questioning premises, surfacing assumptions, steel-manning alternatives, pre-morteming before action. The system already had most of the critical-thinking machinery (claim tags §1.1, adversarial-reviewer, goal-evaluator, "model the other side" §1.9, backward revalidation) but lacked a unifying frame, prospective (pre-action) moves, and an explicit question-the-premise move. Research grounding: Paul-Elder framework (elements of thought + intellectual standards), Socratic questioning (six question types), Klein pre-mortem (prospective hindsight, ~30% improvement in reason identification, attacks overconfidence), and LLM self-reflection research (Reflexion; self-correction benchmarks) establishing that structure beats exhortation — models self-critique poorly when asked vaguely and well when given concrete moves.
- Decision: Add a `### Critical Thinking` section to `agents/auto.md` (placed before Step 0) defining four concrete moves — question the premise, surface uncertainty and trace claims, steel-man the opposite, pre-mortem non-trivial actions — woven into the existing 8-step cycle with no new sequential gates. Reframe Auto's initiative as thinking-primary, action-as-follow-through (opening paragraph + one clause in `description:`). Add `AGENTS.md §1.13` as a policy pointer. Add a Critical thinking row to the README behavior table and sharpen the Auto description line. Add an `Assumptions:` line to the job template `## Design`. Align the `project/AGENTS.md` template.
- Consequences: Two of the four moves are structurally enforced at their output layer (pre-mortem ↔ §1.6 rollback rule; surface-uncertainty-and-trace-claims ↔ §1.1 claim tags) and therefore reliable across models — though the merged move's prospective pre-Produce timing (naming assumptions early) is model-dependent; only the claim-tagging output is §1.1-enforced. Two moves (question the premise, steel-man) rely on model disposition and are model-dependent — high-value-when-applied but cannot be gated; this is an acknowledged limit, not a claim of universal effect. The review agents are a separate structural backstop, not one of the four moves. The four-move framing is a judgment-call compression of Paul-Elder + Socratic and is tunable. The 8-step cycle is unchanged; the moves run inside existing steps. "Question the premise" is scoped to non-trivial requests with an explicit simple-request escape hatch to avoid second-guessing every ask. Critical thinking that blocks all action is flagged as a failure mode ("procrastination with better branding").
- Related: `agents/auto.md`, `AGENTS.md`, `README.md`, `templates/job-template.md`, `project/AGENTS.md`, `memory/gotchas.md`

## DEC-0007 — Make simplicity a named, structural lens in the Auto cycle
- Date: 2026-06-21
- Status: accepted
- Context: Auto already carried simplicity seeds scattered across the cycle — "do direct work only when it is simpler" (opening), "collapse to one phase" for simple jobs (Phase Mechanics), "simplest thing that works" (Step 3 Produce), "match effort to the prize" (§1.5), "cheapest check that can falsify" (Step 4 Verify). They were ungathered, and the cycle lacked the concrete reflex that makes simplicity fire reliably: a stop-check ladder. Inspiration: the KISS principle broadly, and ponytail (DietrichGebert, MIT) specifically — a "lazy senior dev" decision ladder (YAGNI → stdlib → native platform → installed dependency → one line → minimum) benchmarked at ~54% less code at 100% safety (agentic, Haiku 4.5, n=4). Install-as-plugin was evaluated and rejected: ponytail is not npm-published, the opencode plugin requires a repo checkout, and it ships its own `AGENTS.md` that would shadow this repo's — a transitive plugin dependency is the wrong shape for a universal config repo installed downstream. The user specified the integration should be a way of thinking applied everywhere, not just code, and not merely a review-type tool.
- Decision: Add a `### Simplicity` section to `agents/auto.md` (after Critical Thinking, both under How You Work) defining three concrete moves — stop at the first rung that holds, prefer deletion and default over addition, match the effort to the work — woven into the existing 8-step cycle with no new gates, paired with an explicit "never simplify away" guardrail reconciling simplicity with verification/security/error-handling. Sharpen the Step 3 Produce line to cross-link the ladder. Add `AGENTS.md §1.14` as a policy pointer. Add a Simplicity row to the README behavior table. Extend the `project/AGENTS.md` template sentence. Adapt the ladder, rules, and guardrail from ponytail (attribution retained); do not replicate ponytail's product surface (intensity levels, commands, output-format enforcement) — users who want that install ponytail directly in their projects.
- Consequences: Simplicity is a lens, not a gate — the 8-step cycle is unchanged; the moves run inside existing steps (Step 0 Decompose, Step 3 Produce, Step 4 Verify). The ladder deliberately generalizes ponytail's 6 code-specific rungs (YAGNI → stdlib → platform → dependency → one-line → minimum) to 4 rungs (YAGNI → existing-solution → one-line → minimum) because the lens fires on all work types — architecture, plans, designs, explanations — not just code; the code-specific options are preserved as sequential stops within the "existing solution" rung (use the first that suffices), so code guidance is preserved. The broader "match effort to the work" move is model-dependent (it sharpens latent seeds but cannot be gated) — acknowledged honestly, mirroring DEC-0006's enforcement taxonomy. The primary failure mode — simplicity becoming a license to under-verify or under-document — is defused by the explicit guardrail (never simplify away verification, security, error handling, accessibility, or explicitly-requested work) and the cross-link to Step 4 Verify. This is an adaptation of ponytail's ruleset, not a copy; the benchmark validation does not transfer to this paraphrase. Users wanting ponytail's full runtime should install it directly. Paired with DEC-0006: critical thinking asks "are we right?", simplicity asks "is this the least that suffices?".
- Related: `agents/auto.md`, `AGENTS.md`, `README.md`, `project/AGENTS.md`, `jobs/archive/simplicity-lens.md`

## DEC-0008 — Ground the system in named philosophical foundations + formalize the memory architecture and learning loop
- Date: 2026-06-22
- Status: accepted
- Context: The critical-thinking (DEC-0006) and simplicity (DEC-0007) lenses were operationalized without naming the philosophical traditions they draw from. The user identified two gaps: (1) the system lacked a visible worldview explaining WHY it is shaped this way — "i would expect some kind of background philosophy there [in README]"; (2) the rename (job/memory/ structure) established the file structure but not the BEHAVIORS that drive it — `jobs/archive/` and `memory/` existed as folders but `agents/auto.md` closeout did not yet consolidate lessons to `memory/` or move completed jobs to `archive/`. Research (docs-research delegation, 14/14 attributions verified against primary sources) grounded the worldview in applied epistemology, with fallibilism (Peirce) as the deepest root, and surfaced 5 attribution corrections: PDCA is Shewhart's (1939), not Deming's (Deming preferred PDSA); the ~30% pre-mortem figure is Mitchell, Russo & Pennington (1989), which Klein cites; "CUDOS" is Ziman's (2000) framing, not Merton's 1942 label; the Lindy effect was named by Goldman (1964) and formalized by Taleb (2012); Baddeley's episodic buffer is a 2000 addition to the 1974 model.
- Decision: Add a `## Foundations` section to `README.md` (human-facing) naming the philosophical roots (three-layer table with corrected attributions), six commitments (pragmatism, falsificationism, bounded rationality, reflective practice, economy of thought, organized skepticism), and the memory architecture (4 cognitive systems → artifacts: working=jobs+TodoWrite, episodic=jobs/archive, semantic=memory/gotchas+decisions, procedural=auto.md). Keep the worldview OUT of the agent prompt — the CT + Simplicity lenses already encode it operationally, and README-only placement is consistent with the cognitive-systems model (worldview = semantic knowledge for humans; prompt = procedural for the agent) and the simplicity lens (prompt stays lean). Formalize two operational behaviors in `agents/auto.md` Step 8: (a) the learning loop — at closeout, ask whether the job yielded a reusable lesson and consolidate to `memory/gotchas.md` or `memory/decisions.md` with a provenance link; (b) archive-move — completed jobs move to `jobs/archive/` for filesystem-level status. Treat `jobs/archive/<slug>.md` as the stable identity (no separate Job-ID) and require a bidirectional provenance check before closeout is done. Add the 4-systems cognitive framing to the Cross-Session Knowledge section.
- Consequences: The worldview is explanatory (README), the behaviors are operational (auto.md) — this split is deliberate and consistent with the cognitive architecture. The learning loop makes the episodic→semantic transfer a defined step at closeout rather than ad-hoc; the provenance link makes it auditable because the closeout checklist verifies both directions resolve (`Source:` from memory to archived job, `Consolidated to:` from job to memory). The archive-move gives filesystem-level job status without an index file (drift-proof). The archived slug is the identity; a separate Job-ID remains unnecessary unless archived jobs must be renamed or referenced across repos. Attribution accuracy is practiced as well as preached — 3 of the 5 corrections appear in the roots table (Shewhart, Mitchell, Lindy); CUDOS appears in the attributions note; Baddeley's episodic buffer is context for the memory-architecture attribution, recorded here. The worldview is model-independent (documentation, not a prompt behavior); the two operational behaviors are reliable across models (explicit closeout steps, not disposition-dependent). The gap-analysis additions (Fallibilism root, antifragility→learning loop, satisficing→simplicity context, extended mind→file memory, Gall/Lindy→simplicity grounding, shoshin→beginner's mind) are folded into the roots table as context, not bolt-on lenses — per the user's "merge everything together as one."
- Source: `jobs/archive/foundations.md`; provenance-check refinement: `jobs/archive/provenance-closeout-check.md`
- Related: `README.md`, `agents/auto.md`, DEC-0006, DEC-0007

## DEC-0009 — Build inline by default; delegate for independence and breadth
- Date: 2026-07-02
- Status: accepted (refines DEC-0005)
- Context: DEC-0005 made Auto orchestration-first, including delegated implementation via `patch-implementer`. A cross-harness design pass (porting this protocol to Claude Code as `claude-auto`) surfaced the economics: subagents start cold and re-derive context the parent already holds, while the real value of delegation is (a) fresh-context gates that cannot inherit the author's blind spots and (b) parallel read-only breadth.
- Decision: Auto builds inline by default. Delegation is mandatory for the independence gates (reviewer, adversarial-reviewer, goal-evaluator) and default for read-only breadth (repo-search, docs-research, impact-mapper, test-strategist). A `patch-implementer` write lane is the exception for truly independent bounded edits, not the default posture.
- Consequences: Fewer cold-start round-trips on routine work; gates keep their full force. Auto remains the orchestrator and state owner per DEC-0005 — only the default posture for implementation labor changes.
- Related: `agents/auto.md`, `AGENTS.md`, DEC-0005

## DEC-0010 — Goal-evaluator gets scoped read access
- Date: 2026-07-02
- Status: accepted
- Context: The goal-evaluator was pure-model (all tools denied). A prior closeout recorded the cost: if the parent's evidence is incomplete or misleading, the evaluator has no recourse.
- Decision: Allow `read` only (grep/glob/list/bash/web stay denied), restricted by prompt to files the caller explicitly names — typically the job file, to check `## Goal` and `## Progress` against the claims.
- Consequences: The evaluator can catch a misleading evidence packet instead of rubber-stamping it, while the missing search tools keep it from drifting into code review.
- Related: `agents/goal-evaluator.md`, `agents/auto.md`

## DEC-0011 — Adversarial reviewer may run allowlisted git inspection
- Date: 2026-07-02
- Status: accepted
- Context: All subagents were bash-less by convention, so the ground-truth gate had to trust the author's pasted verification output. A full shell-capable verification-runner was deferred pending a safe-command design.
- Decision: Give `adversarial-reviewer` a pattern-scoped bash permission: `git diff/log/show/status` (plus `--no-pager` variants) allowed, everything else denied. Independently reproducing what actually changed is stronger evidence than trusting the author's summary; test suites and builds remain parent-run.
- Consequences: The strongest gate can inspect the real diff itself with no permission prompts and no mutation surface. The broader verification-runner (running test gates in a subagent) remains open — this covers only git inspection.
- Related: `agents/adversarial-reviewer.md`, `agents/auto.md`

## DEC-0012 — Offer deterministic gotchas loading in project setup
- Date: 2026-07-02
- Status: accepted
- Context: "Read `memory/gotchas.md` on session start" is an instruction the model must remember, and it does not survive compaction. OpenCode's `instructions` config field loads files deterministically.
- Decision: `/init` offers wiring `memory/gotchas.md` into the project-level `opencode.json` `instructions` array. This config repo's root `opencode.json` is not changed — its gotchas are about this repo, not about downstream projects.
- Consequences: Projects that opt in get pitfalls injected every session; gotchas files should stay short since they become a per-session context cost.
- Related: `commands/init.md`, `agents/auto.md`
