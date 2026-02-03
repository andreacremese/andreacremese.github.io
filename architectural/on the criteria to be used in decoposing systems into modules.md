# On the criteria to be used in decoposing systems into modules

## TODO

[] find a quote / source for the cost of changing software

[link](https://dl.acm.org/doi/10.1145/361598.361623)

## Introduction

This is one of the pivotal papers in system decompositions. It is from 1971, and still every bit as relevant in the XXI century.
In my experience, its considerations come up often in the day to day 
life of a software developer architect. The reason for this is really simple, and that is because this paper puts as a first class citizen the concept of idependent development, changeability, and comprehensibility.

Independent development means being able to parallelize operations, which is critical for any team of a certain size. Changeability is key as, depending on various estimations, software support costs 4 to 10 times as much as the first write. Designing for changeability means let's make code cheaper on a TCO (total cost of ownership). Comprehensibility is most of what an engineering does on a day to day basis, being that from the code or from logs, understanding of the running code takes a long time.



## brief summary

The paper proposes a simple theoretical problem (KWIC system) as a benchmark to compare two possible approaches to modularize and decompose a system. For the sake of this discussion one can think of the KWIC as a small programming challenge where strings are manipulated, reversed, and ordered. Its details are somewhat unimportant in comparison with the modularization so I will not spend too much time going into details.

The two modularizations proposed are:

- Modularization 1: a flowchart approach - write code reflecting the way strings / text is flowing through the steps.
- Modularization 2: use "information hiding" as a criteria. "Every model [...] is characterized by its _knowledge_  of a design decision which it hides from all others.".


Modularization 2 later is called also Encapsulation.

The first criteria proposed to compare the options is **changeability**, or "how many places do we need to amend if {x} happens", where x is some sort of requests for change in functionality, with a wider example in the back of the paper regarding a concrete case. THe analysis whos that flowchart systems tend to have data that is very tightly knitted across the steps, therefore causing a change in one step to cause a change ... in every module that makes the system. In the second option instead the changes are localized in one module in general, and at most then in the module that consumes that.

In terms of **independent development**, the next criteria, it is clear that the Interface between modules need to be established at the outset, by all teams working on this flowchart. 
These interfaces are very stiff and hard to change. 
This means different actors working on different parts of the system cannot commence until the whole system is designed, with a massive hit to velocity at first. In the second modularization the interfaces are more abstract, and they are much more independent.

In terms of **comprehensibility**, the first modularization needs to be understood in its entirety by an individual before operating on that, while in the second modularization the encapsulation allows someone to operate on a smaller subset. This is also nowadays known as cognitive load for a developer (and regression bugs).

An interesting point that the paper makes is that, after assembly, the code produced may be very well the same in the two modularizations BUT the advantages are still remaning.


## Reflections

### Changeability

The term encapsulation seems to come up very often the day to day life of a software developer / architect. It is a concept we all grasp, and we are able to talk about, but often it is hard to substantiate the **why spending the extra time**, especially with less technical counterparts (PMs, EMs, ...). This paper to me really gets to the point of why that is important. 


### Don't use a flow chart to do system design

While important to understand real processes and communicate with otherstake holders, this is a pitfall I fell into so many times. 
Maybe that is why designing (and maintaining) ETL - extract translate load systems is so complicated: at the end of the day they are DAGs (directed acyclic graphs - flowcharts) that the data traverses, and changes in a node change the whole system.

Another aspect where designing (and maintaining) software as a flowchart becomes pretty cumbersome is when using frameworks to interact with LLMs and agents. These tend to become graphs with some State that gets passed around. Understandind what that `State` has inside can become really complicated, and requires to understand the whole graphs (with all loops and optional edges). For that reasons as soon as subgraphs / separate nodes become available that is a good choice to take, as it at least reduces the scope of the "flowchart".


### hierarchical and module partial ordering

This is in a separate paper by Dijkstra which I am reviewing in another note, but in essence this means that modules that "uses" or "depend on" others".
Another definition is that "at higher levels the actual implementation of [module] has lost its identity"
This paper discusses that a hyerarchical system is necessary, but not sufficient, to get the benefits of modularization.

### Information hiding

This is tightly related to the above, and it mostly translates to Encapsulation.

### Comprehensibility

One aspect for this in the era of AI systems is that reduces the pressure on the context for an LLM. This because an agent can think and help on a module without having to "understand" (keep in context) the content of the other. So, one take away, is that **comprehensibility actually helps us when we use agents as well**. 

### One note on coding agents ~doing~ fixing architecture

In late 2025 I looked at a POC service that, due to timing and a heavy use of AI in making it, didn't have a great encapsulation. Actually, it had reversed encapsulation (the inner layer depende on the outer layer). As an exercise, we attempted to have an AI agent (won't name names, but one of the main ones at that time) refactor it to respect the encapsulation proposed in this paper. We didn't just pass in the paper and prompt "please make it so", we actually formulated what we wanted, the changes, and took it in steps. That proved really challenging (the agent couldn't really do it). Agents may be able to do this in the future, but this is to make the point that these sort of large strategic decisions are really hard for an LLM - at least in late 2025.

### The Unix Philosophy

One of the corner stones of the "characteristic style" for Unix is to _Make each program do one thing well_. That quote is actually from 1978 (according to "Unix Time-Sharing System: Foreword"), and every bit as relevant today, probably influenced by this paper. I may be forcing it a bit, but the idea of "comprehensibility" and "changeability" is directly correlated by that. Can you immagine the nightmare of having to, say, amend `sed` and having a dependency on `sort` on unix?