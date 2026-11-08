@wile_content
Feature: Testing wile content task with sample_refinements fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content sample_refinements.rb
    * Given option "content ./features/fixtures/sample_refinements.rb"
    * When we run command
    * Then stdout is fixture 'sample_refinements.txt'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample_refinements.rb --raw
    * Given option "content ./features/fixtures/sample_refinements.rb --raw"
    * When we run command
    * Then stdout is fixture 'sample_refinements.raw'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample_refinements.rb --dump
    * Given option "content ./features/fixtures/sample_refinements.rb --dump"
    * When we run command
    * Then stdout is fixture 'sample_refinements.sexp'
    * Then exit status is "0"
    * Then stderr is "# ./features/fixtures/sample_refinements.rb"
