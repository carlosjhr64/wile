# Wile

* [VERSION 0.0.260418](https://github.com/carlosjhr64/wile/releases)
* [github](https://www.github.com/carlosjhr64/wile)
* [rubygems](https://rubygems.org/wile)

## DESCRIPTION

`Wile` is a tasks dispatch manager
for ruby gem projects that uses it's project template.

Generate a new project from scratch using it's template.
Compare current project with template.
Automate `gemspec` maintenance.
And many other tasks!

## PHILOSOPHY

### One structure for all Ruby projects

Every Ruby project should look the same. Same directories, same test layout,
same dotfiles, same release ritual. The `cache/` template *is* that structure,
and `wile mkdir` creates it, `wile compare` measures drift from it, `wile cp`
repairs it. A new project isn't a blank page; it's the template with a name.

### The template is executable documentation

Structure described in prose rots. Structure enforced by tooling doesn't.
The template isn't a wiki page about how projects should look — it *is* how
they look, and the tooling keeps them honest. If you want to change the
standard, you change the template, and every project can be pulled forward
with `compare`/`cp`.

### Hygiene is automated, not aspirational

Version strings agree across `.version`, `lib/`, `README`, and the gemspec —
because `bump` writes them all and `tc_version` checks them all. Rubocop is
clean because `tc_rubocop` fails otherwise. The dictionary and lexicon are
current because their tests fail otherwise. The README's HELP section matches
`--help` output because `update` regenerates it. Nothing here relies on
remembering; the test suite is mostly the project checking itself.

### Releases are a ritual, not a decision

Versions are dates: `0.0.YYMMDD`. `bump` stamps a new one (major/minor only
when you mean it), `test` proves the tree, `build` packages it, `publish`
pushes the gem, tags, and pushes git. No agonizing over what "deserves" a
minor bump — the date is the version, and the ritual is the same every time.

### The environment is part of the project

`wile requirements` knows every command the workflow needs, down to the
version. Dotfiles ship in the template. A project isn't just code; it's the
machine the code expects. *(This is the most personal opinion here — the
shape of it is universal, the contents are mine.)*

### Code should be legible to its author in six months

`content` shows every method with its line count. `order` suggests method
ordering by dependency. `smell` finds the unused, the undefined, the isolated.
`review` walks you through each file with content, order, reek, and rubocop
in turn. Readability isn't a virtue you admire; it's a property you maintain.

### Documentation lives with the code — or it's generated

Task help is scraped from the comment header of the task file; it can't drift
from the code because it *is* the code. The README's HELP section is
regenerated from `--help`. Anything a human has to remember to update by hand
will eventually lie, so don't ask humans to do it.

### Convention over configuration, all the way down

A task is a file in `lib/wile/tasks/`. Its help is its header comment. Its
argument contract is a declarative `Usage` validator. Nothing is registered
in five places; adding a feature is adding a file. The tool trusts naming
conventions the way the template trusts directory conventions.

### Unix citizenship

Small tasks, composable with pipes. Fuzzy task matching (`wile upd` finds
`update`) because humans mistype. Exit codes from `sysexits(3)`: 64 for
"you used me wrong," 70 for "I broke." Color when there's a TTY. It should
feel like it belongs next to `git` and `grep`, not like an app.

## INSTALL
```console
$ gem install wile
```
* Required Ruby version: `>= 4.0`

## HELP
```console
$ wile --help
## wile ##
Usage:
  wile [<task=WORD> [<args>+]] [:options+]
Options:
  -h --help
  -v --version
  -c --check
  --config=FILE
  -d --dump
  -f --force
  -l --list
  --name=WORD
  -r --raw
  -s --strict
  -t --trace
Types:
  WORD /^\w+$/
  FILE /^[\w\-\.\/]+$/
```
## TASKS

Run `wile` by itself and you'll get `Wile's` man-page.

+ build: build gem package
+ compare: compare project to template
+ cp: copy files from template to project
+ dependencies: list project's dependencies
+ dictionary: dictionary maintenance(helps catch typos overall)
+ gemfile: outputs a `Gemfile`
+ help: get usage on any particular task
+ info: outputs information on current project
+ lexicon: code lexicon maintenance(helps catch typos in code)
+ list: lists available tasks
+ mkdir: creates a new project directory populated with template
+ note: scrapes project for `NOTE` comments
+ nvim: opens project files in your editor
+ order: suggests an order to your methods in a file
+ requirements: list `Wile's` system requirements
+ ruby: lists all ruby files in project
+ test: runs project's tests
+ todo: scrapes bullet lines in `TODO.md` or `TODO` comments in entire project
+ update: maintains `gemspec` and `README.md`

## LICENSE

Copyright (c) 2026 CarlosJHR64

Permission is hereby granted, free of charge,
to any person obtaining a copy of this software and
associated documentation files (the "Software"),
to deal in the Software without restriction,
including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and
to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice
shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS",
WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## [CREDITS](CREDITS.md)
