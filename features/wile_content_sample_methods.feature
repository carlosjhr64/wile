@wile_content
Feature: Testing wile content task with sample_methods fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content sample_methods.rb
    * Given option "content ./features/fixtures/sample_methods.rb"
    * When we run command
    * Then stdout is fixture 'sample_methods.txt'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample.rb --raw
    * Given option "content ./features/fixtures/sample_methods.rb --raw"
    * When we run command
    * Then stdout is fixture 'sample_methods.raw'
    * Then exit status is "0"
    * Then stderr is ""

  Scenario: content sample.rb --dump
    * Given option "content ./features/fixtures/sample_methods.rb --dump"
    * When we run command
    * Then stdout is fixture 'sample_methods.sexp'
    * Then exit status is "0"
    * Then stderr is "# ./features/fixtures/sample_methods.rb"
