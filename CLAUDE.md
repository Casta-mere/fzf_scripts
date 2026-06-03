# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of interactive shell functions built on top of `fzf`. Each `.sh` file in the repo root defines functions for a specific domain. They are **not** standalone scripts — they define shell functions meant to be sourced into the user's shell session.

## Release process

Releases are triggered by pushing a `V*` tag. The GitHub Actions workflow (`build.yml`) then:

1. Concatenates all `*.sh` files in the root into `generated/fzf-scripts.sh` with a `# VERSION=<tag>` header prepended.
2. Copies `install/install.sh` to `generated/`.
3. Publishes both files plus archive bundles (`install_pack.tar.gz`, `install_pack.zip`) as a GitHub release.

The installer downloads `fzf-scripts.sh` and sources it from `~/.fzf-scripts/fzf-scripts.sh`. The version string read by `install.sh --version` comes from the `# VERSION=` line at the top of that file.

**To cut a release:** push a tag matching `V*` (e.g. `git tag V0.1.1 && git push origin V0.1.1`). No build step needs to be run locally.

## File layout

| File | User-facing functions |
|---|---|
| `git.sh` | `glog` — interactive git log with preview and copy-hash |
| `process.sh` | `fkill` (kill process), `ffgrep` (grep + batcat preview), `ff` (find file) |
| `conda.sh` | `conda_activate`, `conda_search` |
| `dockerscript.sh` | `enter`, `ddel`, `dfdel` (user-facing); `ContainerUP/Down/All`, `ImageAll` (internal helpers) |
| `install/install.sh` | Manages install/uninstall/update; not bundled into `fzf-scripts.sh` |

## Patterns to follow

- Each root `.sh` file adds shell functions only — no top-level code that runs on source.
- Helper functions (like `ContainerUP`) should be defined before the public functions that call them within the same file.
- The build concatenates files with `awk 'FNR==1 && NR>1 {print ""} 1' *.sh` — alphabetical order. Keep that in mind if cross-file dependencies arise (currently all dependencies are within the same file).
- `--accept-nth` in fzf pipelines controls which column is returned; use it to keep display formatting separate from the value passed to the command.
- Runtime dependencies: `fzf`, `batcat` (for file previews), `docker` (docker scripts), `conda` (conda scripts).
