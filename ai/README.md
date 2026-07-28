---
title: "AI for  thinking developers"
layout: default
description: "How to use AI for software development"
permalink: /ai/
---

# AI for thikning developers

Welcome! This is a quick collection of AI ideas and readings for developers. The field is moving fast—so treat everything here as a snapshot, not gospel.

_Inspired by Melanie Mitchell’s “AI for Thinking Humans.”_


## Pages 

### [Your Agent Experience Feels Like a Videogame? Design It Like One – Jul 2026](fsm_for_ai_experiences.html)
When your agent experience outgrows its DAG, finite state machines — borrowed from game design — offer a simpler model: current phase + event = outcome

### [MCP vs CLI: Stop Wrapping APIs, Start Offering Expertise – Jul 2026](mcp_vs_cli_2026.html)
New benchmarks, an evolved take — CLIs win on cost and composability, but MCPs become valuable when they embed domain expertise rather than just wrapping your API

### [Transformer Architecture: The Ultra Basics – May 2026](transformer_ultra_basics.html)
A starter guide to the transformer architecture — enough to get the shape of vectorial spaces, embeddings, attention, MLP, and the encoder/decoder split

### [MCP vs Terminal Calls – Feb 2026](mcp%20vs%20terminal%20for%20tool%20calls.html)
Context, composability, and design tradeoffs for AI tool calls

*Key insights: Why CLIs are more flexible and context-friendly than MCPs, practical advice for tool builders and developers, and why this space is evolving fast*

---

Check back soon—new papers and ideas are always popping up. If you have thoughts or questions, I’d love to hear from you!

## How I work with AI (as of Feb 2026)

Quick snapshot of my current workflow:

- claude (or anything on command line), with its setup symlinked so I can version control it.
- tmux to multiplex the terminal, have multiple chats, separate vim and the chat.
- git worktrees to work on multiple branches concurrently
- Usually one chat, one subject. Some skills, but not going crazy there.
- **CLIs over MCP** (for development): More flexible, better context. [My thinking has evolved](mcp_vs_cli_2026.html) — CLIs still win for dev workflows, but MCPs earn their place when they embed real expertise
- **Role prompts at the outset of a chat**: Start each chat with "assume the role of..." — keeps it focused and cuts down hallucinations (tip from a Google training)
- stk to keep track of the discussion https://github.com/andreacremese/stk
- **Small steps**: Iterate, commit often. Makes it easy to roll back when things go sideways
- **Stack your TODOs**: Keep a running list of concerns the AI surfaces. Explore depth-first. use [stk as a tool](https://github.com/andreacremese/stk)


