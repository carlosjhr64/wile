# Wile

* [VERSION 0.3.261106](https://github.com/carlosjhr64/wile/releases)
* [github](https://www.github.com/carlosjhr64/wile)

## DESCRIPTION

`Wile` is a prescriptive task dispatcher for Ruby gem projects,
built around a living project template.

It scaffolds new projects from the template, keeps existing ones
aligned with it, and automates the rest of the workflow -- gemspec
upkeep, testing, and release. There is no configuration file: your
clone is the configuration, to take as-is or edit and install
locally. It targets Linux, fish, and tmux.

## INSTALL

* Wile runs only on Linux
* Required Ruby version: `>= 4.0`

`Wile` is not published to RubyGems. Because project structure, template
conventions, and environment expectations are hardcoded directly into
the Ruby source and `cache/` template, the code itself *is* the configuration.

The minimum Ruby version that should work on
the first bootstrap script is less than 4, just try it and see.
The goal is to automate the installation of `rbenv` and
get your ruby at Wile's current version.

On each bootstrap, run it with the `--help` flag to
understand what the script is going to attempt to do.

To use `wile`, clone the repository from GitHub, review and customize the code
and `cache/` templates to fit your own workflow, and install it locally:
```console
$ git clone --depth 1 https://github.com/carlosjhr64/wile.git
$ cd wile
$ ./bin/bootstrap_ruby_rbenv
$ ./bin/bootstrap_ruby_gems
$ ./bin/bootstrap_fish
$ ./bin/bootstrap_fisher_plugins
$ ./bin/bootstrap_system_commands
$ ./bin/bootstrap_install_neovim
```
At this point you should be good to go.
I have a terminal dedicated to run `fish`, but
at the point above after installing fish, or
any time after..
You can run `fish` and be in the fishshell.
Anyways(you're in the fishshell), proceed:
```console
$ goto wile # takes you to the wile diretory
$ wile install
$ cd .. # a resonable place you might set up a new project
$ RBENV_VERSION=4.0.7 wile mkdir awesome # Use the .ruby-version set in wile
$ goto awesome
```
There you'll see the skeleton of your new Awesome project.

## HELP

For more help, see the AI generated and maintained
[wiki](https://github.com/carlosjhr64/wile/wiki).
```console
$ wile --help #>>
## wile ##

Usage:
  wile [<task=WORD> [<args>+]] [:options+]

Options:
  -h --help	Show help summary
  -v --version	Show version number
  -c --check	Run in check-only mode
  -d --dump	Dump internal structure or data
  -f --force	Force execution without safety checks
  --format=WORD	Output format
  -l --list	List items
  --name=WORD	Filter or match by name
  --only=CSV	Select only specified items
  -q --quiet	Suppress non-essential output
  -r --raw	Raw / unformatted output
  -s --strict	Enable strict mode
  -t --trace	Trace execution
  -y --yes	Assume yes to confirmation prompts

Reserved flags for custom tasks:

  -a --all	Apply to all targets
  --archive	Archive mode; preserve file attributes and permissions
  --backup	Make backup before removal or overwrite
  --batch	Run in non-interactive batch mode
  --clean	Remove build artifacts and temporary files
  --color=WHEN	Control colored output (always, auto, never)
  --config=FILE	Configuration file path
  --context=INTEGER	Number of lines of context to display
  --count	Print count of matching items instead of contents
  --delete	Delete extraneous or target files
  --dereference	Follow symbolic links
  --detailed	Display detailed output
  --diff	Show differences between files or states
  --directory=FILE	Change to directory before operating
  --encoding=WORD	Character encoding to use
  --exclude=PATTERN	Exclude files or paths matching pattern
  --follow	Output appended data as file grows
  --header	Display or include header line
  --icase	Ignore case distinctions in patterns or text
  --include=PATTERN	Include only files or paths matching pattern
  -i --interactive	Prompt before overwrite or action
  --interval=DECIMAL	Time to wait between repetitions
  --jobs=INTEGER	Number of concurrent jobs or tasks
  --limit=INTEGER	Limit the number of results or records
  --linenumber	Print line number with output lines
  --logfile=FILE	Path to log file
  --maxdepth=INTEGER	Descend at most INTEGER directory levels
  --mode=MODE	File permission mode (octal or symbolic)
  --nocache	Bypass cache and fetch fresh data
  --output=FILE	Write output to file
  -p --parents	Create intermediate parent directories as needed
  --port=INTEGER	Port number to connect or listen to
  --preserve=ATTRS	Preserve specified file attributes
  --readable	Print human readable output
  -R --recursive	Operate recursively on directories
  --remote=URL	Remote repository or server address
  --reverse	Reverse sorting order of results
  --simulate	Simulate execution without making changes
  --sort=WORD	Sort output by specified key or field
  --status	Display operational status or summary
  --sync	Synchronize data to storage before exiting
  --tag=WORD	Tag name or label to apply or filter by
  --target=FILE	Target file, directory, or architecture
  --timeout=DECIMAL	Maximum time to wait before timing out
  --user=USER	Run as or filter by user

Types:
  WORD      /\A[\w-]+\z/
  CSV       /\A[\w-]+(,[\w-]+)*\z/
  FILE      /\A(\/?[\w.][\w.-]*)+\/?\z/
  ATTRS     /\A[a-zA-Z]+(,[a-zA-Z]+)*\z/
  MODE      /\A[0-7]{3,4}\z/
  INTEGER   /\A\d+\z/
  DECIMAL   /\A\d+(\.\d+)?\z/
  PATTERN   /\A\S+\z/
  USER      /\A([a-zA-Z_])[\w-]*\z/
  WHEN      /\A(always|auto|never)\z/
  URL       /\A([a-zA-Z]+:\/\/\S+|[\w.-]+@\S+)\z/

### Get started ################################
#  wile               # shows man page         #
#  wile list          # list all tasks         #
#  wile help [<task>] # show help for task(s)  #
#  wile test          # run the test suites    #
################################################
```
## TASKS

Run `wile list` and you'll get the entire list of available tasks.
```console
$ wile list --format=dictionary #>>

+ hello: prints Hello World
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
+ update: update project files

```
## FEATURED TESTS

* `test/tc_readme_rocket_check`

Your Ruby demos don't lie.
Test to verify your README rockets!
```ruby
# The rockets are compared to the inspect return of the value
1 + 2 #=> 3
1 + 2 == 3 #=> true
['a', 'b', 'c'].join #=> "abc"
'abc'.class #=> String
'abc'.to_sym #=> :abc
'Major.Minor.Build'.split('.') #=> ["Major", "Minor", "Build"]
{a: 'abc', b: 'cde', c: 'xyz', d: 'ace'}.select{|k,v| v.include? 'c'} #=> {a: "abc", b: "cde", d: "ace"}
require 'date'
# The twiddle rockets verifies it matches the pattern
Date.today.to_s #~> ^\d\d\d\d-\d\d-\d\d$
```

* `test/tc_dictionary`

Spell check tailored for code and docs.
Uses compressed English trigram frequencies to catch typos across
`README.md`, `bin/*`, and `lib/` without external dependencies.
New terms and project jargon are reviewed with `wile dictionary`
and tracked in `.dictionary`.

* `test/tc_version`

Keep version numbers honest and in sync.
Ensures the authoritative version in `.version` stays aligned across
code constants in `lib/`, CLI executables in `bin/`, gemspecs, and
`README.md` so you never publish a mismatched gem.

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
