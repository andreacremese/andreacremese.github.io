---
title: "Go Interfaces: Thoughts on Composition Over Inheritance"
subtitle: "Who should own the contract — the producer or the consumer?"
date: 2026-03-28
layout: default
description: "Go's implicit interface satisfaction is the deeper half of composition over inheritance. When to use consumer-defined vs producer-defined interfaces, and why it depends on the boundary."
permalink: /architectural/go-interfaces.html
---

# Go Interfaces: Thoughts on Composition Over Inheritance


## Introduction

One of the patterns in Object Oriented Programming to reuse code is inheritance. A design principle is "composition over inheritance", and there are quite a few videos about that for Go. Most of them focus on struct embedding. But looking at the code AI generates, and at the standard library, there are deeper considerations — a framing to decide "Who should own the contract — the producer or the consumer? And does it depend on context?"

## TL;DR
- Go supports two levels of composition: struct embedding (the familiar one) and implicit interface satisfaction (the one most posts skip).
- If your team's output is a service with a hardened API (REST, GraphQL): producer-defined interfaces will likely serve you better — the ergonomic cost of losing LSP navigability outweighs the modest coordination saving.
- If your team's output is a package that gets imported: export structs, let the consumer define the narrowest contract.
- In both cases we are chasing minimum coordination among teams to promote speed of execution.
- This is still valid in the era of AI code assistants.

## Background — struct embedding (the half every Go tutorial covers)

Go has no class inheritance. Instead, you embed one struct into another — "has-a" rather than "is-a":

```golang
type Auth struct{}

func (a *Auth) GetToken() string {
	return "a token"
}

type User struct {
	Name string
	Auth // embedded — User now has GetToken() for free
}

var u User
u.GetToken() // works, no super() call, no class hierarchy
```

This is well-covered elsewhere. But it's only half of Go's composition story.

## The two patterns, side by side

### Pattern A: Producer-defined interface (the OOP-flavored approach)
- The producer package exports an interface and an implementation. Maybe a mock too.
- The consumer imports that interface and codes against it.
- This is what AI code-completion tools generate. This is what engineers coming from Java/C# reach for.

```golang
// producer package
type Repository interface {
    GetByID(id string) (*Order, error)
    Save(order *Order) error
}

type postgresRepo struct { db *sql.DB } // unexported — consumers depend on the interface
func (r *postgresRepo) GetByID(id string) (*Order, error) { ... }
func (r *postgresRepo) Save(order *Order) error { ... }
```

```golang
// consumer package — imports the producer's interface
import "myapp/repository"

func NewService(repo repository.Repository) *Service { ... }
```

### Pattern B: Consumer-defined interface (the idiomatic Go approach)
- The producer exports a concrete type. No interface. No mock. Just the exported struct.
- The consumer declares a narrow interface — only the methods it actually consumes.
- If the concrete type satisfies it, implicit interface satisfaction handles the rest. No `implements`, no shared type.

```golang
// producer package — exports concrete type only
type PostgresRepo struct { db *sql.DB }
func (r *PostgresRepo) GetByID(id string) (*Order, error) { ... }
func (r *PostgresRepo) Save(order *Order) error { ... }
func (r *PostgresRepo) ListByCustomer(custID string) ([]*Order, error) { ... }
```

```golang
// consumer package — defines only what it needs
// its tests will mock only what it needs, and will not use anything from the producer package really.
type orderFetcher interface {
    GetByID(id string) (*Order, error)
}

func NewService(fetcher orderFetcher) *Service { ... }

// in the tests
type fetcherMock struct {}

func (fm *fetcherMock) GetByID(id string) (*Order, error) {
	// implement behavior as needed, in the consuming package
}

```

The consumer asks for one method out of three. Interface Segregation Principle for free.

