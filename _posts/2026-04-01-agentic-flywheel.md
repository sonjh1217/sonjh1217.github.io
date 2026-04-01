---
title: "Building an Agentic Flywheel"

categories:
  - AI
  - Workflow
tags:
  - Agent
  - Harness
  - Workflow
  - FeedbackLoop
---

I have been thinking a lot about what kind of environment makes AI agents improve over time instead of just producing one-off outputs.

More specifically, I wanted to build an environment that could support what Kief Morris calls *the agentic flywheel*.

The framing that helped me most came from Kief Morris's article, [Humans and Agents in Software Engineering Loops](https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html). In that piece, he argues that the interesting work is not only asking agents to produce artifacts, but building the harness around them and improving that harness over time.

The line that stuck with me most was the idea that for each step of the workflow, the agent should review the result and recommend improvements to the harness that produced it. That turns a normal workflow into a system that can improve itself.

## From iteration to flywheel

A lot of agent usage still looks like this:

1. Ask for a result.
1. Review it.
1. Request fixes.
1. Finish the task.

That can work, but most of the learning from the iteration disappears. The output gets better, yet the workflow that created it stays mostly the same.

The flywheel starts when we treat user feedback as input not only for the artifact, but also for the harness.

```text
+---------------------------+
| Task                      |
+---------------------------+
             |
             v
+---------------------------+
| Agent produces first pass |
+---------------------------+
             |
             v
+---------------------------+
| Human reviews result      |
+---------------------------+
             |
             v
+---------------------------+
| Iteration improves output |
+---------------------------+
             |
             v
+-----------------------------+
| Extract reusable lessons    |
+-----------------------------+
             |
             v
+---------------------------+
| Create recommendation     |
+---------------------------+
             |
             v
+-----------------------------+
| Update harness or backlog   |
+-----------------------------+
             |
             v
+--------------------------------------+
| Next task starts with better defaults |
+--------------------------------------+
```

Instead of asking only, "How do I fix this draft?", the more useful question becomes, "What should change upstream so the next draft starts closer to the right answer?"

## Humans on the loop

The article distinguishes between humans *in* the loop and humans *on* the loop ([Martin Fowler](https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html)). That distinction feels important.

When humans are *in* the loop, we inspect outputs and correct them directly.

When humans are *on* the loop, we improve the harness:

1. prompts
1. quality checks
1. memory
1. templates
1. evaluation steps
1. automation rules

That shift matters because repeated work usually fails in repeated ways. If the same issue appears again and again, directly editing the artifact is only a local fix. Updating the harness is the scalable fix.

## What I wanted

I wanted an environment with a few properties:

1. It should preserve stable preferences instead of rediscovering them each time.
1. It should distinguish one-off edits from reusable lessons.
1. It should record recommendations in a structured way.
1. It should allow low-risk improvements to be applied automatically.
1. It should leave higher-risk improvements in a backlog.

In other words, I did not want a smarter prompt only. I wanted a feedback system that could gradually create an agentic flywheel.

## The harness I set up

I built a small repo-local harness with four layers to make that flywheel concrete:

```text
+------------------+
| Task execution   |
+------------------+
         |
         v
+-------------------------------+      +----------------------------------+
| flywheel-status.sh            |----->| current memory                   |
| reads current memory          |      | - memory/preferences.md          |
+-------------------------------+      | - memory/domain-rules.md         |
         |                              | - memory/harness-rules.md        |
         v                              +----------------------------------+
+--------------------------+
| flywheel-init.sh <slug>  |
| creates run template     |
+--------------------------+
         |
         v
+------------------+
| Run record       |
+------------------+
         |
         v
+------------------+
| Recommendations  |
+------------------+
      /       \
     v         v
+----------------------+   +------------------+
| Applied improvements |   | Backlog          |
+----------------------+   +------------------+
           |
           v
+---------------------------+
| Memory and AGENTS rules   |
+---------------------------+
           |
           v
+----------------------+
| Next task execution  |
+----------------------+
```

### 1. Memory

The harness starts with memory files:

1. `preferences.md`
1. `domain-rules.md`
1. `harness-rules.md`

These are meant to capture things like:

1. language preference
1. source-link style
1. rules for public incident writeups
1. rules for how the agent should reflect after iteration

### 2. Run records

Each substantial task can create a run note that answers:

1. What was the task?
1. What did the first pass do?
1. What feedback changed the result?
1. Which changes are reusable?

This matters because reflection works better when it is tied to a concrete task rather than vague memory.

### 3. Recommendations

Reusable lessons become recommendation files with fields such as:

1. trigger
1. problem
1. proposed change
1. benefit
1. risk
1. reversibility

That structure is important because not every lesson should be auto-applied.

### 4. Auto-apply versus backlog

If a recommendation is low risk, easy to reverse, and clearly useful across future tasks, it can be applied directly to memory or workflow rules.

If not, it should stay in a backlog for later review.

That is the part that starts to look like a real agentic flywheel instead of a pile of notes.

## Two helper scripts I use

To keep the loop lightweight, I added two small scripts:

1. `tools/flywheel-status.sh`
1. `tools/flywheel-init.sh`

`tools/flywheel-status.sh` prints the current preferences, domain rules, harness rules, and backlog recommendation file list. I use it before substantial tasks so the agent starts with current defaults.

`tools/flywheel-init.sh <slug>` creates a new run folder with the run template. In public repositories, I keep run details local only and avoid committing task-specific notes.

## A small real example

I saw the value of this immediately while drafting a public incident writeup.

The task itself was simple: write a sanitized blog post about a Universal Link login issue related to AASA.

But the iteration revealed reusable lessons:

1. the post should be in English
1. public incident naming should avoid overclaiming the root cause
1. source links should sit inline with the claims they support

Those are not just edits to one post. They are harness improvements.

So instead of fixing the post and moving on, I recorded them in memory and recommendation files. That means the next similar task can start closer to the desired result.

## Why this is better than just "prompt harder"

There is a temptation to solve everything by writing a more detailed prompt. Sometimes that helps, but a flywheel is different.

A prompt is static guidance.

A flywheel is a learning mechanism for improving the harness itself.

It creates a path like this:

1. produce
1. inspect
1. generalize
1. encode
1. reuse

Once that loop exists, the harness can slowly become more reliable without requiring humans to rediscover the same preferences every time.

## What I still would like to add

This is only a first version. The next steps I would want are:

1. scoring recommendations by benefit, risk, and frequency
1. automatically promoting some recommendations into memory
1. collecting recommendation history across repositories
1. adding periodic review so the harness does not just grow forever

That last part matters too. A harness should improve, but it should also stay legible.

## Closing thought

The most interesting part of working with agents may not be the artifacts they generate. It may be the environments we build around them.

If an agent can help produce code, text, tests, or documentation, that is useful.

If it can also help improve the workflow that produces those things, that is much more powerful.

That is the direction I want: not only agents that do tasks, but systems that learn from the way those tasks are corrected.
