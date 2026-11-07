@wile_content
Feature: Testing wile content task with sample_scopes fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content sample_scopes.rb
    * Given option "content ./features/fixtures/sample_scopes.rb"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is fixture 'sample_scopes.txt'

  Scenario: content sample.rb --raw
    * Given option "content ./features/fixtures/sample_scopes.rb --raw"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is fixture 'sample_scopes.raw'

  Scenario: content sample.rb --dump
    * Given option "content ./features/fixtures/sample_scopes.rb --dump"
    * When we run command
    * Then exit status is "0"
    * Then stderr is "# ./features/fixtures/sample_scopes.rb"
    * Then stdout is fixture 'sample_scopes.dump'