Standard library examples (pinned to Go 1.26.1):
- [`io.Writer`](https://github.com/golang/go/blob/e87b10ea2a2c6c65b80c4374af42b9c02ac9fb20/src/io/io.go#L99) — one-method interface, used everywhere
- [`io.Copy`](https://github.com/golang/go/blob/e87b10ea2a2c6c65b80c4374af42b9c02ac9fb20/src/io/io.go#L387) — consumer that accepts `Writer` and `Reader`, regardless of implementation.
- [`net/http.Handler`](https://github.com/golang/go/blob/e87b10ea2a2c6c65b80c4374af42b9c02ac9fb20/src/net/http/server.go#L88) — one-method interface, the backbone of Go's HTTP ecosystem
- [`fmt.Stringer`](https://github.com/golang/go/blob/e87b10ea2a2c6c65b80c4374af42b9c02ac9fb20/src/fmt/print.go#L63) — one-method interface for string representation

## What each pattern optimizes for

#### Pattern A (producer-defined)
- **LSP navigability.** "Go to Implementations" on `Repository` lands you on `postgresRepo` instantly. Same package, zero ambiguity.
- **Discoverability.** A new engineer opens the producer package and sees the contract right there.
- **Familiar to OOP-background engineers.** Lower onboarding friction for teams coming from Java/C#.

#### Pattern B (consumer-defined)
- **Narrow contracts.** Each consumer declares exactly the surface it needs. No more, no less.
- **Lower coordination cost.** The producer can evolve freely — no consumer breaks unless that consumer explicitly asked for a changed method.
- **Trivial testing.** 3-line stub in the test file. No codegen, no shared mock package.

## The conditional: it depends on where the boundary sits

The right pattern depends on the ownership boundary.

#### Exported package → Pattern B wins
- Different teams, different repos, different release cadences.
- Coordination cost is real and expensive — PRs against shared interfaces, version negotiations, release sync meetings that turn your microservices into a distributed monolith.
- The LSP tradeoff barely matters: consumers rarely navigate into the producer's internals daily.
- This is where `io.Writer` and `net/http.Handler` live — and why the standard library is designed this way.

#### Encapsulated code that exports an API → Pattern A is often better
- Same team, same codebase, same standup. Coordination cost is already low.
- The LSP tradeoff hits you every day — you or your engineers (or your AI code assistant) are navigating between API → logic → DB layers constantly.
- A well-scoped producer-defined interface at the layer boundary gives you "Go to Implementations" and clear contracts, without the cross-team overhead that makes it expensive elsewhere.
- For small services: you might not need interfaces at all. Pass the concrete type and add an interface when testing demands it.

## Common failure modes (regardless of pattern)
- **Exporting interfaces "just in case."** 12-method `Repository` interfaces where every consumer uses 2.
- **Shared interface packages.** A `contracts/` directory that every service imports. You've reinvented the base class.
- **Over-embedding.** Embedding 5 structs into one type. You're building a god struct, just horizontally.
- **Applying Pattern B dogmatically inside your own service.** This will be from the most technically gifted engineer in your team, as it is _the_ pattern in the std library, but will slow you down when you need Pattern A.
- **AI code review blindness.** Accepting the OOP-flavored output from code completion without asking "who should own this contract?"

## What about the AI code assistants

One nihilist argument I hear is that code is irrelevant in the era of code assistants. As someone pretty close to the forefront of using code assistants in 2026, I still think these patterns matter. Here is why:

- **Human understanding.** No matter who or what produces the code, you want a human (i.e. your team) to understand it. Who will pick up that page? Who has the moral hazard when things go wrong? I don't think your investor will react well if you pull a Digg version 4 and fold the company on a bad update, and your argument is "the AI made me do that."
- **Pattern consistency steers agent runs.** You want to be deliberate in what you write, or in the instructions you give your code assistant, so that the N+1 run doesn't apply Pattern A in a place where Pattern B lives (or the other way around). If you use Pattern A, you want to be deliberate and make sure that is enforced, because an agent may pick up Pattern B (as that is popular as well) and all of a sudden agent run N+2 has to reconcile — spending more time, more money in AI, and more time for your team to understand what happened.

In other words:

> Being deliberate about which pattern you use where isn't just good engineering, it's how you steer the AI tools that now write most of your code.
