# frozen_string_literal: true

## Standard libraries:
require 'English'
autoload :Find,       'find'
autoload :Shellwords, 'shellwords'
autoload :FileUtils,  'fileutils'
autoload :JSON,       'json'
autoload :ERB,        'erb'
autoload :Prism,      'prism'

## Third-party gems:
autoload :HelpParser, 'help_parser'
require 'colorize'

# The Wile module is the main namespace for the Wile application.
module Wile
  ROOT = File.expand_path('..', __dir__)
  VERSION = File.read("#{ROOT}/.version").chomp
  autoload :Run,        'wile/run'
  autoload :Sysexits,   'wile/sysexits'
  autoload :Refinement, 'wile/refinement'
end
