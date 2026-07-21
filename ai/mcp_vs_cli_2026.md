---
title: "MCP vs CLI: Stop Wrapping APIs, Start Offering Expertise"
subtitle: "New benchmarks, same debate — but the real answer isn't which to pick"
date: 2026-07-21
layout: default
description: "The MCP vs CLI debate is still raging in 2026. New evaluation data shows they solve different problems. MCP servers as thin API wrappers don't hold up to CLIs, but MCPs can add value doing something CLIs can't: composing those APIs with domain expertise."
---

# MCP vs CLI: Stop Wrapping APIs, Start Offering Expertise


## Why This Keeps Coming Up

It's summer 2026, and "should I use an MCP or a CLI?" or "should we publish an MCP" is still one of the most common questions I hear from engineers building with agents. I [wrote about this in February](/ai/mcp%20vs%20terminal%20for%20tool%20calls) and came down firmly on the CLI side — less context bloat, more composability, wider user base. Six months later, new evaluation-based research landed that made me revisit that take. Not because I was wrong (like all authors on the internet, I am never wrong...) — but because I was asking the wrong question.


## The Wrong Question

The framing "MCP vs CLI" assumes you're picking one tool for all jobs. That's like asking "hammer or screwdriver?" — it tells you more about the person asking than about the problem. The real question isn't which is better in the abstract. It's: what does your user need, what do you need, and what does the task demand?

MCPs and CLIs serve different constituencies, different interaction models, and different cost profiles. Comparing them head-to-head made sense when MCPs were new and everyone was reaching for them by default. Now that the dust has settled, the interesting question is when each one earns its place — and what makes an MCP valuable (spoiler: it's not being a thin wrapper around your API and competing with a CLI).


## What the Benchmarks Showed

A recent evaluation ([video](https://youtu.be/CfITzVcUkZA?si=KObLkwL1a50izHDD)) ran a head-to-head test using GitHub as the benchmark — a repo with real issues to solve. Four arms: the GitHub MCP, the `gh` CLI with a large skill file, the CLI with a small skill file, and a vanilla agent with no tools configured. Each was evaluated on correctness, output quality, latency, cost, and tool fidelity (how often the agent actually used the tools it was given).

The headline: all four setups solved the problems within reason. Correctness and quality were comparable across the board. The difference was cost — the MCP arm was an order of magnitude more expensive. In one case, the MCP agent wrote the returned JSON to disk, only to parse it with `grep`. The model was fighting the tool, not leveraging it.

I'd encourage you to watch the full video for the detailed methodology and results if you have the time — it's rather interesting.


## Three Things the Data Reveals

**The benchmark tips the scale toward CLI.** GitHub has one of the most popular CLIs in existence. The model's training data is saturated with `gh` examples — it already knows the output formats, the flags, the piping patterns. It can compose commands confidently without trial and error. For any tool with that level of adoption, a CLI will outperform an MCP simply because the model has seen it before. The MCP agent even reached for CLI patterns when it wasn't supposed to.

**MCP is a curated menu, not a toolbox.** When a task slotted cleanly into a single MCP call, performance was competitive. The moment the agent needed to compose multiple calls or handle an edge case outside the menu, it diverged. MCPs excel at the "happy path" — CLIs excel at the long tail.

**Skills didn't help much — for popular tools.** Because `gh` is so well-represented in training data, adding skill files barely moved the needle. The model already knew what to do. This won't generalize to less popular tools, but it's a useful reminder: don't over-engineer the scaffolding when the model already has the knowledge.


## The Real Design Question: Thin Wrapper vs. Expert Agent

Most MCPs today are thin wrappers around an API. They expose endpoints as tool calls, return raw JSON, and leave the consuming model or agent to figure out composition. I am proposing that this is the antipattern.

If your product already has a popular CLI — or even a well-documented API — a thin-wrapper MCP is competing on the CLI's turf with worse composability and higher cost. The MCP will lose that fight AND you will end up with just another translation server to babysit that pages your support team at 3 am on a Sunday.

The more interesting design is an MCP that hides an agent inside it. The idea is to have a specialized agent with deep expertise in your codebase and API access. Instead of exposing raw endpoints and hoping the calling model knows (or try and fail) how to compose them, you embed the composition knowledge *inside* the MCP. The calling agent says "do X," and the MCP-agent figures out the multi-step orchestration internally.

This flips the value proposition. The MCP is no longer a thinner, more expensive version of your CLI. It's a domain expert that happens to speak the MCP protocol. The cost per call goes up, but the cost per *solved problem* goes down — because the calling agent doesn't burn tokens fumbling through your API surface.

If you're building an MCP in 2026, that's the question to ask: am I exposing raw tools, or am I offering expertise?


## When to Use Which

### As a consumer — choosing your tools

**Use a CLI** when you're a developer working with agents. The model already knows popular CLIs, composition is free, and you stay in control of the orchestration. This is the default for power users.

**Use an MCP** when you're not a command-line power user, or when the OAuth 2.1 flow saves your team real friction. Accept the token cost as a trade-off for accessibility.

### As a producer — choosing what to build

**Publish a CLI** (or a well-documented API, e.g. GraphQL) if your product exposes APIs and your users are technical. The model's training data does the integration work for you. A well-documented CLI is the highest-leverage investment — it serves humans, agents, and CI/CD without extra plumbing. A well-documented CLI will probably serve your consumers better than skill files, too. Their agent may need to run your `--help` a couple of times, but that beats consuming a stale skill markdown file that drifts from reality.

**Publish an MCP** if it genuinely adds to your offering — meaning it embeds domain expertise that a raw CLI can't provide. E.g. it knows out of the gate how to orchestrate calls, pipe results to achieve an experience. If your MCP is just a thinner, less composable version of your API, you're building a translation server that nobody asked for.


_Note:_ the idea of an MCP that can orchestrate calls and knows your API is not a blank check to skip hardening your API. You still need to [build it in a way that offers experiences rather than raw data](/architectural/service-oriented-architecture-platform-building-and-yegges-rant). If anything, an expert-agent MCP requires *more* encapsulation to be effective — the agent inside it needs clean, composable building blocks to work with.


## References
- [MCP vs CLI: Benchmarking Tools for Coding Agents 2025-08-15](https://mariozechner.at/posts/2025-08-15-mcp-vs-cli/)
- [What if you don't need MCP at all? 2025-11-02](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/)
- [MCP vs CLI 2026 video](https://youtu.be/CfITzVcUkZA?si=KObLkwL1a50izHDD)
- [Previous post: MCP vs Terminal Calls – Feb 2026](/ai/mcp%20vs%20terminal%20for%20tool%20calls)
