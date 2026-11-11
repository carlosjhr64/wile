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
- **content**: Inspect ruby file structure and methods (see **CONTENT**).
- **cp**: Copy template files into project (see **CP**).
- **dependencies**: List ruby dependencies.
- **dictionary**: Manage spelling dictionary (see **DICTIONARY**).
- **gemcheck**: Check for missing gems across rbenv Rubies.
- **gemfile**: Generate Gemfile from dependencies.
- **help**: Show detailed help for tasks (see **HELP**).
- **info**: Display project metadata and configuration (see **INFO**).
- **install**: Build and install gem locally.
- **lexicon**: View and update vocabulary whitelist (see **LEXICON**).
- **list**: List all tasks or filter by pattern (see **LIST**).
- **mkdir**: Create project directory from template (see **MKDIR**).
- **note**: Scrape ruby files for NOTE comments (see **NOTE**).
- **nvim**: Open project files in Neovim (see **NVIM**).
- **order**: Suggest method ordering in ruby files (see **ORDER**).
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

## CONTENT

Wile inspects Ruby source files, displaying class, module, and method
definitions alongside their line counts and referenced dependency calls:

    $ wile content lib/foo.rb       # Inspect method line counts and calls
    $ wile content lib/foo.rb --raw # Display raw line counts and definitions
    $ wile content lib/foo.rb --dump # Dump parse tree as S-expressions

Output details:

- **Method line counts**: Beside each method definition, Wile displays the
  number of lines in the method (in green). The count includes the `def` header
  and all body lines, excluding only the closing `end` keyword.
- **Referenced dependencies**: Indented lines beneath a method show calls
  and constants referenced within its body, color-coded by resolution.

Arguments and options:

- `<filename>+`: One or more Ruby source files to inspect.
- `--raw`: Display plain method line counts and definitions without color.
- `--dump`: Dump internal S-expression AST structure to stdout with source
  header on stderr.

## CP

Wile copies template files from the living template cache into the project
directory, keeping scaffolded files synchronized with upstream enhancements:

    $ wile cp                       # Copy all missing template files
    $ wile cp test                  # Copy template files matching pattern
    $ wile cp .rubocop.yml --force  # Overwrite existing project file
    $ wile cp --trace               # Show skipped and copied files

Template behavior:

- **ERB templates**: Template files ending in `.erb` are evaluated in the
  project context, replacing project placeholders and removing the `.erb`
  extension upon copying.
- **Safety**: Existing project files are skipped by default. Pass `--force`
  to overwrite existing files with fresh template copies.

Arguments and options:

- `<match>`: Optional pattern filtering which template files to copy.
- `-f`, `--force`: Overwrite existing files in the project.
- `-t`, `--trace`: Trace execution, displaying skipped files in grey and
  copied files in green.

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

## INFO

Wile displays project metadata, description, and dependency configuration
synthesized from project dotfiles, `README.md`, and gemspec specifications:

    $ wile info                     # Display project metadata and gems

Sections displayed:

- **Header**: Project name, version number, and author username.
- **Description**: Project summary extracted from the description section of
  `README.md`.
- **Files**: Complete listing of tracked project files packaged into the gem.
- **Executables**: Executables located under `bin/`.
- **Runtime gems**: Third-party gems and versions required at runtime.
- **Development gems**: Dependencies required during development and testing.

`wile info` takes no arguments and must be executed from the project root.

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

## MKDIR

Wile creates a new Ruby gem project directory scaffolded from the living
template in `cache/`:

    $ wile mkdir my_gem             # Create new project directory

Arguments:

- `<dirname>`: Exactly one argument specifying the new project directory
  name. Must contain only letters, numbers, underscores, or hyphens
  (`[a-zA-Z0-9_-]`).

Scaffolding steps:

1. **Safety Check**: Verifies that `<dirname>` does not already exist in the
   target path.
2. **Template Copy**: Copies the template structure from `cache/` into the
   new project directory.
3. **Template Evaluation**: Evaluates all `.erb` files (such as
   `README.md.erb`, `bin/project.erb`, and `lib/project.rb.erb`), substituting
   the project name, PascalCase module name, Git author credentials, year, and
   date.
4. **Path Renaming**: Renames template source and executable files (e.g.
   `bin/project` and `lib/project.rb`) to match the project name, and deletes
   the `.erb` templates.
5. **Git Initialization**: Initializes a new Git repository (`git init`) and
   installs template Git hooks (such as `.git/hooks/pre-commit`).

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

## ORDER

Wile analyzes call dependencies and method line lengths within a Ruby
source file to suggest an optimal top-to-bottom method order. The
optimization minimizes the line distance between callers and their
dependencies (preferring callees above callers) and breaks ties with
alphabetical ordering:

    $ wile order lib/foo.rb         # Suggest method order using default (bcmv)
    $ wile order lib/foo.rb bprm    # Suggest order using best permutation
    $ wile order lib/foo.rb dump    # Dump method data and index as JSON
    $ wile order lib/foo.rb qc      # Check dependency integrity and cycles

When suggestions are found, Wile prints each method name alongside
movement indicators:

- `↑N` (arrow up): Method moved up by N positions from its original place.
- `↓N` (arrow down): Method moved down by N positions from its original place.

Wile exits 0 when the file is already in optimal order, or 1 when reordering
is suggested.

Sort methods:

- **bcmv** (default): Best combination move. Evaluates relocating any
  method to any position (insert and shift), committing the single best
  move per round until no move reduces total distance.
- **nswp**: Neighbour swap. Fast first-improvement pass that sweeps
  forward and backward through adjacent method pairs, swapping immediately
  upon any score improvement.
- **cswp**: Combination swap. First-improvement pass that tests all pairs
  `(i, j)` and swaps them immediately upon any score improvement.
- **bnswp**: Best neighbour swap. Evaluates all adjacent pairs `(i, i+1)`
  and commits the single best adjacent swap per round.
- **bcswp**: Best combination swap. Evaluates all possible pairs `(i, j)`
  across the file and commits the single best swap per round.
- **bprm**: Best permutation. Exhaustive search across a sliding window of
  7 methods (5,040 permutations per step) sweeping forward and backward
  until convergence. Reaches global optimum for files with <= 7 methods.

Special subcommands:

- **dump**: Print parsed method definitions, sizes, and dependency index
  as formatted JSON.
- **index**: Print method call-site line offsets for each dependency.
- **isolate**: Print methods that neither call nor are called by other
  methods in the file.
- **total**: Print the file's total valuation score with a detailed trace
  of alphabetical and dependency distances.
- **qc**: Quality check dependency symmetry and detect circular
  dependencies. Exits 65 (EX_DATAERR) if errors are found.

Arguments:

- `<filename>`: Path to the Ruby source file to analyze.
- `<sort-type|special>`: Optional sort algorithm or special subcommand.
  Defaults to `bcmv`.

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
