@wile_todo
Feature: Testing wile todo task

  Background:
    * Given command "./bin/wile"

  Scenario: todo
    * Given option "todo"
    * When we run command
    * Then exit status is "0"
    * Then stdout includes "# TODO"

  Scenario: todo with matcher
    * Given option "todo sample_todo"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "features/fixtures/sample_todo.rb"
    * Then stdout includes "# TODO: Example todo for testing wile todo task"

  Scenario: todo with non-matching pattern
    * Given option "todo nonexistent_xyz"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is ""

  Scenario: todo with disallowed option
    * Given option "todo --dump"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes one or more arguments."
