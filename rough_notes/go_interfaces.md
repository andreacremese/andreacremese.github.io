# go interfaces vis a vis other languages


In Go, the common rule is: accept interfaces, return concrete types.
Interfaces are usually best defined by the consumer (the orchestration service), not by the producer (repository package).
That keeps abstractions minimal and avoids “fat interface first” design.

so often (looking at you AI code completes) you get a package that looks like

```golang
type PackageInterface interface {
    Method1().
}

func (t *thisPackage) Method1() {
    ...
}

```

But that is not what we want to do.

Examples in the wild:

In other words, the interface is actually defined by the consumer, as the smallest subset of behavior it accepts. One example of this is net/http in standard library , looking at the type Handler interface.

Another is io, still in the standard library, example type Writer.
