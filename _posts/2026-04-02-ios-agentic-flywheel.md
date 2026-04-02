---
title: "Designing an Agentic Flywheel for iOS Development"

categories:
  - iOS
  - AI
  - Workflow
tags:
  - iOS
  - Agent
  - Harness
  - TDD
  - Quality
---

My previous post about the agentic flywheel was intentionally generic.

This one is the follow-up: how I would design an **iOS-development-specific** flywheel.

The framing still comes from Kief Morris's article, [Humans and Agents in Software Engineering Loops](https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html), especially these points:

1. Harness = the collection of specifications, quality checks, and workflow guidance.
1. The loop improves only if agents can evaluate performance and failure scenarios.
1. For each workflow step, the agent should review results and recommend harness improvements.
1. Recommendations should be scored by risk, cost, and benefit, and low-risk/high-value ones can be auto-applied.

## Why a domain-specific flywheel?

A generic flywheel is useful, but iOS development has domain-specific constraints:

1. Figma-level state accuracy matters, not only functional behavior.
1. Logging requirements are product requirements, not optional implementation details.
1. Team conventions (architecture, event handling, logging format, UI framework rules) matter for maintainability.
1. TDD loop quality and static checks affect long-term velocity.

If the harness does not encode these constraints, the agent can still produce code, but the loop quality will be unstable.

## Human workflow I am mapping

In my real workflow, development can be summarized as:

1. Estimation
1. Design
1. Implementation

Before coding starts, PM shares task context (PRD + design/Figma). Then:

1. Estimation is split by stage:
   - design
   - implementation
   - integration with backend/other iOS developers
   - developer self-test (requirement checks, design QA, logging QA)
1. Design artifacts are created and reviewed:
   - feature flow charts, including A/B branches if needed
   - API flow and handling flow
   - request/response/path contract details
1. Implementation proceeds in small requirement-level TDD commits and small PRs.
1. Final checks include UI parity with Figma, logging requirements, and developer self-test.

## Recasting this as AI workflow commands

I would encode the same flow into three AI-first commands:

1. `/estimation`
1. `/design`
1. `/implementation`

And I would treat each as a measurable loop step, not just content generation.

```text
+-------------------+
| /estimation       |
+-------------------+
          |
          v
+-------------------+
| /design           |
+-------------------+
          |
          v
+-------------------+
| /implementation   |
+-------------------+
          |
          v
+-------------------+
| loop review       |
| + harness update  |
+-------------------+
          |
          v
+-------------------+
| next task         |
+-------------------+
```

## Step 1: `/estimation`

Input:

1. PRD
1. Figma
1. integration constraints
1. team rules

Output:

1. MD estimate by stage:
   - design
   - implementation
   - integration
   - developer self-test
1. explicit assumptions
1. risk flags

Quality checks:

1. Did the estimate include all stages?
1. Are assumptions explicit and testable?
1. Are dependencies called out early?

Harness improvement examples:

1. If estimates repeatedly miss design QA effort, update estimation rubric.
1. If integration effort is underestimated, add stronger dependency prompts.

## Step 2: `/design`

This step should produce both design artifacts and executable test intent.

Output bundle:

1. Functional flow chart (including A/B branches when relevant)
1. API contract spec (path, params, request/response, edge cases)
1. Test cases in Given/When/Then, grouped by screen and feature
1. Snapshot-style UI expectations for Figma states
1. Logging test cases ("when X happens, Y log is sent")
1. Additional engineering safety behavior (for example, error alert behavior)

I treat this as the key bridge from product intent to implementation.

```text
+-------------------------+
| /design                 |
| PRD + Figma             |
| + logging requirement   |
| + QA TC                 |
+-------------------------+
       /                 \
      v                   v
+-------------------------+   +-------------------------+
| Design artifacts        |   | Test-case package       |
| - flow charts           |   | - requirement TC        |
| - API contracts         |   | - design snapshot TC    |
+-------------------------+   | - logging TC            |
                              | - safety/edge-case TC   |
                              +-------------------------+
```

Quality checks:

1. Can all requirements map to at least one test case?
1. Are UI states in Figma mapped to testable snapshot expectations?
1. Are logging requirements represented as test cases?
1. Are critical negative/error scenarios included?

