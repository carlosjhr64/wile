@wile_bump
Feature: Testing wile bump task

  Background:
    * Given command "./bin/wile"

  Scenario: bump with invalid argument
    * Given option "bump invalid"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes one argument (major|minor|build)."

  Scenario: bump with too many arguments
    * Given option "bump major minor"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes one argument (major|minor|build)."

  Scenario: bump with disallowed option
    * Given option "bump --force"
    * When we run command
    * Then exit status is "64"
    * Then stderr includes "Optionally takes one argument (major|minor|build)."
