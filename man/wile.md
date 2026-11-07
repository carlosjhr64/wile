# wile

## NAME

wile -- prescriptive task dispatcher for Ruby gem projects

## SYNOPSIS

`wile [<task>] [<args>...] [:<options>...]`

`wile <options>...`

## DESCRIPTION

**Wile** is a prescriptive task dispatcher for Ruby gem projects,
built around a living project template.

It scaffolds new projects from the template, keeps existing ones
aligned with it, and automates workflow steps -- gemspec upkeep,
testing, and release.

## GET STARTED

- `wile`: Display manual page.
- `wile <options>...`: Query options dictionary for flag details.
- `wile list`: List all available tasks.
- `wile help [<task>]`: Show help for task(s).
- `wile test [<file> [<method>]]`: Run project test suites.

## GLOBAL OPTIONS

- `-h`, `--help`: Show help summary.
- `-v`, `--version`: Show version number.
- `-c`, `--check`: Run in check-only mode.
- `-d`, `--dump`: Dump internal structure or data.
- `-f`, `--force`: Force execution without safety checks.
- `--format=WORD`: Output format.
- `--git`: Operate on git-tracked files.
- `-l`, `--list`: List items.
- `--name=WORD`: Filter or match by name.
- `--only=CSV`: Select only specified items.
- `-q`, `--quiet`: Suppress non-essential output.
- `-r`, `--raw`: Raw / unformatted output.
- `-s`, `--strict`: Enable strict mode.
- `-t`, `--trace`: Trace execution.
- `-y`, `--yes`: Answer yes to all prompts.

## TASKS

Run `wile list` to list all tasks, or `wile help <task>` for details.

- **build**: Build gem package into pkg/.
- **bump**: Bump project version number.
- **compare**: Compare project files with template (see **COMPARE**).
- **content**: Inspect ruby file structure and methods.
- **cp**: Copy template files into project.
- **dependencies**: List ruby dependencies.
- **dictionary**: Manage spelling dictionary (see **DICTIONARY**).
- **gemcheck**: Check for missing gems across rbenv Rubies.
- **gemfile**: Generate Gemfile from dependencies.
- **help**: Show detailed help for tasks (see **HELP**).
- **info**: Display project metadata and configuration.
- **install**: Build and install gem locally.
- **lexicon**: View and update vocabulary whitelist (see **LEXICON**).
- **list**: List all tasks or filter by pattern (see **LIST**).
- **mkdir**: Create project directory from template.
- **note**: Scrape ruby files for NOTE comments (see **NOTE**).
- **nvim**: Open project files in Neovim (see **NVIM**).
- **order**: Suggest method ordering in ruby files.
- **publish**: Publish new version to RubyGems.
- **requirements**: Verify system commands and versions.
- **review**: Run code review checklist.
- **ruby**: List all ruby files in project or git (see **RUBY**).
- **smell**: Classify method dependencies and smells.
- **tc**: List custom unit tests (see **TC**).
- **test**: Run test suites (see **TESTING**).
- **todo**: Display TODO.md or scrape files for TODO comments (see **TODO**).
- **update**: Update project files.

## COMPARE

Wile compares project files against the living template in `cache/`,
honoring `.wileignore`:

    $ wile compare                  # Compare all template files
    $ wile compare README           # Show diff for matching files
    $ wile compare lib/ test/       # Compare multiple paths

Markers indicate file status:

- `✓` (green): Project file is identical to the template.
- `Δ` (blue): Project file contains expected customizations (such as
  `lib/`, `bin/`, `man/`, `README.md`, `Gemfile`, and dotfiles).
- `✗` (red): Project file drifted from template outside expected changes.
- `# Missing:` (red): Template files absent from the project.

When invoked with one or more match patterns, `compare` displays unified
diff lines indented beneath each matching file. Discrepancies are
informational, so `compare` exits 0 on drift or missing files.

Arguments:

- `<match>...`: Optional patterns filtering files to compare and diff.

## DICTIONARY

Wile provides trigram-based spell checking across `README.md`, `bin/*`, and
`lib/**/*.rb` via `test/tc_dictionary`. Words not recognized by the trigram
model are compared against the `.dictionary` whitelist:

    $ wile dictionary               # Check spelling and prompt to update
    $ wile dictionary --check       # Check only; exit 1 on unrecognized words
    $ wile dictionary --yes         # Auto-accept new words into .dictionary

Options:

- `-c`, `--check`: Run in check-only mode without prompting.
- `-y`, `--yes`: Answer yes to confirmation prompt (auto-accept updates).

## HELP

Wile scrapes task documentation directly from the header comments of
task source files in `.tasks/*.rb` and `lib/wile/tasks/*.rb`:

    $ wile help                     # Show help for help and list tasks
    $ wile help build               # Show detailed help for build task
    $ wile help order review        # Show help for multiple tasks

Arguments:

- `<task>...`: One or more task names or partial names to inspect. When
  omitted, Wile displays help for `help` and `list`.

## LEXICON

Wile enforces vocabulary control across `lib/**/*.rb` using AST parsing in
`test/tc_lexicon`. Every method name, identifier, and symbol is tracked in
`.lexicon` to prevent unintended API drift and subtle typos:

    $ wile lexicon                  # Inspect vocabulary drift and prompt
    $ wile lexicon --check          # Check only; exit 1 on new vocabulary
    $ wile lexicon --yes            # Auto-accept new vocabulary into .lexicon

