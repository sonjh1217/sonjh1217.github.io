# Agentic Flywheel

This folder is a lightweight harness for iterative human-agent work.

The goal is not only to finish a task, but to capture what the iteration taught us and feed it back into the next run.

## Loop

1. Read the current memory before starting a substantial task.
1. Do the work.
1. Compare the first-pass output with the final accepted output.
1. Extract reusable lessons, not one-off edits.
1. Turn those lessons into recommendations.
1. Auto-apply low-risk recommendations to the harness.
1. Leave higher-risk recommendations in the backlog for later review.

## What Lives Here

- `memory/preferences.md`
  - stable user preferences
- `memory/domain-rules.md`
  - recurring rules for writing, coding, reviews, and other task types
- `memory/harness-rules.md`
  - rules for how the agent should review itself and improve the workflow
- `recommendations/backlog/`
  - recommendations that still need review or later scheduling
- `recommendations/applied/`
  - recommendations already folded into the harness
- `runs/`
  - private per-task working notes for reflection and scoring
- `templates/`
  - starter templates for runs and recommendations

## Public Repo Safety

If this repository is public:

1. Keep `memory/` focused on sanitized, reusable rules.
1. Keep `recommendations/applied/` generalized enough that they do not reveal private context.
1. Do not commit task-specific run logs with personal, company, or incident details.
1. Store detailed run notes locally under `runs/`, but keep them out of version control.

## Auto-Apply Policy

Recommendations may be auto-applied when all of the following are true:

1. The recommendation is low risk.
1. It is easy to reverse.
1. It improves repeated work, not only a single file.
1. It does not conflict with an explicit user instruction.

Otherwise, store it in `recommendations/backlog/`.

## Suggested Workflow

Before a substantial task:

1. Read `memory/preferences.md`.
1. Read the relevant parts of `memory/domain-rules.md`.
1. Read `memory/harness-rules.md`.

After a task with meaningful iteration:

1. Create a run folder with `bash tools/flywheel-init.sh <slug>`.
1. Fill in the run notes locally.
1. If a lesson is reusable, create a recommendation file.
1. If the recommendation is safe to auto-apply, update memory or `AGENTS.md` and move the recommendation to `recommendations/applied/`.

## Scope

This harness is repo-local so it can live in version control, but the structure is intentionally generic and can be copied into other repositories or promoted into a broader personal workflow later.