Harness improvement examples:

1. If a requirement repeatedly escapes to implementation without a test case, tighten design output schema.
1. If logging regressions repeat, promote logging TCs to a required section.

## Step 3: `/implementation`

The implementation skill should consume design test cases and execute a strict TDD loop.

TDD loop per requirement-level unit:

1. write test case
1. confirm failure
1. implement
1. confirm pass
1. run quality checks before commit

Quality checks should include:

1. a static-rules gate before commit
1. lint/format checks
1. code coverage checks
1. globalization checks (localized strings, layout safety for longer text)
1. team-enforced style/architecture checks (for example, SwiftUI requirement for new views, MVVM, event handling style, logging style)

```text
+-------------------------+
| implementation unit     |
| (small requirement)     |
+-------------------------+
            |
            v
      [TDD micro-loop]
   test fail -> implement -> test pass
            |
            v
+-------------------------+
| pre-commit checks       |
| static rules gate       |
| - lint/format           |
| - coverage              |
| - globalization         |
| - team style/arch       |
+-------------------------+
            |
            v
+-------------------------+
| small commit / small PR |
+-------------------------+
```

Harness improvement examples:

1. If lint failures recur, strengthen implementation prompts and pre-commit check gating.
1. If generated code repeatedly deviates from team style, add explicit templates or pattern references.
1. If certain rules are always violated, convert them from guidance to hard checks.

## What "giving agents information to evaluate the loop" means in iOS

For iOS work, this usually means giving the agent:

1. task specs (PRD, acceptance criteria, dependencies)
1. UI truth (Figma states and behavior)
1. quality truth (lint/static rules/architecture conventions)
1. observability truth (logging requirements)
1. test truth (required failure scenarios and expected behavior)

Without these, the agent can generate output but cannot reliably evaluate loop performance.

## Scoring recommendations and auto-applying harness updates

After each step, recommendations can be scored:

1. risk
1. cost
1. benefit
1. recurrence frequency
1. reversibility

Then use policy gates:

1. Low risk + high recurrence + low cost + reversible -> auto-apply
1. Medium risk or unclear impact -> backlog + human approval
1. High risk or architecture-impacting -> manual review required

This is how the flywheel stays safe while still getting faster.

## Practical questions I expect

### What if PRD misses important cases?

This is critical, and it is exactly why the design step must output a structured test-case package and why a human must review it carefully.

The key review question is:

1. "If these screen-by-screen and feature-by-feature TCs are implemented and combined, will the feature be correct?"

If the answer is no, the next action is to resolve the missing input, not to guess:

1. missing logging requirement -> request it explicitly
1. missing PRD behavior -> ask PO/PM and clarify
1. unclear edge-case behavior -> add explicit test cases before implementation

The harness side should also improve: the design skill should actively flag likely missing inputs and unresolved assumptions to the developer.

### What if QA TC or logging requirements arrive late during implementation?

Use an incremental loop:

1. continue with available inputs
1. when new QA TC/logging requirements arrive, run additional `/design` and `/implementation` loops for the delta

This is not fundamentally different from human development. The loop should support iterative updates instead of assuming perfect upfront inputs.

### What about small bug fixes or tiny features?

The same workflow still applies, just at smaller scope.

1. Run `/design` with a concise problem statement.
1. Generate and review the resulting TCs.
1. Implement via the same TDD + static-rules gate loop.

I do not want hard constraints like "must provide a Jira ticket." The skill should represent a workflow stage, not a rigid input format. It should evolve with context.

## Practical example of loop improvement

If `/implementation` repeatedly fails static checks:

1. detect failure pattern
1. propose harness change
   - strengthen prompt constraints
   - add missing template
   - move a soft rule into hard gate
1. score recommendation
1. auto-apply if policy threshold is met
1. verify next task passes the same check

That is the flywheel in practice: not only fixing code, but improving the system that generates code.

## Closing

My goal is not to remove humans.

My goal is to move humans from repetitive correction work to harness engineering work.

For iOS development, that means encoding estimation rules, design-to-test conversion, TDD execution, and static quality gates into a loop that can measure itself and improve itself task after task.
