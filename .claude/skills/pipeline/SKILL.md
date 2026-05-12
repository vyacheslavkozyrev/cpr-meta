---
description: Run all SDD phases automatically in sequence — analyze, plan, implement, review, test — with gate checks and context clears between each phase.
argument-hint: <feature-number>
---

You are the **Pipeline** orchestrator for the SDD framework.

Feature number: **$ARGUMENTS**

# Pipeline

Run SDD phases in sequence for feature `[####]`. Each phase is delegated to a **fresh sub-agent** so context is fully isolated between stages.

---

## Execution Rules

1. Before each phase: read `specifications/[####]-*/progress.md`.
2. **Skip** the phase if its row already shows ✅ Complete — move to the next one.
3. **Halt** if the preceding required phase is not ✅ Complete — notify the user which phase is missing.
4. **Delegate** each phase to a fresh agent (see _How to delegate_ below).
5. After the agent returns: **re-read** `progress.md` to verify the gate passed.
6. **Halt on gate failure** — report the reason and tell the user to fix it and re-run `/pipeline [####]`.

---

## How to Delegate a Phase

For each phase in sequence:

1. Read `.claude/skills/<phase>/SKILL.md` (e.g. `.claude/skills/analyze/SKILL.md`).
2. Replace every occurrence of `$ARGUMENTS` in the file content with the feature number (`[####]`).
3. Prepend the following line to the prompt **before** the SKILL.md content:
   > "The pipeline orchestrator has already verified the gate condition. **Skip Step 0** and proceed directly to Step 1."
4. Spawn a fresh agent:
   ```
   Agent(
     subagent_type: "general-purpose",
     description: "<Phase> phase for [####]",
     prompt: <gate-skip prefix + modified SKILL.md content>,
     model: <see Phase Table>
   )
   ```
5. After the agent completes, re-read `specifications/[####]-*/progress.md` and check the phase row.

---

## Phase Table

| # | Phase | SKILL.md path | Model | Human gate |
|---|-------|--------------|-------|------------|
| 0 | Specify | _(pre-condition — not automated)_ | — | Must be ✅ before pipeline starts |
| 1 | Analyze | `.claude/skills/analyze/SKILL.md` | `haiku` | None — halt if BLOCKED |
| 2 | Plan | `.claude/skills/plan/SKILL.md` | _(default)_ | **Pause** after agent — show plan.md, wait for user approval |
| 3 | Implement | `.claude/skills/implement/SKILL.md` | _(default)_ | None — halt if build fails |
| 4 | Review | `.claude/skills/review/SKILL.md` | _(default)_ | None — halt if score < 80 or Blockers |
| 5 | Test | `.claude/skills/test/SKILL.md` | _(default)_ | None — halt if any AC uncovered or test fails |

---

## Start Condition

Read `specifications/[####]-*/progress.md`.
If Specify is not ✅ Complete, stop immediately:
> "Pipeline cannot start: Specify is not complete. Run `/specify [####]` first."

---

## Plan Human Gate (Phase 2)

After the Plan agent completes and `progress.md` shows Plan ✅ Complete:

1. Read and display the full contents of `specifications/[####]-*/plan.md` to the user.
2. Ask:
   > "Plan complete. Please review the task list above and reply **approve** to continue to Implement, or describe any changes needed."
3. **Do not proceed to Implement until the user explicitly approves.** Incorporate any requested changes directly into `plan.md`, then confirm again.

---

## Completion

When all five phases are ✅ Complete:
> "Pipeline complete for [####]. Analyze ✅ Plan ✅ Implement ✅ Review ✅ Test ✅. Ready to merge."
