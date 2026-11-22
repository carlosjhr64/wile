@wile_content
Feature: Testing wile content task with sample_operators fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content sample_operators.rb
    * Given option "content ./features/fixtures/sample_operators.rb"
    * When we run command
    * Then stdout is fixture 'sample_operators.txt'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample_operators.rb --raw
    * Given option "content ./features/fixtures/sample_operators.rb --raw"
    * When we run command
    * Then stdout is fixture 'sample_operators.raw'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample_operators.rb --dump
    * Given option "content ./features/fixtures/sample_operators.rb --dump"
    * When we run command
    * Then stdout is fixture 'sample_operators.sexp'
    * Then exit status is "0"
    * Then stderr is "# ./features/fixtures/sample_operators.rb"
