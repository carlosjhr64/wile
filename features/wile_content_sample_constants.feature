@wile_content
Feature: Testing wile content task with sample_constants fixture

  Background:
    * Given command "./bin/wile"

  Scenario: content constant types
    * Given option "content features/fixtures/sample_constants.rb -r"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "casgn SampleConstants::LAMBDA lambda"
    * Then stdout includes "casgn SampleConstants::STR str"
    * Then stdout includes "casgn SampleConstants::TEXT str"
    * Then stdout includes "casgn SampleConstants::RATE float"
    * Then stdout includes "casgn SampleConstants::COUNT int"
    * Then stdout includes "casgn SampleConstants::MAP hash"
    * Then stdout includes "casgn SampleConstants::REGEX regexp"
    * Then stdout includes "casgn SampleConstants::LIST array"
    * Then stdout includes "casgn SampleConstants::STATUS sym"
    * Then stdout includes "casgn SampleConstants::Pair Struct"
    * Then stdout includes "casgn SampleConstants::CUSTOM Object"
