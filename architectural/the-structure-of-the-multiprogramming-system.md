---
title: "The Structure of the Multiprogramming System"
subtitle: "Layered Abstractions and the Logical Ordering Principle"
date: 2026-02-09
layout: default
description: "Notes on layered abstractions, verification, and information hiding from Dijkstra's THE system."
permalink: /architectural/the-structure-of-the-multiprogramming-system.html
---

# The structure of the "THE" multiprogramming system

Some notes on Dijkstra's paper about layered abstractions and the logical ordering of system levels. [the paper lives at this link(last I checked =) )](https://dl.acm.org/doi/pdf/10.1145/800001.811672)

## TL;DR headlines

- Layer your system so each level depends only on the one below it.
- Make lower-level details **irrelevant** and **loose their identity** to upper levels.
- Verify each level independently, like unit tests with a small surface area.
- Put hardware-specific concerns (i/o in general) at the bottom so they do not leak upward.
- The payoff: lower cognitive load, better changeability, and fewer all-hands "why is prod on fire" meetings.

## The logical ordering idea

Dijkstra's core move is to organize a system as a hierarchy of levels (or layers). Each level provides a clean abstraction for the level above, and relies only on the level below. That ordering matters. The levels are not just stacked for show; the dependencies are intentionally one-way.

If level N depends on level N-1, you can reason about N without fully understanding how N-1 is implemented. In other words, a lower level can fade into the background once its contract is trusted. This is a big deal for both correctness and team scaling.

You can read it as a design principle: "Make what is in level N irrelevant for level N+1." The lower level loses its identity and disappears from the picture. This is not just poetic. It is a practical requirement for building systems people can actually change.

## Principles (and the business translation)

### Abstraction

The abstraction principle says the details of level N should not leak into level N+1. Example: storage details (level 0) should not show up in service logic (level 1). If a service needs to know the file system layout, the abstraction failed.

Business translation:

- Fewer incidents when you swap infrastructure.
- Better vendor optionality.
- More predictable delivery timelines.

Sample of this failure: AWS lamdas (and a lot of the serverless movement of the mid 2010, I may write a paper about that in the first place at some point as I don't think as an industry we have really learned fully, but I digress...)

### Separate verification

Each layer can be verified independently. Prove level N correct assuming level N-1 is correct, and you can build up confidence without trying to reason about the entire system at once.

Business translation:

- Faster QA cycles.
- Tests become more meaningful and less flaky.
- Reduced blast radius when a change goes wrong.

Also, this is why we use mocks for unit tests. It is not "cheating." It is the logical consequence of layered design. (Your test suite still needs integration coverage, but your unit tests stop feeling like a hostage situation.)

### Information hiding

Lower levels hide their internal decisions from upper levels. This is closely related to Parnas's information hiding principle, and it gives you flexibility to change internals without breaking consumers.

Business translation:

- Lower maintenance cost.
- Faster refactoring cycles.
- Fewer coordination meetings across teams.

### Put hardware concerns at the bottom

The paper uses unmaskable interrupts as an example. Those live in the lowest level. The point is not about interrupts per se; the point is: hardware-specific concerns should not bubble up into application logic. If a hardware detail leaks into a business workflow, you have locked your product to your current stack.

Business translation:

- Easier migrations.
- Fewer rewrites when infrastructure changes.
- Less platform friction for product teams.

## Why layered ordering matters (the human problem)

Layering is not only about code. Parans makes the point in his famous paper ["On the criteria to be used in decomposing systems into modules"](on%20the%20criteria%20to%20be%20used%20in%20decoposing%20systems%20into%20modules.html) that it is likely that the code that is compiled at the end is the same, but the importance of this is about people and cognition. Most engineers can hold one level of abstraction in their heads at a time (if like me, maybe 1/2 at a time). Fewer can juggle three at once without opening twelve browser tabs and a meditation app.

When the system is layered:

- You can onboard new engineers by teaching one level at a time.
- Teams can make progress without full-system context.
- Reviews become less about reading a novel and more about checking a contract.

When the system is not layered, every change is a cross-level archaeology dig. That is not a stable business plan. It is a stress test.

## Common failure modes (aka how layering gets sabotaged)

- **The "just this once" escape hatch.** One small shortcut turns into a pattern. Then suddenly level 2 depends on level 0 and everyone is debugging from the basement.
- **Shared databases across layers.** It feels fast until it is slow. Then it is slow forever, and teams are bound at the hips in a distributed monolith hell. Forever.
- **Cross-layer logging and metrics that leak internal structure.** People start to depend on internals. Observability becomes coupling.
- **Accidental utility layer.** A shared helpers layer can be fine, but a mega-layer used by all is a stealth dependency graph.

There is no perfect system. The goal is to treat exceptions as debt, not as a design style.

## Practical checklist

If you want to apply this tomorrow without a big rewrite, start here:

- Make a graph of the modules on your solution (mermaid is amazing for this). Start small, even just of the local modules. Are the arrows going in the right direction?
- List your current layers. If you cannot list them, you do not have them.
- Identify which layer leaks into the one above it.
- Add a contract for that boundary (API, interface, or protocol).
- Write tests at the boundary first.
- Move cross-layer concerns downward, not upward.

Keep it boring. Software layering is like flossing, not glamorous but spoendy when you don't do it.
Modularization like the bass player in a band: you only notice him/her when the groove doesn't work.

## Note on changeability (and the Parnas link)

See ["On the criteria to be used in decomposing systems into modules"](on%20the%20criteria%20to%20be%20used%20in%20decoposing%20systems%20into%20modules.html) for an expansion on changeability. A hierarchical system is a necessary but not sufficient condition for modularity. You can stack levels and still build a brittle system if the levels do not hide decisions or if every layer reaches around the one below it.

The key idea is to not design a system as a flow chart. Flow charts encode execution order; layers encode responsibility boundaries. That is a different kind of design commitment, and it pays long-term dividends.
