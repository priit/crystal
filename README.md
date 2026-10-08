# Crystal Alpha — fast rebuilds fork

A Crystal compiler fork where editing a method rebuilds in a fraction of a
second. On an Amber V2 blog (101 files, [benchmark](#benchmark-an-amber-v2-blog)),
the running server shows a method body edit in 0.6 s and a template edit in
1.3 s instead of 36 s, and a build without changes is skipped (0.06 s).

**Based on:** Crystal 1.21.1 plus upstream `master` up to
[`bdfcb3685`](https://github.com/crystal-lang/crystal/commit/bdfcb3685)
(2026-10-08); `crystal --version` reports `1.22.0-dev`.

Even in an LLM-driven world, clear and maintainable source code is still
valuable. I'm not a big fan of LLMs blindly turning everything into very
verbose Assembly or low-level Rust. The compiler should handle the lower-level
complexity deterministically, producing the exact same result every time.

The goal is to make Crystal fast enough for an LLM-heavy development workflow
without sacrificing readability. Current Crystal compilation is effectively 
unusable in an LLM-driven workflow: LLMs need fast feedback and multiple 
quick development cycles, while a large Crystal project can spend hours
compiling instead of iterating.

It's built for both ways of writing code today:

- **With an LLM (Claude Code, other agents):** the agent edits several files
  without a build per step (`crystal watch hold`), then gets its errors in
  a second or two (`crystal watch build`) instead of waiting for a full
  compile.
- **By hand:** keep `crystal watch` open in a terminal; save a file and the
  program restarts with the change before you've switched windows.

Your code stays ordinary Crystal: no type annotations are required, and
everything that compiles with upstream Crystal compiles here the same way.

Both can work on the same project at once if needed: the agent edits, you keep
`crystal watch` open, and it rebuilds once when the agent is done.

## Setup

1. **Install the compiler** (Linux; needs LLVM and the usual Crystal build
   dependencies). From a checkout of this repository:

   ```sh
   make install release=1 interpreter=1 PREFIX=~/.local/opt/crystal-alpha
   ln -sfn ~/.local/opt/crystal-alpha/bin/crystal ~/.local/bin/crystal
   crystal watch --help | grep hold   # this fork is the one on PATH
   ```

   The man page step needs `asciidoctor`; if it fails, the compiler is still
   installed. Keep your upstream `shards` binary (it works with this
   compiler), and if linking programs fails on bundled libraries such as
   `libgc`, copy `lib/` from your upstream Crystal install into the prefix.

2. **Nothing to migrate.** Run `crystal watch` in your project. Return types are optional, as in upstream Crystal; see
   [How it stays fast without type annotations](#how-it-stays-fast-without-type-annotations).

## Prepare Claude Code (or another agent)

Put these hooks in the project's `.claude/settings.json` (also printed by
`crystal watch hooks`). They hold builds while Claude edits and release them
when it stops, so a multi-file edit is built once:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|NotebookEdit",
        "hooks": [{ "type": "command", "command": "crystal watch hold claude" }]
      }
    ],
    "Stop": [
      {
        "hooks": [{ "type": "command", "command": "crystal watch release" }]
      }
    ]
  }
}
```

And add this to the project's `CLAUDE.md` (or `AGENTS.md` for other agents):

~~~~markdown
## Crystal toolchain (crystal-alpha fork)
- `crystal watch --help` must list `hold` and `build`; if not, the upstream
  compiler is on PATH: tell the user.
- The user keeps `crystal watch` running. Don't start another build or
  watcher; check with `crystal watch status`.
- After your edits, run `crystal watch build`: it builds what changed
  (usually a second or two) and prints the errors; exit 1 = fix them.
  Exit 2 = no watcher: use `crystal build --no-codegen` to type check.
- Without the hooks, run `crystal watch hold claude` before editing.
- Specs: `crystal spec --affected` runs just the examples your edits reach
  (fast with the watcher); run plain `crystal spec` before finishing.
  A single file or example: `crystal spec [spec/file_spec.cr:LINE]`.
- Editing method bodies and adding methods is fastest (a body edit that
  changes what a method returns also types its callers again, still
  fast); changing signatures, removing methods or adding types is fine
  but rebuilds fully (a full compilation, ~20 s on a 100 file app).
- If the watcher runs with `--log FILE`, the program's output and the
  builds are in FILE and only the problems in FILE.errors.log
  (`crystal watch status` names them); the last build is what follows the
  last `=== build N started ===` line.
- Format: `crystal tool format`.
~~~~

## Usage

In a shard, commands find the main file from `shard.yml` (first target's
`main`, else `src/<name>.cr`):

```sh
crystal watch           # build, run, rebuild + restart on every change
crystal watch --no-run  # rebuild on every change without running (a shard, a CLI tool)
crystal watch -o bin/app --log log/development.log  # where the program goes; its output and errors also to a log
crystal build           # build; skipped if nothing changed
crystal run             # build and run once, as upstream
crystal spec            # run the specs; skipped build if nothing changed
```

While `crystal watch` is running, the other commands use it:
`crystal build` gets its up to date executable, and `crystal spec` has it keep
the spec program typed too, so after an edit the specs rebuild in about a
second instead of compiling from scratch. Other programs (the hooks above, an
agent, a script) talk to it as well:

```sh
crystal spec --affected     # run only the examples reaching code changed since the last spec run
crystal watch hold claude   # don't build while editing
crystal watch release       # build what changed, once
crystal watch build         # build now, wait, print errors (exit 0 ok, 1 failed, 2 no watcher)
crystal watch status        # result of the last build
```

What rebuilds fast (~0.6-3 s on the blog): method bodies (also when what the method
returns changes: its callers are typed again), methods added to a class,
struct or module (unless they override another or a macro lists the type's
methods), templates (Slang, ECR) rendered inside a method, and the fix after
a type error. A signature change, a new type, a removed method, a changed
return type reaching top-level code, a recursive method without a return
type, or a file read by a top-level macro (e.g. i18n locales) rebuilds
fully (~18 s on the blog). A top-level `run` macro (a generator writing the files a
`require` reads) is run again when its input changes; if its output is the
same and it adds or removes no file, the files it rewrote rebuild as
ordinary edits.

## How it stays fast without type annotations

`crystal watch` keeps the typed program in memory. When
you edit a method body, only that method is typed again, and only the LLVM
modules of the types it belongs to are generated again; every other
module's object file is reused.

What keeps an edit local is a check, not an annotation: after typing the new
body, the compiler compares the type it returns with the old one. Usually
it's the same, and nothing else needs to change (*early cutoff*). When it
changed, the methods calling it are typed again with the new type, then
theirs, until the types stop changing. So return types don't make
rebuilds or full builds faster: Crystal infers every method anyway.

Return types are still worth writing where they document intent, and a
declared type keeps a body edit from reaching callers when the new type
fits it. `--strict-signatures` (or `CRYSTAL_STRICT_SIGNATURES=1`) is the
old opt-in mode: every `def` in your project must declare its return type,
and the declared type is what callers see (the *return type firewall*).
`crystal tool annotate` adds the types for you. How it works:
`IC_PHASE_8_STRICT_SIGNATURES.md`. Incremental caching and
`--no-incremental`: `INCREMENTAL_PLAN.md`.

## What's different from upstream Crystal

Things to check when switching a project or system to this compiler:

1. **Incremental compilation is on**, cached in `CRYSTAL_CACHE_DIR` (default
   `~/.cache/crystal`): `crystal build` with nothing changed only checks
   file fingerprints and macro inputs. If something looks stale, build with
   `--no-incremental` (or `CRYSTAL_INCREMENTAL=0`) and please report it.
2. **`run` macros must name what they read.** A build that used `{{ run(...) }}`
   is now skipped when nothing changed, judging by the program's sources, the
   arguments that are files or directories, and the files the program lists
   in the file named by the `CRYSTAL_MACRO_RUN_DEPFILE` environment variable
   (one path per line). A `run` program reading other files (a fixed config
   path, a glob of its own) should list them there; or set
   `CRYSTAL_MACRO_RUN_TRUST=0` to never skip such builds. ECR, Slang and
   i18n embeds are covered by their arguments.
3. **Commands without a file** (`crystal build`, `crystal run`,
   `crystal watch`, ...) build the shard's main file (`shard.yml`) instead of
   printing their usage. `crystal run` still runs once, as upstream.
4. **A full compilation restarts the watcher** in place (`exec`, same
   pid, same arguments) so only the new program is held in memory; the
   build number, holds and logs carry on. `CRYSTAL_WATCH_REEXEC=0` keeps
   it in the same process.
5. **`.crystal-watch/`** appears in projects where `crystal watch` ran (it
   holds the build status; it ignores itself in git).
6. **Processes are spawned with `posix_spawn`** on Linux (glibc) instead of
   `fork` + `exec`, when no `chdir:` is given: much faster from a large
   process, same redirections, environment and signal handling. Code that
   relied on running Crystal code in the child between `fork` and `exec`
   can't, but the standard library never offered that for `Process.new`.
7. **Only with `--strict-signatures`** (opt-in): every `def` in your project
   (not `lib/`, not the standard library) must declare its return type, and
   a declared return type is what callers see: upstream, `def foo : Int32?`
   whose body returns an `Int32` has type `Int32` at call sites; in strict
   mode it's `Int32?`. Such methods always count as possibly raising, and a
   body that is just a literal or `self` isn't inlined at its call sites.

## Benchmark: an Amber V2 blog

A blog engine on Amber `2.0.0-beta.5` and Grant: 12 models with
associations, generated by the Amber CLI (`amber new` and
`amber generate scaffold`: models, controllers, schemas, ECR views),
101 source files. It's in `benchmarks/amber_blog`. How long until the
running server shows a change:

| Change | Crystal 1.21.0 | This fork, `crystal watch` | Faster |
|---|---|---|---|
| A model method body | 36.0 s | 0.6 s | 56× |
| A controller action | 35.9 s | 2.7 s | 13× |
| A template (ECR) | 35.5 s | 1.3 s | 26× |
| First build (empty cache) | 57.8 s | 29.0 s | 2× |

`crystal watch` is the everyday loop: started in the project in a
terminal, it rebuilds and restarts the server on every save. For Crystal
1.21.0 it's the `crystal build` time, before restarting the server (its
`crystal run` builds the same way). The fork's
`crystal build`, without `crystal watch` running, takes 17-20 s for these
edits (2× faster) and 0.06 s when nothing changed. With `crystal watch`
running, a change it can't apply in place (a changed signature) takes
about 18 s, and `crystal spec` after a method body edit about 0.8 s
(20-22 s for its first build).

The script checks after each edit that the server serves the new code.
The numbers are the middle of three runs (2026-10-08, the fork at
`1ac762b36`): Crystal 1.21.0 took 57-58 s cold and 35-39 s per rebuild,
the fork's `crystal watch` 0.64 s for every model edit and 2.3-2.8 s for
the controller. Tested on Ubuntu 26.04.1
LTS, x86_64 (Linux kernel 7.0.0-34-generic) with LLVM 21.1.8, AMD Ryzen 7
PRO 6850U (8 cores).

Check it yourself:

```sh
STOCK_CRYSTAL=/path/to/crystal-1.21/bin/crystal ./scripts/benchmark_amber_blog.sh
```

`CRYSTAL` picks the fork (default: `crystal` on `PATH`); it needs `shards`,
`curl`, `sqlite3` and a free port 3000. To generate the blog again, or a
larger one (`TopicNNN` models up to the count), with the
[Amber CLI](https://github.com/amberframework/amber_cli):

```sh
./scripts/demo_amber_blog.sh /tmp/blog 12
```

---

# Crystal (upstream README)

[![Linux CI Build Status](https://github.com/crystal-lang/crystal/workflows/Linux%20CI/badge.svg)](https://github.com/crystal-lang/crystal/actions?query=workflow%3A%22Linux+CI%22+event%3Apush+branch%3Amaster)
[![macOS CI Build Status](https://github.com/crystal-lang/crystal/workflows/macOS%20CI/badge.svg)](https://github.com/crystal-lang/crystal/actions?query=workflow%3A%22macOS+CI%22+event%3Apush+branch%3Amaster)
[![AArch64 CI Build Status](https://github.com/crystal-lang/crystal/workflows/AArch64%20CI/badge.svg)](https://github.com/crystal-lang/crystal/actions?query=workflow%3A%22AArch64+CI%22+event%3Apush+branch%3Amaster)
[![Windows CI Build Status](https://github.com/crystal-lang/crystal/workflows/Windows%20CI/badge.svg)](https://github.com/crystal-lang/crystal/actions?query=workflow%3A%22Windows+CI%22+event%3Apush+branch%3Amaster)
[![CircleCI Build Status](https://circleci.com/gh/crystal-lang/crystal/tree/master.svg?style=shield)](https://circleci.com/gh/crystal-lang/crystal)
[![Join the chat at https://gitter.im/crystal-lang/crystal](https://badges.gitter.im/crystal-lang/crystal.svg)](https://gitter.im/crystal-lang/crystal)
[![Code Triagers Badge](https://www.codetriage.com/crystal-lang/crystal/badges/users.svg)](https://www.codetriage.com/crystal-lang/crystal)

---

[![Crystal - Born and raised at Manas](doc/assets/crystal-born-and-raised.svg)](https://manas.tech/)

Crystal is a programming language with the following goals:

- Have a syntax similar to Ruby (but compatibility with it is not a goal)
- Statically type-checked but without having to specify the type of variables or method arguments.
- Be able to call C code by writing bindings to it in Crystal.
- Have compile-time evaluation and generation of code, to avoid boilerplate code.
- Compile to efficient native code.

## Why?

We love Ruby's efficiency for writing code.

We love C's efficiency for running code.

We want the best of both worlds.

We want the compiler to understand what we mean without having to specify types everywhere.

We want full OOP.

Oh, and we don't want to write C code to make the code run faster.

## Project Status

Within a major version, language features won't be removed or changed in any way that could prevent a Crystal program written with that version from compiling and working. The built-in standard library might be enriched, but it will always be done with backwards compatibility in mind.

Development of the Crystal language is possible thanks to the community's effort and the continued support of [84codes](https://www.84codes.com/) and every other [sponsor](https://crystal-lang.org/sponsors).

## Installing

[Follow these installation instructions](https://crystal-lang.org/install)

## Try it online

[play.crystal-lang.org](https://play.crystal-lang.org/)

## Documentation

- [Language Reference](http://crystal-lang.org/reference)
- [Standard library API](https://crystal-lang.org/api)
- [Roadmap](https://github.com/crystal-lang/crystal/wiki/Roadmap)

## Community

Have any questions or suggestions? Ask on the [Crystal Forum](https://forum.crystal-lang.org), on our [Gitter channel](https://gitter.im/crystal-lang/crystal) or IRC channel [#crystal-lang](https://web.libera.chat/#crystal-lang) at irc.libera.chat, or on Stack Overflow under the [crystal-lang](http://stackoverflow.com/questions/tagged/crystal-lang) tag. There is also an archived [Google Group](https://groups.google.com/forum/?fromgroups#!forum/crystal-lang).

## Contributing

The Crystal repository is hosted at [crystal-lang/crystal](https://github.com/crystal-lang/crystal) on GitHub.

Read the general [Contributing guide](https://github.com/crystal-lang/crystal/blob/master/CONTRIBUTING.md), and then:

1. Fork it (<https://github.com/crystal-lang/crystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
