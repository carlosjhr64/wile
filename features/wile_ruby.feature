@wile_ruby
Feature: Testing wile ruby task

  Background:
    * Given command "./bin/wile"

  Scenario: ruby
    * Given option "ruby"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "bin/wile"
    * Then stdout includes "lib/wile.rb"

  Scenario: ruby --git
    * Given option "ruby --git"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "bin/wile"
    * Then stdout includes "lib/wile.rb"

  Scenario: ruby with matcher
    * Given option "ruby tasks/ruby.rb"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "lib/wile/tasks/ruby.rb"
    * Then stdout does not include "lib/wile/tasks/note.rb"

  Scenario: ruby with matcher and --git
    * Given option "ruby tasks/ruby.rb --git"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "lib/wile/tasks/ruby.rb"
    * Then stdout does not include "lib/wile/tasks/note.rb"

  Scenario: ruby with positional git argument
    * Given option "ruby git tasks/ruby.rb"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "lib/wile/tasks/ruby.rb"
    * Then stdout does not include "lib/wile/tasks/note.rb"

  Scenario: ruby with non-matching pattern
    * Given option "ruby nonexistent_xyz"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is ""

  Scenario: ruby with disallowed option
    * Given option "ruby --dump"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes file matchers"
