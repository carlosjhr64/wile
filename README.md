# Wile

* [VERSION 0.0.261020](https://github.com/carlosjhr64/wile/releases)
* [github](https://www.github.com/carlosjhr64/wile)

## DESCRIPTION

`Wile` is a tasks dispatch manager
for ruby gem projects that uses it's project template.

Generate a new project from scratch using it's template.
Compare current project with template.
Automate `gemspec` maintenance.
And many other tasks!

## INSTALL

* Wile runs only on Linux
* Required Ruby version: `>= 4.0`

`Wile` is not published to RubyGems. Because project structure, template
conventions, and environment expectations are hardcoded directly into
the Ruby source and `cache/` template, the code itself *is* the configuration.

To use `wile`, clone the repository from GitHub, review and customize the code
and `cache/` templates to fit your own workflow, and install it locally:
```console
$ git clone https://github.com/carlosjhr64/wile.git
$ cd wile
$ ./bin/bootstrap_ruby_rbenv
$ # And more bootstraping problems to solve... TODO
```

## HELP

For more help, see the AI generated and maintained
[wiki](https://github.com/carlosjhr64/wile/wiki).
```console
$ wile --help #>>
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

Run `wile` by itself and you'll get `Wile's` help page.
```console
$ wile #>>

## wile help ##
Usage:
  wile help [<task>+] # show task's help

## wile list ##
Usage:
  wile list [<match>+] [--list] # list tasks(by match)

```
Run `wile list` and you'll get the entire list of available tasks.
```console
$ wile list --list #>>

+ build: build gem pkg
+ bump: Bump the version number
+ compare: compares project with template
+ content: show file's contents
+ cp: copy template files into project
+ dependencies: list ruby dependencies
+ dictionary: view changes and update dictionary
+ gemcheck: Checks for missing gems
+ gemfile: list ruby gems as in Gemfile
+ help: show task's help
+ info: show project info
+ install: install current local project
+ lexicon: view changes and update lexicon
+ list: list tasks(by match)
+ mkdir: creates project dirname
+ note: scrape ruby files for note's
+ nvim: spawn nvim with(matching) files
+ order: suggest a methods order
+ publish: publish a new version
+ requirements: checks for missing system commands
+ review: runs review
+ ruby: lists all ruby files
+ smell: classify methods in your code
+ tc: lists custom unit tests in project
+ test: runs tests
+ todo: scrape file's TODO's
+ update: update README and gemspec

```
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
