@wile_tc
Feature: Testing wile tc task

  Background:
    * Given command "./bin/wile"

  Scenario: tc
    * Given option "tc"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "test/tc_ut_tasks"

  Scenario: tc wile
    * Given option "tc wile"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "test/tc_comments"
    * Then stdout includes "test/tc_rubocop"

  Scenario: tc all
    * Given option "tc all"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "# Project:"
    * Then stdout includes "test/tc_ut_tasks"
    * Then stdout includes "# Wile:"
    * Then stdout includes "test/tc_comments"

  Scenario: tc all with raw option
    * Given option "tc all --raw"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "test/tc_ut_tasks"
    * Then stdout includes "test/tc_comments"
    * Then stdout does not include "# Project:"
    * Then stdout does not include "# Wile:"

  Scenario: tc with match pattern
    * Given option "tc help"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "test/tc_ut_help"

  Scenario: tc all with match pattern
    * Given option "tc all rubo"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "# Wile:"
    * Then stdout includes "test/tc_rubocop"

  Scenario: tc with non-matching pattern
    * Given option "tc nonexistent_pattern_xyz"
    * When we run command
    * Then exit status is "0"
    * Then stderr includes "No tests matched: nonexistent_pattern_xyz"

  Scenario: tc with disallowed option
    * Given option "tc --check"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes scope (project, wile, all)"
