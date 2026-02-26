---
title: "An example of encapsulation in Go: Enums for Status Disclosure"
subtitle: "Applying encapsulation for packages, tales from the trenches"
date: 2026-02-18
layout: default
description: "Putting in practice encapsulation and logical ordering when designing an internal API"
permalink: /architectural/example-of-encapsulation-enums-in-golang.html
---

# An example of encapsulation in Go: Enums for Status Disclosure

## Introduction

I have been exploring in other pages the encapsulation and the logical ordering of packages. While helping a colleague redesign an API for a package, I encountered a scenario where applying these concepts really paid off, even though it meant adapting the patterns in the underlying language (Go).

This post examines:
- What interface hardening looks like in the reality of day-to-day team collaboration
- Why proper encapsulation matters for long-term maintainability
- How Go's type system can express information hiding principles through status enums

## TL;DR

- Encapsulated APIs reduce coordination costs and enable parallel team development, or parallel development within your team
- Expose outcomes, not implementation—consumers need status, not internals  
- Status enums provide compile-time safety while hiding design decisions
- Go's type system supports information hiding despite lacking native enums

## The Design Challenge

Consider a lunch service that must communicate three distinct outcomes to consumers for each user:
- Lunch prepared and ready
- Lunch skipped due to policy exemption
- Lunch skipped due to user absence

Additionally, the service may encounter failures when calling third-party systems—failures callers might want to retry.

The architectural question: How do we design an API that **encapsulates all lunch preparation logic** while **disclosing only the necessary status** to its internal consumers?

(this is not really the exact case, as I work almost completely on proprietary software, but this is the idea).

## Why This Matters: Business Impact

This API design directly impacts the three business outcomes Parnas identified:

**Changeability Cost Reduction**: When requirements change (new skip reasons, different preparation logic, policy updates), modifications stay within the service module. Consumer code remains stable, reducing the ripple effect Parnas warned against. In practical terms: a policy change doesn't require coordinated updates across multiple teams or services, it is just a PR localized in a single package, no one is the wiser.

**Independent Development Velocity**: Frontend teams can build UI flows knowing only the status outcomes. Backend teams can refactor internals confident the interface remains stable. This parallelizes work and eliminates coordination bottlenecks—the difference between sequential handoffs and true concurrent development.

**Comprehensibility**: New developers joining consumer teams need only understand three outcomes and standard error handling. They don't need to comprehend lunch preparation internals, policy engines, or third-party integrations—reducing cognitive load and onboarding time.

These aren't abstract benefits. They translate to: faster feature delivery, lower maintenance costs, and reduced coordination overhead that scales with team growth.

## Information Hiding in Practice

Following [Parnas's principles](on%20the%20criteria%20to%20be%20used%20in%20decoposing%20systems%20into%20modules.html), our lunch service should hide design decisions about:
- How lunch preparation works
- Where policy rules are checked
- Which third-party services are consulted
- Internal business logic and workflows

The service should expose only:
- Final status (what happened)
- Actionable errors (when retry is possible)

This encapsulation delivers three key benefits:

1. **Changeability**: Internal lunch logic can evolve without affecting consumers
2. **Independent Development**: Service internals and consumer code develop separately
3. **Comprehensibility**: Consumers understand outcomes without implementation details

## The Status Enum Pattern

Go's type system and error handling conventions provide natural mechanisms for information hiding. For our multi-state scenario with no data return, the most idiomatic pattern is using an enum-like structure (which isn't really a native Go construct, but works well here):

```go
type LunchStatus int

const (
    LunchStatusUnknown LunchStatus = iota  // Zero value = invalid
    LunchStatusPrepared
    LunchStatusSkippedPolicy
    LunchStatusSkippedAbsent
)

func(s *LunchService) CheckLunchStatusForUser(ctx context.Context, userID uuid.UUID) (LunchStatus, error)
```

