# frozen_string_literal: true

## Standard libraries:
require 'English'
require 'find'
autoload :FileUtils, 'fileutils'
autoload :JSON,      'json'
autoload :ERB,       'erb'
## Third-party gems:
require 'colorize'
autoload :Prism, 'prism'
## Also:
# require 'test/unit'
## Local libraries:
require_relative 'refinement'
require_relative 'help'
require_relative 'usage'
require_relative 'tasks'
