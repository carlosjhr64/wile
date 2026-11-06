@wile_content
Feature: Testing wile content task with sample_scopes fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content scopes, top-level definitions, and singleton class
    * Given option "content features/fixtures/sample_scopes.rb -r"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "def #toplevel_work"
    * Then stdout includes "casgn SampleScopes::SCOPED_LIMIT int"
    * Then stdout includes "def SampleScopes::CompactNested#perform"
    * Then stdout includes "def SampleScopes::SingletonService.activate"
    * Then stdout includes "def #toplevel_call"
    * Then stdout includes "File.exist?"
    * Then stdout includes "end"
