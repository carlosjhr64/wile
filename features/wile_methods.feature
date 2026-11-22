@wile_methods
Feature: Testing wile methods task

  Background:
    * Given command "./bin/wile"

  Scenario: methods with --name=shared
    * Given option "methods --name=shared"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "## Shared ##"
    * Then stdout does not include "## Unused ##"
    * Then stdout does not include "## Reused ##"

  Scenario: methods with --name=reused
    * Given option "methods --name=reused"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "## Reused ##"
    * Then stdout does not include "## Shared ##"

  Scenario: methods with pattern match
    * Given option "methods Sysexits"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "# Matching: /Sysexits/"
    * Then stdout includes "Wile::Sysexits"

  Scenario: methods with --name=undefined
    * Given option "methods --name=undefined"
    * When we run command
    * Then exit status is "0"
    * Then stderr is ""
    * Then stdout includes "## Undefined ##"
    * Then stdout does not include "## Shared ##"

  Scenario: methods with disallowed option
    * Given option "methods --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes one or more arguments."
