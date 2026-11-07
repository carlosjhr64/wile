@wile_options_dictionary
Feature: Testing wile flag dictionary

  Background:
    * Given command "./bin/wile"

  Scenario: --batch
    * Given option "--batch"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "--batch"
    * Then stdout includes "Description: Run in non-interactive batch mode"
    * Then stdout includes "Commands:    sed, make, git"

  Scenario: Typed flag with pattern
    * Given option "--format=json"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "--format=json"
    * Then stdout includes "Description: Output format"
    * Then stdout includes "Pattern:     WORD (/\A[\w-]+\z/)"
    * Then stdout includes "Commands:    rubocop, reek, cucumber"

  Scenario: Short flag alias
    * Given option "-a"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "--all"
    * Then stdout includes "Description: Apply to all targets"
    * Then stdout includes "Commands:    ls, du, df, git"

  Scenario: Multiple flags
    * Given option "--batch --archive"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "--batch"
    * Then stdout includes "--archive"

  Scenario: Unrecognized flag
    * Given option "--foo"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Unrecognized:  foo"

  Scenario: Invalid flag pattern
    * Given option "--context=abc"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "--context=abc !~ INTEGER=/\A\d+\z/"
