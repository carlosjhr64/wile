@wile_content
Feature: Testing wile content task with sample_calls fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content stdlib and kernel call resolution
    * Given option "content features/fixtures/sample_calls.rb"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "SampleCalls::CONFIG hash"
    * Then stdout includes "SampleCalls::PATTERN regexp"
    * Then stdout includes "File.exist?"
    * Then stdout includes "#puts"
    * Then stdout includes "#warn"
    * Then stdout includes "CONFIG.fetch"
    * Then stdout includes "PATTERN.match?"
    * Then stdout includes "#perform"
