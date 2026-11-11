# frozen_string_literal: true

# ## wile gemfile ##
# Outputs to STDOUT a Gemfile.
# If the 'git' token is given, then
# it will only look at ruby files in git.
# Primary use:
#   wile gemfile > Gemfile
# Usage:
#   wile gemfile [git] # list ruby gems as in Gemfile
module Wile
  # This file is loaded upon a :gemfile task request.
  class Tasks
    GEMFILE_USAGE = ['gemfile: Optionally only "git" as an argument.',
                     (..1), /^git$/, Set[]].freeze

    # :reek:UtilityFunction
    def gemfile(options, gemspec = nil, io: $stdout)
      Utilities.verify_project_root!
      token = Usage.new(options, *GEMFILE_USAGE).args&.first
      gemspec ||= Gemspec.new(token:)
      run = format_gems(gemspec.rungems)
      output_gemfile(run, format_gems(gemspec.devgems) - run, io:)
    end

    private

    # :reek:UtilityFunction
    def format_gems(gems)
      gems.map { "gem '#{it.name}'" }.uniq
    end

    # :reek:UtilityFunction
    def output_gemfile(run, dev, io: $stdout)
      io.puts "source 'https://rubygems.org'",
              "ruby file: '.ruby-version'",
              '## runtime ##',
              *run.sort,
              '## development ##',
              *dev.sort
    end
  end
end
