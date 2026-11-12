# frozen_string_literal: true

# ## wile gemfile ##
# Generates project Gemfile from dependencies.
# Usage:
#   wile gemfile # generate Gemfile from dependencies
module Wile
  # This file is loaded upon a :gemfile task request.
  class Tasks
    GEMFILE_USAGE = ['gemfile: Takes no arguments.', 0, Set[]].freeze

    # :reek:UtilityFunction
    def gemfile(options, gemspec = nil, file = 'Gemfile')
      Utilities.verify_project_root!
      Usage.new(options, *GEMFILE_USAGE)
      gemspec ||= Gemspec.new
      File.write(file, gemfile_content(gemspec))
    end

    private

    # :reek:UtilityFunction
    def format_gems(gems)
      gems.map { "gem '#{it.name}'" }.uniq
    end

    # :reek:FeatureEnvy :reek:UtilityFunction
    def gemfile_content(gemspec)
      run = format_gems(gemspec.rungems)
      dev = format_gems(gemspec.devgems) - run
      [
        "source 'https://rubygems.org'",
        "ruby file: '.ruby-version'",
        '## runtime ##',
        *run.sort,
        '## development ##',
        *dev.sort
      ].join("\n") << "\n"
    end
  end
end
