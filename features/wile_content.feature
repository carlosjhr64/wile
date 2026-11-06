@wile_content
Feature: Testing wile content task

  Background:
    * Given command "./bin/wile"

  Scenario: content
    * Given option "content features/fixtures/sample.rb"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "features/fixtures/sample.rb"

  Scenario: content with raw option
    * Given option "content features/fixtures/sample.rb -r"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "casgn A::B::C lambda"
    * Then stdout includes "def A::B#initialize"

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

  Scenario: content method definitions and operator methods
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

  Scenario: content on non-existent file
    * Given option "content nonexistent_file_xyz.rb"
    * When we run command
    * Then exit status is "1"
    * Then stderr includes "File not found: nonexistent_file_xyz.rb"
    * Then stderr includes "No files selected."

  Scenario: content with disallowed option
    * Given option "content features/fixtures/sample.rb --check"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes one or more filenames."
