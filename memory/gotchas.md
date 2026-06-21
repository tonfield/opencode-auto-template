# OpenCode Auto gotchas

Recurring pitfalls, invariants, and change-impact warnings for this config repo.

## Template AGENTS.md can become active instructions
- Symptom: Reading files under `project/` can cause OpenCode to load `project/AGENTS.md` as an additional instruction file.
- Why it happens: OpenCode discovers `AGENTS.md` files by path, and this repo intentionally ships a project template that includes `project/AGENTS.md`.
- What to check: When editing or reviewing files under `project/`, remember that placeholder template content may appear as system context.
- Safe practice: Treat `project/AGENTS.md` as template data unless the task is explicitly about the downstream project skeleton. Keep its content aligned with the system this repo is trying to build.
- Related: `project/AGENTS.md`, `project/memory/README.md`

## Job-file tracking differs between this repo and generated projects
- Symptom: Guidance can look contradictory because root `.gitignore` ignores `jobs/`, while `/init` recommends unignoring `jobs/*.md`.
- Why it happens: This config repo keeps its own Auto work records local, but downstream project repos often need job files committed as shared project state.
- What to check: Root `.gitignore`, `commands/init.md`, README project-template docs, and any job-file policy wording.
- Safe practice: Say “this config repo's `jobs/` is local” when describing root behavior; say “project repos may track `jobs/*.md`” when describing `/init` output.
- Related: `.gitignore`, `commands/init.md`, `README.md`, `memory/decisions.md#dec-0001--keep-config-repo-job-files-local`

## npm install can warn even when audit passes
- Symptom: `npm install` may warn that `opencode-snip@1.6.1` requires Node `^24` when run on older Node versions, and may report an unapproved install script for `msgpackr-extract`.
- Why it happens: `opencode-snip` publishes a stricter engine range than this local Node 22 environment, and npm's script-approval mechanism tracks packages with install scripts.
- What to check: Run `npm install` and `npm audit --omit=dev --audit-level=moderate`; inspect whether warnings are engine/script-approval warnings or actual vulnerabilities.
- Safe practice: Treat `found 0 vulnerabilities` as the audit gate. Use Node 24 for warning-free installs, and only approve install scripts deliberately after reviewing the package need.
- Related: `package.json`, `package-lock.json`, `opencode-snip`, `msgpackr-extract`

## Counting errors in self-described honest taxonomies
- Symptom: A decision record or job file that stakes its credibility on "honestly documenting" a limitation gets the count wrong — overstating what's enforced and understating what's model-dependent.
- Why it happens: When enumerating a taxonomy (e.g., "N items, X enforced, Y model-dependent"), it's easy to conflate a related-but-separate item (like review agents) as a member of the enumerated set (like the critical-thinking moves), while orphaning a real member. Self-review reads the sentence for tone, not arithmetic.
- What to check: After writing any "X of N are A, Y are B" claim, re-count by listing each member and its category explicitly. Ask: is every member accounted for? Is any non-member being counted?
- Safe practice: Write the enumeration as an explicit member→category list in the source notes, even if the prose compresses it. Run adversarial review on any honesty-claim decision record — it catches arithmetic self-review misses.
- Related: `memory/decisions.md` (DEC-0006), `jobs/archive/critical-thinking-system.md`

## grep honors .gitignore — job-file sync claims must scope the path
- Symptom: A `[verified]` claim that "zero stale references remain" across all files is false when the file being verified lives under a gitignored path (e.g., `jobs/`).
- Why it happens: The `grep` tool (ripgrep-based) honors `.gitignore` by default. In this repo, root `.gitignore` ignores `jobs/`, so any repo-root grep silently skips every job file — including the one the verification claim lives in.
- What to check: When verifying "zero stale references" or "full surface sync" across files that include gitignored paths, run the grep with `--no-ignore` (via `rg --no-ignore`) or scope the path explicitly to the gitignored directory.
- Safe practice: Never scope a sync-verification grep to the repo root alone when the surface includes `jobs/`. Always add a separate `rg --no-ignore jobs/` pass, or read the job file directly.
- Related: `.gitignore`, `jobs/`, `memory/decisions.md#dec-0006`

