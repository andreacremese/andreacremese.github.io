---
title: "Serviceability Checklist for Startup Microservices"
subtitle: "Application-Level Readiness Patterns That Reduce MTTR and Change Failure Rate"
date: 2026-03-16
layout: default
description: "A soft checklist of serviceability patterns for production readiness—application code plus runtime integration checks"
permalink: /architectural/serviceability-checklist.html
---

# Serviceability Checklist for Startup Microservices
*Application-Level Readiness Patterns That Reduce MTTR and Change Failure Rate*

## Introduction

I was recently asked, after writing a bit of code in a POC microservice, for a checklist of "serviceability aspects I would check before deploying this code into production."

That is a fantastically large question, one for which Google has a profession dedicated to it (see Launch Coordinator Engineering). Nonetheless, I wanted to develop a starting point for areas I look at when an MVP starts taking traffic from internal or external customers.

## TL;DR

- **First principle**: Operational pain compounds silently until it doesn't. Production readiness costs less at design time than at runtime—the cost curve peaks after GA.
- **Scope**: Application code plus mandatory runtime integration checks (the gray area between SRE and developers)
- **Outcome**: Lower MTTR, reduced change failure rate, and fewer 2am pages from preventable failures. All the things you get from Accelerate-the-book.
- **This is a soft checklist**: Context matters. I use this as a starting point, not a compliance document. One question to ask: which parts of production readiness cost less than production forgiveness?

## Why This Matters: Operational Pain Compounds

From the Accelerate book and DORA framework, we know high-performing teams optimize four metrics: Deployment Frequency, Lead Time for Changes, Mean Time to Restore (MTTR), and Change Failure Rate.

The instinct is to trade speed for stability or vice versa. DORA research shows this is a false choice. High performers optimize both simultaneously through operational discipline baked into the application layer.

**Operational pain compounds silently until it doesn't.**

Here's some examples of what happens when these patterns are missing:

- **Without startup health checks**: containers join the fleet broken, serve bad traffic, increase MTTR (debugging "why is this pod broken?" instead of "pod failed readiness, roll back")
- **Without observability**: every incident becomes archaeology—hours correlating logs instead of minutes tracing requests (and MTTD means someone has to tap you on the shoulder "hey your stuff's borked")
- **Without retry logic**: transient network blips become cascade failures
- **Without API contract stability**: breaking changes slip through, emergency cross-team patches, deployment velocity drops

The mechanisms in this checklist directly reduce MTTR and change failure rate.

## Scope: Application Plus Runtime Integration

This paper focuses on what goes inside the container/code and how it interacts with critical runtime dependencies. This is application code plus the mandatory runtime integration checks that often fall into the gray area between SRE and developers—and frequently go unnoticed until they fail in production.

**An example of what's excluded**:
- DevOps organization and team structure
- CI/CD pipeline speed and health
- Branching strategy (trunk-based vs. short-lived branches)
- Infrastructure as Code and dashboard repeatability
- Incident review processes (hopefully blameless)
- Alerting strategy and on-call setup
- Backups, archives, encryption, security, data at rest
- Runtime performance analysis (profiling, load testing)

These things are still important, but outside this paper's scope.

## The Checklist: Serviceability Patterns

This is a soft checklist, not a gate. Every context is different—a three-person startup has different constraints than a post-Series-B company. Use these as prompts, not requirements.

### Data Integrity and Migrations

**Problem**: Old data with new code breaks silently in production.

**Heuristics**:
- Migrations in code, run automatically in the pipeline
- Container only bootstraps if migrations match expected version (fail-fast if database is behind)
- For risky migrations: either test old data with new code in CI, OR separate DDL and code changes into sequential deploys

**Why this matters**: Migration failures caught at startup mean MTTR measured in seconds (rollback), not hours (data archaeology).

---

### API Contract Stability as an Operational Constraint

**Problem**: Once in production, your API contract is operationally sticky. Breaking changes cascade, if possible at all.

**Heuristics**:
- Generate contracts from source of truth (OpenAPI from code, GraphQL introspection, protobuf definitions)—never hand-maintained
- PR/build fails on contract drift, possibly have notifications when contracts change (I had that in Slack once, it was pretty decent, tied us to the rail in a good way)
- Breaking changes require explicit versioning and migration window

