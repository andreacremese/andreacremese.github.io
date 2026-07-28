---
title: "Your Agent Experience Feels Like a Videogame? Design It Like One"
subtitle: "Finite state machines for AI experiences that outgrew their DAG"
date: 2026-07-27
layout: default
description: "When your agent experience adds interrupts, clarifications, and retries, it stops being a DAG. Finite state machines — borrowed from game design — offer a simpler model: current phase + event = outcome. No path reconstruction, no combinatorial debugging."
---

# Your Agent Experience Feels Like a Videogame? Design It Like One


## The Wall

If you've built agent experiences for production-grade offerings with a graph-based framework — LangGraph, or anything that models steps as nodes and edges — you've probably had the same trajectory. The POC is chocolatey and smooth. Version one works beautifully. It's a DAG (a directed acyclic graph — fancy way of saying the flow goes forward and never loops back). Linear, debuggable, easy to reason about. Each node builds on the previous one.

Then product asks for a clarification step. Or you want to string together an experience that exists elsewhere in the offering (i.e. your mobile or web application) — porting logic that already serves your web or mobile app into your bot or agent flow, but that requires calling three different internal APIs, asking for clarifications in the middle, and handling some corner cases that currently the user would click or reason about. Then a retry on a flaky third-party API. Then a branch where the system asks the user a question before continuing.

Suddenly it's not a DAG anymore. And the code starts fighting you.

Here's what that looks like (as I may have seen in production): debugging means tracing through multiple files and multiple nodes to figure out how the shared state got into a particular shape. The answer isn't "what state is the user in — can we provide a way out?" — it's "what path did the user take to get here?" Those are very different questions, and the second one scales combinatorially — every node that can amend the state multiplies the paths you have to reason about.

This spills into how you talk about the experience with internal customers — waterfalls of path-dependent explanations rather than reasoning about a single state the user may be in.

Team velocity drops. Reasoning about the experience becomes a drag. And the final tell — the code gets so tangled that the only way to reason about it is to point an agent at it. If your production code requires an AI to understand it, something has gone wrong. (Paraphrased from Mitchell Hashimoto — but I'm a believer in "written by AI, understood by human" for the product you want to sell for money.)



## Why DAGs Break Down

A DAG works when every node can assume a clean contract: "I receive X, I produce Y, the next node takes it from here." That's the pipeline model, and it's elegant (or is it? more on this later). LangGraph and similar frameworks encourage this — you define nodes, you define edges, maybe even conditional edges (that take different roads depending on... the state). You pass state forward.

The problem is the shared state object. In most graph frameworks, there's a single state that flows through the graph. Every node can read it, every node can amend it. When the flow is linear, this is fine — you can trace exactly which node put what into state. But the moment you add branches, interrupts, or loops, that shared state becomes a bag that any of N nodes might have touched in any order.

Now imagine debugging: the user hit a clarification step, and the state looks wrong. Which node set that field? It depends on which branch the user came from. Did the retry node run before or after the validation node? Did the interrupt handler clean up after itself? You're no longer debugging a function — you're reconstructing a path through a graph. And your test matrix just went combinatorial.

The deeper issue is that DAGs encode *sequence*, not *situation*. They answer "what happens next?" but not "where are we?" When an experience is truly linear, these are the same question. The moment it isn't, they diverge — and the gap between them is where your team's velocity goes to die.

This isn't a new problem. Dijkstra warned decades ago against designing systems as flowcharts — [flowcharts encode execution order, not responsibility boundaries](/architectural/the-structure-of-the-multiprogramming-system). DAG-based agent frameworks repeat that mistake with a modern coat of paint.

Subgraphs help a little, as do split states, but at the end of the day this is a fundamental flaw in the approach for experiences that aren't linear.

## The FSM Insight

The fix isn't a better graph — it's a different model entirely. Treat non-linear experiences as finite state machines, like videogame developers do.

A note on terminology: "state" is overloaded here — it means both the data bag in the graph model and the current situation in an FSM. To keep things clear, I'll call the FSM's concept a **phase** — the discrete situation the user is currently in. The machine transitions between phases.

The core idea is simple: `(event, current_phase) → new_phase`. That's it. The system has a defined set of phases. When an event arrives, the machine looks at what phase it's currently in and what event just happened, and transitions to the next phase. Nothing else matters. Not which node ran before. Not which branch was taken. Not what the data looked like three steps ago.

### The Mario Explanation

FSMs are the bread and butter of game design — they've powered character behavior, animation systems, and game logic for decades. When I explained this pattern to audiences not familiar with FSMs, I reached for Mario.

In a Mario game, when you press "jump," what happens depends entirely on Mario's current phase — not on what happened before. If Mario is running right and you press jump, he goes diagonal up-right. If he's already in the air and you press jump, nothing happens. If he's standing still, he jumps straight up.

`(jump, running_right) → diagonal_up_right`
`(jump, in_the_air) → in_the_air`
`(jump, standing_still) → jumping_up`

There's no check on where Mario was thirty seconds ago. No trace-back through which platforms he visited. The game doesn't care how he got to "running right" — it only cares that he *is* running right, and that you pressed jump. Current phase + event = outcome.

That's the whole model. Replace "jump" with "user answered the clarification question" and "running right" with "waiting for email confirmation," and you have the same machine running your agent experience.

### Back to agent experiences

In most agent experiences, the event that triggers a transition is straightforward: the user answered a clarification question and you can continue. Sometimes it's an API response or a timeout, but the common case is "the user replied to our clarification."

This is a fundamentally different contract than the DAG model. In a DAG, the state accumulates history — every node leaves its fingerprints. In an FSM, the phase *is* the complete picture. If you know the current phase and the incoming event, you know the outcome. Full stop.

The key difference from the DAG model is ownership: the FSM is the single writer. Only the state machine itself mutates the phase data during a transition. No other part of the system touches it. Phases carry whatever data they need — the user's answers so far, API responses, intermediate results — but there's exactly one place that decides what goes in and what comes out.

The functions that do the actual work — calling APIs, prompting an LLM, validating inputs — don't mutate the FSM's phase data. That's the machine's job alone. They may call external APIs, but from the orchestration's perspective, they're pure: input in, result out. The state machine decides what to do with that output.

One might object: "you're just centralizing all the logic in one place." Not quite. The state machine owns *transitions and data* — the "where are we and where do we go next." The actual work lives in those pure functions, which are independently testable, independently debuggable, and blissfully unaware of the larger flow. The FSM is the orchestrator, not the doer.

The practical consequence: debugging goes from "reconstruct the path" to "inspect the phase." Your test matrix goes from combinatorial (every possible path) to linear (every possible phase × event pair). And when the user gets stuck? You don't need to figure out how they got there. You just need to know where they are.


## Why This Matters Beyond Code

The first feedback I got wasn't about performance or correctness — it was about readability. A colleague DM'd me (paraphrasing) about a PR where I'd used the FSM pattern for an agentic experience: "I just opened the PR and it's possible to read and make sense of what you're doing here." That's in contrast with PRs where achieving one piece of logic means touching three or four nodes, and following the path became really hard. That's not a compliment you usually get on agent orchestration code. (I'm also proud because that colleague is very sharp — well, like most of my colleagues really. External validation is always nice, no matter what we tell ourselves.)

