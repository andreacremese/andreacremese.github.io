---
title: "MCP vs Terminal Calls – Feb 2026"
subtitle: "Which is better for your context?"
date: 2026-02-16
layout: default
description: "MCPs were the flavor of the month, but is context preservation better with MCP or just letting your agent use the terminal?"
---


# Fast-Moving Patterns: MCP vs Terminal Calls

*A lightweight, time-stamped snapshot of a moving target.*

AI tooling is evolving at breakneck speed. This post is a quick, opinionated take on a question that’s come up a lot lately: should your agent use an MCP server, or just call tools via the terminal? MCPs were all the rage in 2025, but is the hype justified? Here’s what I’ve learned so far—and why this might all be outdated in a few months.


## Table of Contents

- [Why MCPs Aren’t Always the Answer](#why-mcps-arent-always-the-answer)
- [Context is King: Why Less is More](#context-is-king-why-less-is-more)
- [APIs vs. Conversations: A Mismatch?](#apis-vs-conversations-a-mismatch)
- [CLIs: Built for Humans and Agents](#clis-built-for-humans-and-agents)
- [Real-World Benchmarks: What the Data Says](#real-world-benchmarks-what-the-data-says)
- [Advice for Tool Builders and Developers](#advice-for-tool-builders-and-developers)
- [The Bottom Line: This Will Be Outdated Soon—And That’s Okay](#the-bottom-line-this-will-be-outdated-soonand-thats-okay)
- [References](#references)


## Why MCPs Aren’t Always the Answer

I’ll admit it: I’ve never been a fan of MCPs. Maybe it’s because I like to see what my agent is doing in the terminal, or maybe it’s my inner minimalist.

> The only thing that doesn’t break on the race car is what you **don’t** put on the race car.

So, unless I really need an MCP ... why add it?

In a chat with a machine learning practitioner, I heard: “MCPs are very context hungry.” That got me curious, I know that context bloating is a very pernicious issue. I dug into some papers and ran a few experiments. Here’s where I landed.


## Context is King: Why Less is More

LLMs only get so many tokens per request—the “context window.” Every extra bit you send eats into that. MCPs are notorious for bloating context: they add lots of JSON, headers, and boilerplate that the model has to process, even if you don’t use all of it.

Bottom line: the shorter your context, the better your LLM performs (and the less it hallucinates).

**Example:**
Browser automation via MCP (open a page, scrape, run JS) can eat up 7–9% of Claude’s context window—just for the tool plumbing! ( from [What if you don't need MCP at all? 2025-11-02](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/))




## APIs vs. Conversations: A Mismatch?

MCPs are APIs: they are designed for machines talking to machines. That means lots of verbose JSON, headers, and structure. LLMs, on the other hand, are built for conversation. There’s a fundamental impedance mismatch: APIs are chatty, LLMs want things concise.

CLIs, by contrast, follow the Unix ethos: small, modular, composable. They have human readable (conversational) docs. They’re easy for both humans and LLMs to use.

**Example:**
Want a list of your repositories? An MCP gives you a big JSON blob. With a CLI, you just pipe to jq and you’re done. No extra round-trips.


## CLIs: Built for Humans and Agents

MCPs are built for LLMs and agents—period. CLIs are built for both humans (in the terminal) and machines (in scripts, CI, etc.). They usually have more features and are more flexible out of the box.

**Example:**
In 2025, GitHub’s MCP couldn’t show full commits, but the CLI could. Even the big players can’t keep up with the CLI’s flexibility.



## Real-World Benchmarks: What the Data Says

[MCP vs CLI: Benchmarking Tools for Coding Agents 2025-08-15](https://mariozechner.at/posts/2025-08-15-mcp-vs-cli/) ran some head-to-head tests. When you control for functionality, API size, and docs, MCP and CLI are about even—though CLI can be a bit more expensive (likely due to extra security checks).

But that’s a best-case scenario. In reality, CLIs are usually smaller, more composable, and more human-friendly. You can pipe one CLI into another; MCPs just can’t compete there.


## Advice for Tool Builders and Developers

**For tool writers:**
Humans and LLMs both use CLIs. Only LLMs use MCPs. If you’re building tools, invest in a great CLI first—you can always layer an MCP on top later.

**For developers:**
If you need something often and there’s no CLI, write a small script in your favorite language, document it, and let your agent use it as needed. Don’t pay the “MCP context tax” if you don’t have to.

**The money quote:**
> Just like a lot of meetings could have been emails, a lot of MCPs could have been CLI invocations.
[MCP vs CLI: Benchmarking Tools for Coding Agents 2025-08-15](https://mariozechner.at/posts/2025-08-15-mcp-vs-cli/)



## The Bottom Line: This Will Be Outdated Soon—And That’s Okay

This space is moving fast. What’s true today might be obsolete tomorrow. For now, CLIs are more flexible, composable, and context-friendly than MCPs. But keep an eye out—next month, the landscape could change again.

## References
- [MCP vs CLI: Benchmarking Tools for Coding Agents 2025-08-15](https://mariozechner.at/posts/2025-08-15-mcp-vs-cli/)
- [What if you don't need MCP at all? 2025-11-02](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/)
- [Why I Went From REST APIs to MCPs to CLIs and Ended Up with Self-Improving AI 2025-09-12](https://wonderwhy-er.medium.com/why-i-went-from-rest-apis-to-mcps-to-clis-and-ended-up-with-self-improving-ai-8b492631f565)