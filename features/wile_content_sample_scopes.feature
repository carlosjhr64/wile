@wile_content
Feature: Testing wile content task with sample_scopes fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content sample_scopes.rb
    * Given option "content ./features/fixtures/sample_scopes.rb"
    * When we run command
    * Then stdout is fixture 'sample_scopes.txt'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample.rb --raw
    * Given option "content ./features/fixtures/sample_scopes.rb --raw"
    * When we run command
    * Then stdout is fixture 'sample_scopes.raw'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample.rb --dump
    * Given option "content ./features/fixtures/sample_scopes.rb --dump"
    * When we run command
    * Then stdout is fixture 'sample_scopes.dump'
    * Then exit status is "0"
    * Then stderr is "# ./features/fixtures/sample_scopes.rb"
