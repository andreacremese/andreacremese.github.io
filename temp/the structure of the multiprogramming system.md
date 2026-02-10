# the structure of the multiprogramming system 

Some notes on the paper re layered abstractions.
link here https://dl.acm.org/doi/pdf/10.1145/800001.811672

## layered abstractions for systems - THE LOGICAL ORDERING

Organize the system as a hierarchy of levels (or layers), where each level builds upon the abstraction provided by the level bleow it. 

Each level presents a cleanre, more abstracted interface to the level above

## Principles


### abstraction

So the idea is boils down to "make what is in Level N irrelevant for Level N+1"
Example, what is relevant for level 0 (db) is irrelevant for service (level 1).
That is one aspect, but the beginning of hierarchical system.

"the lower level **looses its identity** and **disappears from the picture**.

### separate verification

each layer can be verified independently. The idea is that you can prove level N is correct assuming N-1 is correct.
So the system can be demostrated correct

That is why we have mocks for UT

### info hiding

Lower levels hide the information from the levels above.

### Put hardware concearns at the bottom

The example here is unmaskable interrupts, to be in level 0


## why?

- Reduce cognitive load (you need to understand one level at the time)
- Enable correctness proof
- Changeability is easier
- Parallel development is possible

## note on changeability 

* on the criterias to be used in decomposing systems into modules*

Read `on the criteria to be used in decomposing systems into modules` for a bit of an expansion on this.
The idea there is that a hierarchical system is necessariy but not sufficient condition for modularity and the 
promise above.

The idea there is to **not design a system as a flow chart** (see that paper)