```go
    // consumer
    res, err := lunchService.CheckLunchStatusForUser(ctx, userId)
    if err != nil {
        // this is where we handle errors (third-party failures, etc.)
        return err
    }
    switch res {
        case LunchStatusPrepared:
            // handle prepared lunch
        case LunchStatusSkippedPolicy:
            // handle policy exemption
        case LunchStatusSkippedAbsent:
            // handle absence
        case LunchStatusUnknown:
            // this should never occur (zero value returned with error)
            // note: go's zero values can be confusing here, but that's a topic
            // for defensive coding, not API design
    }
```
This design maintains a clear separation: the status enum communicates *what happened*, while the error communicates *what went wrong*.

## Why This Supports Information Hiding

### 1. The Hardened Interface

The API exposes three discrete states without revealing:
- How policies are evaluated
- Where absence data is stored
- How lunch generation works
- Which external services are called

Consumers receive sufficient information to act (prepared vs. skipped vs. error) without coupling to implementation details. This is the "hardened interface" that enables independent evolution.

### 2. Localizing Change

When business requirements change, modifications remain localized:

**Example: Adding a new skip reason** (dietary restrictions)
```go
const (
    LunchStatusUnknown LunchStatus = iota
    LunchStatusPrepared
    LunchStatusSkippedPolicy
    LunchStatusSkippedAbsent
    LunchStatusSkippedDietary  // New state, isolated change
)
```

Existing consumers using `switch` statements get compile-time safety—they'll detect the new state. Consumers only checking specific states remain unaffected.

**Example: Changing preparation logic**
Internal implementation changes require zero consumer modifications. The service might switch from synchronous to asynchronous preparation, change data sources, or add caching—all invisible to callers.

### 3. Supporting Independent Development

The clear interface contract enables parallel work:
- Service team refactors internal logic without coordinating with consumers
- Consumer teams build features knowing only status outcomes
- Testing mocks require only status values, not implementation knowledge

Teams coordinate through the interface, not implementation—exactly what Parnas prescribed.

## Alternative Patterns Considered

### Pattern A: Sentinel Errors
```go
func CheckLunchStatus(userID string) (*Lunch, error)

// Returns:
// - (&Lunch{}, nil) on success
// - (nil, ErrPolicySkip) on policy exemption
// - (nil, ErrAbsent) on absence
// - (nil, error) on failure
```

**Trade-off**: This treats "policy skip" and "absence" as error conditions when conceptually they're valid business outcomes. It conflates business states with failures, weakening the information hiding principle by overloading error semantics. I don't think that is a good trade off logically.

### Pattern B: Result Struct
```go
type LunchResult struct {
    Lunch      *Lunch
    SkipReason string
}

func CheckLunchStatus(userID string) (*LunchResult, error)
```

**Trade-offs**: 
- Appropriate when returning the `Lunch` object itself. However, when consumers don't need lunch details (only status), this exposes unnecessary implementation details, violating information hiding.
- The `SkipReason` string requires consumers to perform string matching (`if result.SkipReason == "policy_skip"`), which is error-prone and lacks compile-time safety. While making `SkipReason` an enum would address this, you'd essentially reinvent the status enum pattern while still carrying the unnecessary `Lunch` field.

## The Status Enum Advantage

The status enum pattern wins for this scenario because:

1. **Semantic Clarity**: States are business outcomes, not errors
2. **Compile-Time Safety**: Switch exhaustiveness checking catches missing cases
3. **Minimal Disclosure**: Consumers see only discrete outcomes, not internal data
4. **Evolution Path**: New states integrate cleanly without breaking consumers

**Caveat**: This pattern works when status is the primary information. If you need to return data (e.g., a `Lunch` object), combine the enum with the data—the status enum remains valuable for representing discrete outcomes alongside the returned value.

## Conclusion

Encapsulation operates at every level—from system architecture down to individual API design. This lunch service example demonstrates how Parnas's information hiding principles find practical expression in Go's type system.

The status enum pattern isn't just idiomatic Go—it's strategic architecture that reduces maintenance costs, enables team scalability, and positions the codebase for change. Small decisions compound: choosing the right return pattern today determines whether tomorrow's requirement changes take hours or weeks.

Parnas's 1971 principles remain our guide: hide decisions, expose contracts, optimize for change.
