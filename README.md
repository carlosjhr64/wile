# Wile

* [VERSION 0.0.251018](https://github.com/carlosjhr64/wile/releases)
* [github](https://www.github.com/carlosjhr64/wile)
* [rubygems](https://rubygems.org/wile)

## DESCRIPTION

`Wile` is a tasks dispatch manager
for ruby gem projects that uses it's project template.

Generate a new project from scratch using it's template.
Compare current project with template.
Automate `gemspec` maintenance.
And many other tasks!

## INSTALL
```console
$ gem install wile
```
* Required Ruby version: `>= 3.4`

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

Copyright (c) 2025 CarlosJHR64

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