**Good practice**: Schema generation in CI catches drift before production  
**Bad sign**: "We have a bunch of Postman collections to manage our services, you can rely on those to shape your consuming API"

**Why this matters**: Contract drift caught in CI reduces change failure rate. Discovered in production, it becomes a multi-team coordination fire drill.

---


### Startup Health Checks and Fail-Fast Behavior

**Problem**: Containers that join the fleet in a broken state (but with succeeding healthchecks) serve bad traffic before anyone notices, and may leave your cluster with no healthy consumers.

**Heuristics**:
- Main function checks critical dependencies at startup: database (`SELECT 1`), cache, secrets manager, required env vars. Panic if can't execute.
- Fail-fast if any critical dependency is unhealthy—prevent the container from joining the fleet
- Only serve traffic after successful initialization

**Why this matters**: Broken pods that never serve traffic mean MTTR is zero. Broken pods that serve bad traffic mean debugging user-reported issues.

**Bonus point** have the healthcheck actually do something across the critical infrastructure (SELECT 1 against the database? poll the cache? This is tricky as you may end up with no containers, so makes one really think about the minimum services we absolutely need to proceed).

---

### Connection Pooling and Singleton Clients

**Problem**: Creating database connections or HTTP clients per-request kills performance and exhausts connection pools.

**Heuristics**:
- HTTP clients, database clients, and I/O handlers are singletons created at bootstrap
- One connection pool per service, configured once, reused across requests
- Never instantiate clients inside request handlers or loops

**Why this matters**: Connection exhaustion under load looks like a deployment failure, increasing change failure rate for safe code changes.

--- 

### Retry Logic and Backpressure

**Problem**: Transient network issues or downstream service blips become cascading failures.

**Heuristics**:
- Clients have retry logic with exponential backoff built in
- Log failures with full context (retries attempted, final error, request metadata)
- For task handlers: bound parallelism to prevent thundering herd (use semaphores or worker pools)

**Why this matters**: Retries with backoff mean transient failures self-heal. Without them, every network hiccup becomes a page.

---

### Concurrency Boundaries and Timeouts

**Problem**: Unbounded goroutines/threads/async tasks create resource exhaustion and indefinite hangs.

**Heuristics**:
- Limit concurrent operations (semaphores, worker pools, or language-specific mechanisms)
- Every concurrent operation gets a timeout via context/cancellation
- Example in Go: use `errgroup` with `SetLimit()` and pass timeout contexts, not blank contexts

```golang
g, ctx := errgroup.WithContext(ctx)
g.SetLimit(10)  // Max 10 concurrent
for _, q := range queries {
    g.Go(func() error {
        ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
        defer cancel()
        // do work with bounded time
    })
}
```

**Why this matters**: Unbounded concurrency means "the service is slow" becomes "the service is dead" under load.

---

### Observability: Logs and Telemetry

**Problem**: Engineers disagree wildly on what to log. Without a baseline, debugging is guesswork.

**Heuristics**:
- Log when things go unexpectedly (errors, retries, fallback paths, panics)
- Include enough context to debug without reproducing (request IDs, user IDs, operation metadata)
- Set-and-forget middleware on every operation: log duration, basic params, exit status

**Why this matters**: Good logs mean MTTR measured in minutes (find the bad request, trace the path). Poor logs mean MTTR measured in hours (try to reproduce, add logging, redeploy, wait for it to happen again).

**Bonus point** don't log synchronously, as a failure in logging causes a failure for the user. Don't log against the same service as the user's traffic, it is a very good way to get self DDOS'd.

## Why This Pays Off

Services with good serviceability patterns compound velocity over time. The gap between well-instrumented and poorly-instrumented services widens with each deploy, each incident, each new team member who needs debugging context. In quarter one, the difference might be invisible. By quarter four, one team ships confidently on Fridays while the other treats every deploy like defusing a bomb.

This isn't about perfection, it's about making trade offs knowing when you are making one. I.e. if you decide to forego one of these, knowing that you'll need to fix it later. It's about buying operational forgiveness as cheap as you can at design time instead of expensively after GA (and probably at 2am after PagerDuty got you).

## What to Do Monday Morning

- Pick 2-3 patterns from this list that your service is missing
- Add them to your PR review checklist or production readiness template
- For existing services: add observability first (you can't improve what you can't measure)
- For new services: start with startup health checks and fail-fast behavior
- Revisit this list quarterly as your service and team mature