Options:

- `-c`, `--check`: Run in check-only mode without prompting.
- `-y`, `--yes`: Answer yes to confirmation prompt (auto-accept updates).

## LIST

Wile lists available built-in and custom tasks with optional pattern
filtering and multiple output formats:

    $ wile list                     # List all tasks with usage syntax
    $ wile list dict lex            # Filter tasks matching patterns
    $ wile list --format=name       # Print task names only
    $ wile list --format=dictionary # Print dictionary-style task summaries

Arguments and options:

- `<match>...`: Optional patterns filtering task names.
- `--format=WORD`: Output format (`USAGE`, `DICTIONARY`, `NAME`, or `CODE`).
  Defaults to `USAGE`.

Formats:

- **USAGE**: Formatted task usage header with brief description comment
  (default).
- **DICTIONARY**: Concise list in `+ <task>: <description>` format.
- **NAME**: Bare task names only, suitable for shell completion and scripts.
- **CODE**: Unformatted usage comment lines extracted from task source files.

## NOTE

Wile scrapes project Ruby source files and prints every line containing
a `# NOTE` comment:

    $ wile note                     # Scrape NOTE comments in all Ruby files
    $ wile note order               # Scrape NOTE comments in matching files

Arguments:

- `<match>...`: Optional patterns filtering Ruby file paths. When omitted,
  all project Ruby files are inspected.

## NVIM

Wile opens the project's standard files in Neovim, ordered by internal
dependency rank (`README.md`, executable `bin/*` scripts, then `lib/**/*.rb`
in load order):

    $ wile nvim                     # Open all standard files in Neovim
    $ wile nvim tasks               # Open files matching "tasks"
    $ wile nvim --list              # List matching files without opening
    $ wile nvim tasks --list        # List files matching "tasks"

Arguments and options:

- `<match>...`: Optional patterns filtering file paths.
- `-l`, `--list`: Print file paths to stdout instead of launching Neovim.

## RUBY

Wile lists all Ruby files in the project, including `.rb` source files and
executable scripts with a Ruby shebang:

    $ wile ruby                     # List all project Ruby files
    $ wile ruby --git               # List only git-tracked Ruby files
    $ wile ruby tasks               # Filter files matching tasks
    $ wile ruby tasks --git         # Filter git files matching tasks

Arguments and options:

- `<match>...`: Optional patterns filtering file paths.
- `--git`: Inspect only files tracked by git.

## TC

Wile discovers and lists test cases located in `test/tc_*`:

    $ wile tc                       # List project custom unit tests
    $ wile tc wile                  # List Wile template quality gates
    $ wile tc all                   # List project and Wile tests
    $ wile tc all --raw             # Suppress headers and spaces
    $ wile tc help                  # Filter project tests matching "help"
    $ wile tc all rubo              # Filter across all tests

Arguments and options:

- `<scope>`: Optional target category: `project` (default), `wile`
  (template quality gates), or `all` (both categories).
- `<match>...`: Optional patterns filtering test file paths.
- `-r`, `--raw`: Suppress section headings and blank lines in `all` scope
  for piping to other commands.

When listing `project` tests, domain unit tests corresponding to ranked
`lib/` files (following the `tc_ut_<module>` convention) are listed first
in rank order, followed by any remaining custom unit tests. When `all` is
selected without `--raw`, tests are grouped under `# Project:` and
`# Wile:` headings.

## TESTING

Wile executes project test suites located in `test/**/tc_*`. The `test`
task supports targeted filtering by test file and test method name:

    $ wile test                     # Run all test suites
    $ wile test usage               # Run test files matching "usage"
    $ wile test usage init          # Run test methods matching "init"
    $ wile test --list              # List matching test files only
    $ wile test -q                  # Fault-only output (suppress dots)

Arguments and options:

- `<filematch>`: Optional pattern filtering test file paths.
- `<methodmatch>`: Optional pattern filtering test method names.
- `-l`, `--list`: Print matching test files without running them.
- `-q`, `--quiet`: Run with fault-only progress style.

## TODO

Wile displays project tasks from `TODO.md` or scrapes `# TODO` comments
from Ruby source files:

    $ wile todo                     # Display TODO.md items
    $ wile todo order               # Scrape TODO comments in matching files
    $ wile todo .                   # Scrape TODO comments across all files

When invoked without arguments, Wile displays `TODO.md` formatted with
`colora`. When invoked with one or more match patterns, Wile inspects
project Ruby files matching the patterns and prints their `# TODO` comments.

Arguments:

- `<match>...`: Optional patterns filtering Ruby file paths. When omitted,
  `TODO.md` is displayed.

## OPTIONS DICTIONARY

Wile maintains a canonical dictionary of CLI options and conventions.
When invoked with one or more options and no task, Wile queries this
dictionary:

    $ wile --format=json
    --format=json
      Description: Output format
      Pattern:     WORD (/\A[\w-]+\z/)
      Commands:    rubocop, reek, cucumber

For each flag, the dictionary reports:

- **Description**: The standard purpose of the flag.
- **Pattern**: The type name and regular expression (for flags taking a
  value).
- **Commands**: Established tools or tasks that use the flag.

Both active task flags and reserved flags for custom tasks can be
inspected. If an unrecognized flag is passed or an option value fails
pattern validation, an error is reported.

## SEE ALSO

`ruby`(1), `fish`(1), `tmux`(1)