Debugging got simpler immediately while porting an experience to this pattern. No agent needed to reason about the flow. A phase is inspectable — you look at it, you know where the user is, you know what can happen next. One data point, not a path reconstruction.

I think the benefits go further than code, though I haven't fully validated this yet as I am in the process of launching this at scale. When your system is modeled as phases, the conversation with product and EMs should change. Instead of walking through flowcharts — "the user goes here, then here, then if this happens they go there, but if they came from over here instead..." — you get: "What phase is the user in? What can happen from there?" That's a question anyone can engage with, no code knowledge required.

This is close to what Eric Evans called "ubiquitous language" in Domain-Driven Design: a shared vocabulary that means the same thing in code and in conversation. When your codebase literally has a `WaitingForEmailConfirmation` phase, and product asks "what happens if the user is stuck waiting for email confirmation?" — you're pointing at the same thing. No translation layer. I believe this will be the outcome, but I'll report back once we've fully shipped.



## When This Applies — and When It Doesn't

**Use an FSM when** your experience isn't a DAG anymore — when it has interrupts, clarification loops, retries, or branches where the next phase depends on external input. That input might be the user answering a question, or a third-party API telling you the item doesn't exist, or a validation check failing. The tell is when debugging starts requiring path reconstruction rather than state inspection.

**Stick with a DAG when** the flow is genuinely linear. If every step feeds cleanly into the next with no loops or interrupts, a pipeline is simpler and you don't need the extra machinery. Don't fix what isn't broken.

**This doesn't apply to** open-ended conversations. If the user can say anything at any time and the system needs to respond flexibly, you're in chatbot territory — not a structured experience. FSMs need a finite, enumerable set of phases. The moment your phase list becomes "whatever the user might say," you've lost the benefit.

**"Why not just use a deep agent?"** You could hand the whole orchestration to a capable model and let it figure out the steps. For developer tooling — where you're willing to wait 30 seconds for a good answer — that can work. But for a webapp or consumer product, that patience isn't afforded. Users expect sub-second responses, and an agent reasoning through your internal APIs on every interaction is both slower and more expensive than a state machine that already knows the valid transitions.

The heuristic: if you can draw your experience on a whiteboard as a finite set of boxes with arrows between them, and the arrows are labeled with events — you have an FSM. If the whiteboard turns into spaghetti where every box connects to every other box, you're either in DAG-that-should-be-an-FSM territory, or in open-ended-conversation territory. The fix is different for each.


## What's Next

There's more to say about the implementation — pure functions, typed results, how to structure the transition table in practice. That's a follow-up post. This one is about the *why* and the *when*.


## References
- [On the use of transition diagrams in the design of a user interface for an interactive computer system — Parnas](https://dl.acm.org/doi/10.1145/800195.805945)
- [Statecharts: A Visual Formalism for Complex Systems — Harel](https://www.state-machine.com/doc/Harel87.pdf)
- [The Structure of the "THE"-Multiprogramming System — Dijkstra](/architectural/the-structure-of-the-multiprogramming-system)