## Surface-sync gates must cover all shared wording, not just headline naming
- Symptom: A "surface sync" verification gate passes (e.g., "three moves" naming consistent across all files), but a deeper shared phrase drifts on one surface (e.g., the guardrail drops the "abstraction" axis in the README, or a policy pointer keeps the narrow wording after the canonical section is broadened).
- Why it happens: Sync gates tend to check the headline label ("three moves," "§Simplicity") because that's the easy thing to grep. But surfaces share multiple phrases — the move enumeration, the guardrail wording, the cross-links — and a gate scoped to the headline misses drift in the others. Broadening the canonical text in one file (after a review finding) without re-syncing the others compounds it.
- What to check: When a sync gate claims "consistent across N files," list the specific shared phrases to compare (headline naming, guardrail axes, cross-link targets), not just the headline. After broadening any load-bearing wording in the canonical file, immediately check every surface that restates it.
- Safe practice: Write the sync gate as an explicit phrase-list, not a single-label check. Treat guardrail wording as load-bearing — it's the defense against the job's own stated failure mode, so drift there is higher-stakes than naming drift.
- Related: `memory/decisions.md#dec-0007`, `jobs/archive/simplicity-lens.md`

## Sync-grep scoping has dimensions beyond gitignore — path subtree, case, and slashless restatement
- Symptom: A "zero stale references" verification claim is false because the grep missed a restatement in a load-bearing path subtree (e.g. `project/` template files, `agents/`), or missed a capitalized variant (e.g. "Append-only" against a lowercase `append-only` pattern), or missed a slashless folder-name restatement (e.g. "docs skeleton" against a `docs/` path pattern).
- Why it happens: ripgrep is case-sensitive by default. The verifier mentally scopes to "the files I just edited" and forgets sibling surfaces that restate the policy — especially the `project/` template subtree, which is load-bearing because README tells users to `cp -r project/* .` into new projects, so stale template policy is inherited verbatim downstream. Sentence-initial capitalization then hides the match from a lowercase pattern, and a restatement that drops the trailing slash ("docs skeleton") escapes a path-pattern grep that keys on the slash.
- What to check: For any "zero stale references" claim, run the grep case-insensitively (`rg -i`), with `--no-ignore` if `jobs/` is in scope, explicitly enumerate every load-bearing subtree (`agents/`, `project/`, `templates/`, `commands/`, `memory/`), and grep the slashless form of any renamed folder name (e.g. "docs skeleton", "docs folder") alongside the slashed form.
- Safe practice: When a policy changes in a canonical file, list every surface that restates it — including `project/**` templates — before claiming sync. Run the sync grep as `rg -i --no-ignore` and include all subtrees. Treat the `project/` template subtree as first-class: it becomes real projects via `cp`.
- Related: `project/memory/decisions.md`, `.gitignore`, `memory/decisions.md`, `memory/gotchas.md` (#5 grep-honors-gitignore, #6 surface-sync-phrase-scope)

## Traceability links break when the linked file moves after the link is written
- Symptom: A provenance or cross-reference link is written to a job's current path, then the job is moved during closeout, leaving the link stale before anyone reads it.
- Why it happens: The link is created from the file's current lifecycle state instead of its stable final state. For closeout provenance, `jobs/<slug>.md` is temporary once archive-on-closeout exists; `jobs/archive/<slug>.md` is the durable target.
- What to check: Any time a job writes a `Consolidated to:` or `Source:` line, check whether either endpoint will be moved later in the same closeout flow. If yes, verify the link points at the final path, not the pre-move path.
- Safe practice: Archive first, then consolidate. If the link must be computed before the move, compute it from the stable final destination. Treat write-then-move ordering as a stale-link risk even when it reads naturally in prose.
- Source: `jobs/archive/foundations.md`
- Related: `agents/auto.md` Step 8, `memory/decisions.md#dec-0008`, `jobs/archive/foundations.md`
