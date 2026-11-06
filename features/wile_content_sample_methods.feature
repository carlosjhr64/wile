@wile_content
Feature: Testing wile content task with sample_methods fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content method definitions and visibility
    * Given option "content features/fixtures/sample_methods.rb -r"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "def SampleMethods::Worker.build"
    * Then stdout includes "def SampleMethods::Worker#initialize"
    * Then stdout includes "def SampleMethods::Worker#run"
    * Then stdout includes "def SampleMethods::Worker#[]"
    * Then stdout includes "def SampleMethods::Worker#valid?"
    * Then stdout includes "def SampleMethods::Worker#reset!"
    * Then stdout includes "#private"
    * Then stdout includes "def SampleMethods::Worker#secret"
    * Then stdout includes "def SampleMethods::Uninitialized.spawn"
    * Then stdout includes "def SampleMethods::Uninitialized#status"
