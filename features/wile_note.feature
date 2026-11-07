@wile_note
Feature: Testing wile note task

  Background:
    * Given command "./bin/wile"

  Scenario: note
    * Given option "note"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is ""

  Scenario: note with matcher
    * Given option "note sample_note"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "features/fixtures/sample_note.rb"
    * Then stdout includes "# NOTE: Example note for testing wile note task"

  Scenario: note with non-matching pattern
    * Given option "note nonexistent_xyz"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is ""

  Scenario: note with disallowed option
    * Given option "note --dump"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes one or more arguments."
