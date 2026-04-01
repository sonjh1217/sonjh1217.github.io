# Harness Rules

These rules describe how the workflow should improve itself.

## Reflection

- After meaningful iteration, capture what changed because of feedback.
- Separate local edits from reusable lessons.
- Prefer small, composable recommendations over large abstract advice.
- If the user changes presentation format, diagram style, citation style, or wording style in a reusable way, record that preference by default unless it is clearly one-off.
- In public repositories, do not keep detailed run logs or sensitive task history under version control.
- When recording applied recommendations in a public repository, generalize the trigger so it captures the reusable lesson without exposing private context.

## Recommendation Quality

Each recommendation should answer:

1. What triggered the recommendation?
1. What upstream change would have prevented or reduced the iteration?
1. What future tasks does it apply to?
1. Is it safe to auto-apply?

## Upstream Targets

Recommendations should improve one of these, in this order:

1. `memory/preferences.md`
1. `memory/domain-rules.md`
1. `AGENTS.md`
1. templates in `.agentic-flywheel/templates/`
1. scripts in `tools/`

## Auto-Approval Guardrails

- Auto-apply only when the change is low risk and easy to reverse.
- Do not auto-apply changes that alter security, credentials, destructive actions, or major product behavior.
- If the user explicitly expresses a stable preference, prefer applying it immediately and recording it as an applied recommendation.
