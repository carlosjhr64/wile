# wile(1) -- prescriptive task dispatcher for Ruby gem projects

## SYNOPSIS

`wile` [<task>] [<args>...] [:<options>...]

## DESCRIPTION

**Wile** is a prescriptive task dispatcher for Ruby gem projects,
built around a living project template.

It scaffolds new projects from the template, keeps existing ones
aligned with it, and automates workflow steps -- gemspec upkeep,
testing, and release.

## GET STARTED

- `wile`: Display manual page.
- `wile list`: List all available tasks.
- `wile help [<task>]`: Show help for task(s).
- `wile test`: Run project test suites.

## GLOBAL OPTIONS

- `-h`, `--help`: Show help summary.
- `-v`, `--version`: Show version number.
- `-a`, `--all`: Apply to all targets.
- `-c`, `--check`: Run in check-only mode.
- `--config=FILE`: Configuration file path.
- `--detailed`: Display detailed output.
- `-d`, `--dump`: Dump internal structure or data.
- `-f`, `--force`: Force execution without safety checks.
- `--format=WORD`: Output format.
- `-l`, `--list`: List items.
- `--name=WORD`: Filter or match by name.
- `--output=FILE`: Write output to file.
- `-q`, `--quiet`: Suppress non-essential output.
- `-r`, `--raw`: Raw / unformatted output.
- `--simulate`: Simulate execution without making changes.
- `-s`, `--strict`: Enable strict mode.
- `-t`, `--trace`: Trace execution.
- `-y`, `--yes`: Assume yes to confirmation prompts.

## TASKS

Run `wile list` to list all tasks, or `wile help <task>` for details.

- **build**: Build gem package into pkg/.
- **bump**: Bump project version number.
- **compare**: Compare project files with template.
- **content**: Inspect ruby file structure and methods.
- **cp**: Copy template files into project.
- **dependencies**: List ruby dependencies.
- **dictionary**: Manage spelling dictionary.
- **gemcheck**: Check for missing gems across rbenv Rubies.
- **gemfile**: Generate Gemfile from dependencies.
- **help**: Show detailed help for tasks.
- **info**: Display project metadata and configuration.
- **install**: Build and install gem locally.
- **lexicon**: View and update vocabulary whitelist.
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
- **test**: Run test suites.
- **todo**: Scrape files for TODO comments.
- **update**: Update README and gemspec.
