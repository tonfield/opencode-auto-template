---
description: Run an ephemeral review. With active job, persist findings to ## Issues.
---
Run a focused review using the reviewer subagent.

Accepted forms:
- `/review`
- `/review --files <path1> [<path2> ...]`
- `/review --topic "<topic>"`

Behavior:
1. Resolve the target:
   - Explicit `--files`: review those paths.
   - Explicit `--topic`: review that topic against current job context.
   - No flags, active job exists: review current git diff + touched files.
   - No flags, no job: ask for a target.
2. Invoke `reviewer` with:
   - mode context: "job"
   - target: resolved files, diff, or topic
   - supporting context: active job's `## Design` and `## Research` when relevant
   - risk profile: LOW/MEDIUM/HIGH, default MEDIUM
3. Return findings in chat.
4. If an active job exists and findings are actionable:
    - Upsert each material finding in job `## Issues` by the reviewer's stable match key: update the existing issue when the match key is already present; append only new match keys.
    - Preserve the reviewer's severity vocabulary:
       ```
       - [ ] `[match-key]` [summary] — severity: blocking|high|advisory|note — status: open
       ```
    - Do not update `## Progress` directly. Auto owns accepting/rejecting findings, applying fixes, and marking progress only after re-verification.
    - Do not update `## Delegation Plan`; Auto owns lane planning.
    - If the job uses `## Subagent Receipts`, Auto may record the accepted review result there after checking scope and acting on material findings.
5. Standalone reviews (no active job) stay in chat only.

Outcomes:
- `completed` — review ran and findings returned.
- `clarification-required` — target ambiguous or unparseable.
- `no-op` — no safe resolvable target.

Reviews never create review artifact files or mutate anything outside the job `## Issues` section.
