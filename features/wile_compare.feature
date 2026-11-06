@wile_compare
Feature: Testing wile compare task

  Background:
    * Given command "./bin/wile"

  Scenario: compare
    * Given option "compare"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "# Found:"
    * Then stdout includes "README.md"

  Scenario: compare with file matcher
    * Given option "compare README"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "# Found:"
    * Then stdout includes "README.md"

  Scenario: compare with non-matching pattern
    * Given option "compare nonexistent_file_xyz"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "No match: nonexistent_file_xyz"

  Scenario: compare with disallowed option
    * Given option "compare --trace"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes one or more file matchers."
