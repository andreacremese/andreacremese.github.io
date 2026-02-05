# Andrea Cremese github pages

A collection of my review papers in the sprit of "A Nerd with an MBA". See them deployed at (andreacremese.github.io)[https://andreacremese.github.io/].

## Development & Security Setup

This repository in **public**. That should be scary for everyone. So to install all required tools and set up pre-commit hooks for security and code quality checks, run:

```sh
make install-hooks-tools
```

This will install pre-commit, semgrep, and ggshield using Homebrew, and configure the pre-commit hooks automatically.

To serve the site locally:

```sh
make serve
```
