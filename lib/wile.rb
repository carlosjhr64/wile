# frozen_string_literal: true

## Standard libraries:
require 'English'
require 'tmpdir'
autoload :Digest,     'digest'
autoload :Find,       'find'
autoload :Shellwords, 'shellwords'
autoload :FileUtils,  'fileutils'
autoload :JSON,       'json'
autoload :ERB,        'erb'
autoload :Prism,      'prism'
autoload :RbConfig,   'rbconfig'

## Third-party gems:
autoload :HelpParser, 'help_parser'
require 'colorize'

# The Wile module is the main namespace for the Wile application.
module Wile
  ROOT = File.expand_path('..', __dir__)
  VERSION = '0.2.261028'
  autoload :Run,        File.join(__dir__, 'wile/run')
  autoload :Sysexits,   File.join(__dir__, 'wile/sysexits')
  autoload :Refinement, File.join(__dir__, 'wile/refinement')
  autoload :Utilities,  File.join(__dir__, 'wile/utilities')
end
