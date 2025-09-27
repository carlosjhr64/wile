# frozen_string_literal: true

# ## wile gemfile ##
# Outputs to STDOUT a Gemfile.
# If the 'git' token is given, then
# it will only look at ruby files in git.
# Usage:
#   wile gemfile [git] # list ruby gems as in Gemfile
module Wile
  # This file is loaded upon a :gemfile task request.
  class Tasks
    GEMFILE_USAGE = ['gemfile: Optionally only "git" as an argument.',
                     (..1), /^git$/, Set[]].freeze

    # :reek:DuplicateMethodCall on attributes
    # :reek:TooManyStatements
    def gemfile(options)
      token, = Usage.new(options, *GEMFILE_USAGE).args
      gemspec = Gemspec.new(token: token)
      run = gemspec.rungems.map { "gem '#{it.name}'" }.uniq
      dev = gemspec.devgems.map { "gem '#{it.name}'" }.uniq
      dev -= run
      output_gemfile(run, dev)
    end

    private

    # :reek:TooManyStatements
    def output_gemfile(run, dev)
      puts "source 'https://rubygems.org'"
      puts "ruby '#{RUBY_VERSION}'"
      puts '## runtime ##'
      puts run.sort
      puts '## development ##'
      puts dev.sort
    end
  end
end
