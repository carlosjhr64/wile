# frozen_string_literal: true

## Standard libraries:
require 'English'
require 'tmpdir'
autoload :Digest,     'digest'
autoload :ERB,        'erb'
autoload :Etc,        'etc'
autoload :FileUtils,  'fileutils'
autoload :Find,       'find'
autoload :JSON,       'json'
autoload :Prism,      'prism'
autoload :RbConfig,   'rbconfig'
autoload :Shellwords, 'shellwords'

## Third-party gems:
autoload :HelpParser, 'help_parser'
require 'colorize'
# wile: require 'tmuxinator'

String.disable_colorization = true unless $stdout.tty? &&
                                          ENV['NO_COLOR'].to_s.empty? &&
                                          ENV['TERM'] != 'dumb'

# The Wile module is the main namespace for the Wile application.
module Wile
  ROOT = File.expand_path('..', __dir__)
  VERSION = '0.4.261113' # Must match .version
  autoload :Run,       File.join(__dir__, 'wile/run')
  autoload :Sysexits,  File.join(__dir__, 'wile/sysexits')
  autoload :Utilities, File.join(__dir__, 'wile/utilities')
  # autoload 'wile/utilities_refinements'
  autoload :UtilitiesRefinements,
           File.join(__dir__, 'wile/utilities_refinements')
  # autoload 'wile/wile_refinements'
  autoload :WileRefinements,
           File.join(__dir__, 'wile/wile_refinements')
end
