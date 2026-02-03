---
title: "On the Criteria to be Used in Decomposing Systems into Modules"
subtitle: "Parnas's Timeless Principles for Software Architects and Business Leaders"
date: 2026-02-02
layout: default
description: "How David Parnas's 1971 insights on system modularization remain essential for modern software architecture and business strategy"
---

# On the Criteria to be Used in Decomposing Systems into Modules
*Parnas's Timeless Principles remain relevant for Software Architects as well as Business leaders*

## Table of Contents
- [Executive Summary](#executive-summary)
- [Introduction: Why This Paper Matters](#introduction-why-this-paper-matters)
- [The Paper's Core Insight](#the-papers-core-insight-a-business-framework-disguised-as-technical-theory)
- [Strategic Implications for Modern Architecture](#strategic-implications-for-modern-architecture)
- [Practical Implementation Framework](#practical-implementation-framework)
- [Lessons for Senior Architects](#lessons-for-senior-architects)
- [The Enduring Relevance](#the-enduring-relevance)
- [Conclusion: Architecture as Business Strategy](#conclusion-architecture-as-business-strategy)
- [References and Further Reading](#references-and-further-reading)

## Executive Summary

David Parnas's 1971 paper "On the criteria to be used in decomposing systems into modules" remains one of the most commercially relevant computer science papers ever written. While academia discusses it as foundational theory, practicing architects recognize it as a business optimization framework disguised as a technical treatise.

This analysis explores why Parnas's modularization principles are not just engineering best practices, but strategic business decisions that directly impact market velocity, operational costs, and competitive advantage.

## Introduction: Why This Paper Matters

Decades after publication, Parnas's work continues to surface in every significant architectural decision we make. The paper's enduring relevance stems from its focus on three business-critical outcomes: **independent development**, **changeability**, and **comprehensibility**—each directly translating to bottom-line impact.

**Independent development** enables team scalability and parallel execution, directly affecting time-to-market. In today's environment where engineering talent costs $150K-$400K annually, the ability to parallelize development work is not just a technical advantage—it's a competitive necessity.

**Changeability** addresses the well-documented reality that software maintenance typically consumes 2-3x the initial development cost over a system's lifetime (with some studies suggesting maintenance costs 4-10x initial development depending on system longevity and complexity). When your product's technical debt service begins exceeding new feature velocity, Parnas's principles become survival tools rather than academic concepts.

**Comprehensibility** tackles cognitive load, which directly correlates to defect rates, onboarding time, and incident resolution speed. In an era where production incidents can cost enterprises millions per hour, reducing system complexity becomes a risk management strategy.



## The Paper's Core Insight: A Business Framework Disguised as Technical Theory

Parnas presents his analysis using the KWIC system (Key Word in Context - a text processing application) as a controlled experiment comparing two modularization approaches:

**Modularization 1: The Flow-Chart Approach**
- Design follows data flow through processing steps
- Mirrors traditional waterfall thinking
- Optimizes for initial development speed

**Modularization 2: Information Hiding**
- Each module encapsulates design decisions
- Exposes minimal interfaces to other components  
- Optimizes for long-term adaptability

The genius of Parnas's approach lies in demonstrating that both modularizations can produce functionally identical systems, yet yield drastically different business outcomes.

### Changeability: The Hidden Cost Center

Parnas's analysis reveals that flow-chart modularization creates systemic coupling. 

This means that changes ripple across module boundaries, requiring coordinated updates throughout the system for bugs / updates / issues. In business terms, this has multiple permutations:

- **Higher change costs**: Simple feature requests require cross-team coordination
- **Increased time-to-market**: Changes must be planned and executed system-wide
- **Risk amplification**: Small changes carry high probability of introducing regressions

Information hiding modularization localizes changes to specific modules, dramatically reducing the blast radius of modifications. This architectural choice directly impacts:

- **Feature velocity**: New capabilities can be developed independently
- **A/B testing capability**: Different approaches can be implemented in parallel
- **Technical debt management**: Legacy components can be incrementally modernized

### Independent Development: The Scalability Multiplier

Flow-chart systems require upfront interface agreements across all modules, creating coordination bottlenecks that limit parallel development. This manifests in real organizations as:

- **Lengthy planning cycles**: All teams must align before implementation begins
- **Reduced autonomy**: Teams cannot make local optimizations without system-wide impact
- **Communication overhead**: Changes require extensive cross-team coordination

Information hiding enables what we now call "loosely coupled, highly cohesive" systems—the foundation of successful microservices architectures and autonomous team structures.


## Strategic Implications for Modern Architecture

### Parnas Predicted the Hardened Interface

Long before Stephen Yagge's famous rant about Amazon vs Google and "hardened interface" entered our vocabulary, Parnas identified the core tension between system decomposition strategies and their interplay with team composition (Conway would inform this later on as well). Successful platform engineering organizations implicitly follow information hiding principles:

- **Domain-driven design**: Services encapsulate business capabilities rather than technical functions
- **API-first development**: Interfaces abstract implementation details - hardened interfaces
- **Organizational alignment**: Team structures mirror system boundaries (Conway's Law)


### The ETL Anti-Pattern: When Flow-Chart Thinking Persists

Modern data engineering frequently falls into the flow-chart trap Parnas identified. Traditional ETL pipelines create exactly the systemic coupling he warned against:

- **Brittle dependencies**: Schema changes ripple through entire pipeline
- **Debugging complexity**: Data quality issues require understanding the entire flow  
- **Deployment coordination**: Pipeline updates require careful orchestration

Organizations adopting modern data mesh architectures unconsciously rediscover information hiding principles, treating data domains as encapsulated modules with published interfaces.

### The AI/LLM Development Paradox

Current AI system development presents fascinating parallels to Parnas's observations. Many LLM applications follow flow-chart patterns—passing state through complex graphs of prompts, tools, and decision points. The comprehensibility crisis emerges when these systems require debugging or modification, as complete understanding is required to make risky updates across the whole graph.

Advanced practitioners increasingly adopt modular approaches (standalone graphs, subgraphs, even standalone nodes that can be tested by themselves), encapsulating reasoning capabilities within specialized agents rather than monolithic prompt chains. This mirrors the information hiding principle: each agent maintains internal reasoning strategies while exposing clean interfaces to collaborators.

### Financial Impact: R&D vs. COGS Optimization

GAAP is not my subject, but from a financial operations perspective, Parnas's principles directly affect cost classification under GAAP accounting:

**Research & Development Costs** (typically not included in operating margin calculations):
- Initial system development
- New feature implementation
- Architecture refactoring

**Cost of Goods Sold** (directly impacts operating margins):
- Production maintenance
- Bug fixes and patches
- Performance optimization
- Security updates

Information hiding architectures do two things at the same time:

- shift costs from COGS to R&D by front-loading design complexity AND
- reduce COGS (ongoing maintenance burden). 

While this may not improve EBITDA directly, it significantly enhances operating margin performance—a metric closely watched by public company investors.


## The Enduring Relevance

Parnas's 1971 insights remain remarkably current because they address fundamental tensions in system design that transcend specific technologies. Whether dealing with monoliths vs. microservices, serverless architectures, or AI system design, the core trade-offs between initial complexity and long-term maintainability persist.

The most successful technology organizations treat Parnas's principles not as academic theory, but as practical business optimization tools. They understand that software architecture is ultimately about optimizing for human coordination at scale—exactly what Parnas identified over fifty years ago.

In an era where software capabilities increasingly determine business success, architects who master these principles position themselves as strategic business assets rather than technical resources. They become the leaders who can navigate the complex trade-offs between short-term delivery pressure and long-term competitive advantage.

## Conclusion: Architecture as Business Strategy

Parnas's paper teaches us that system architecture is never just a technical decision—it's a business strategy encoded in software. The decomposition choices we make today determine our organization's ability to respond to market changes, scale development capacity, and maintain competitive advantage tomorrow.

Modern architects must think beyond code structure to understand how technical decisions ripple through teams, processes, and ultimately business outcomes. Specifically, how technical decisions can lower or raise changeability (read, maintenance) cost.

The principles Parnas outlined in 1971 provide a timeless framework for making these strategic technical decisions. In a world of rapidly evolving technologies, his insights offer stability: focus on changeability, independent development, and comprehensibility, and the specific implementation details become tactical choices rather than strategic constraints.

---

## References and Further Reading

### Primary Source
- Parnas, D. L. (1972). "On the criteria to be used in decomposing systems into modules." *Communications of the ACM*, 15(12), 1053-1058. [DOI: 10.1145/361598.361623](https://dl.acm.org/doi/10.1145/361598.361623)

### Foundational Papers
- Conway, M. E. (1968). "How do committees invent?" *Datamation*.
- Dijkstra, E. W. (1968). "The structure of the 'THE'-multiprogramming system." *Communications of the ACM*.
- Rokas, J. (2025). "The true cost equation: Software development and maintenance costs explained." [Idealink Tech Blog](https://idealink.tech/blog/software-development-maintenance-true-cost-equation)
