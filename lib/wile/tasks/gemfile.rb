# frozen_string_literal: true

# ## wile gemfile ##
# Generates project Gemfile from dependencies.
# Options:
#   --dump       prints Gemfile to stdout instead of writing
# Usage:
#   wile gemfile [--dump] # generate Gemfile from dependencies
module Wile
  # This file is loaded upon a :gemfile task request.
  class Tasks
    GEMFILE_USAGE = [
      'gemfile: Takes no arguments with optional dump flag.',
      0, Set['dump']
    ].freeze

    def gemfile(options, gemspec = nil, file = 'Gemfile')
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      Usage.new(options, *GEMFILE_USAGE)
      gemspec ||= Gemspec.new
      GemfileWriter.new(gemspec, file, options).write
    end
  end

  # Builds and writes a project Gemfile from gemspec dependencies.
  class GemfileWriter
    def initialize(gemspec = Gemspec.new, file = 'Gemfile', options = nil)
      @gemspec = gemspec
      @file = file
      @options = options
    end

    def self.format_gems(gems)
      gems.map { "gem '#{it.name}'" }.uniq
    end

    def write
      @options&.dump? ? puts(content) : File.write(@file, content)
    end

    private

    def content
      run = GemfileWriter.format_gems(@gemspec.rungems)
      dev = GemfileWriter.format_gems(@gemspec.devgems) - run
      [
        "source 'https://rubygems.org'",
        '## runtime ##',
        *run.sort,
        '## development ##',
        *dev.sort
      ].join("\n") << "\n"
    end
  end
end
