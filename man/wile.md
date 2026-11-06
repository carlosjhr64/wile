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
- **compare**: Compare project files with template.
- **content**: Inspect ruby file structure and methods.
- **cp**: Copy template files into project.
- **dependencies**: List ruby dependencies.
- **dictionary**: Manage spelling dictionary (see **DICTIONARY**).
- **gemcheck**: Check for missing gems across rbenv Rubies.
- **gemfile**: Generate Gemfile from dependencies.
- **help**: Show detailed help for tasks.
- **info**: Display project metadata and configuration.
- **install**: Build and install gem locally.
- **lexicon**: View and update vocabulary whitelist (see **LEXICON**).
- **list**: List all tasks or filter by pattern.
- **mkdir**: Create project directory from template.
- **note**: Scrape ruby files for NOTE comments.
- **nvim**: Open project files in Neovim.
- **order**: Suggest method ordering in ruby files.
- **publish**: Publish new version to RubyGems.
- **requirements**: Verify system commands and versions.
- **review**: Run code review checklist.
- **ruby**: List all ruby files in project or git.
- **smell**: Classify method dependencies and smells.
- **tc**: List custom unit tests.
- **test**: Run test suites (see **TESTING**).
- **todo**: Scrape files for TODO comments.
- **update**: Update project files.

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
- **Commands**: Established Linux tools that use the flag.

Both active task flags and reserved flags for custom tasks can be
inspected. If an unrecognized flag is passed or an option value fails
pattern validation, an error is reported.

## SEE ALSO

`ruby`(1), `fish`(1), `tmux`(1)
