@wile_nvim
Feature: Testing wile nvim task

  Background:
    * Given command "./bin/wile"

  Scenario: nvim with list option
    * Given option "nvim --list"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "README.md"
    * Then stdout includes "bin/wile"
    * Then stdout includes "lib/wile.rb"

  Scenario: nvim with match pattern and list option
    * Given option "nvim tasks --list"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "lib/wile/tasks.rb"

  Scenario: nvim with non-matching pattern and list option
    * Given option "nvim nonexistent_pattern_xyz --list"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is ""

  Scenario: nvim with non-matching pattern
    * Given option "nvim nonexistent_pattern_xyz"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "No files matched: nonexistent_pattern_xyz"

  Scenario: nvim with disallowed option
    * Given option "nvim --check"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes one or more arguments."
