@wile_gemfile
Feature: Testing wile gemfile task

  Background:
    * Given command "./bin/wile"

  Scenario: gemfile --dump
    * Given option "gemfile --dump"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "source 'https://rubygems.org'"
    * Then stdout includes "## runtime ##"
    * Then stdout includes "## development ##"

  Scenario: gemfile --dump matches Gemfile
    * Given option "gemfile --dump"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout is fixture 'Gemfile'

  Scenario: gemfile with disallowed argument
    * Given option "gemfile extra"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional dump flag."

  Scenario: gemfile with disallowed option
    * Given option "gemfile --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Takes no arguments with optional dump flag."
