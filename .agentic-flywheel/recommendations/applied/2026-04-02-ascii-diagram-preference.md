---
title: "Capture box-style ASCII diagram preference"
status: "applied"
applies_to: "blog_writing"
change_type: "memory"
benefit: "medium"
risk: "low"
reversible: true
---

## Trigger

- During explanatory blog writing, a reusable preference emerged for simpler diagram formatting.

## Problem

- The first draft used Mermaid even though a lighter diagram style was preferred for explanatory blog posts.

## Recommendation

- Store a default preference for box-style ASCII diagrams in blog posts unless Mermaid is explicitly requested.
- Treat reusable presentation-format feedback as something that should be recorded automatically after the task.

## Expected Benefit

- Future explanatory posts will start closer to the user's preferred visual style.
- The harness will miss fewer reusable formatting preferences.

## Auto-Apply Decision

- Auto-applied because the preference was explicit, low risk, easy to reverse, and likely to recur.
