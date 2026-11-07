# frozen_string_literal: true

# ## wile note ##
# Puts each NOTE line.
# Usage:
#   wile note [<match>+] # scrape ruby files for NOTE comments
module Wile
  # This file is loaded upon a :note task request.
  class Tasks
    using UtilitiesRefinements

    NOTE_USAGE = ['note: Optionally takes one or more arguments.', Set[]].freeze

    # :reek:TooManyStatements
    def note(options)
      Utilities.verify_project_root!
      match = Usage.new(options, *NOTE_USAGE).args
      files = Project.rbfiles.weird_filename!
      files = files.reject { it.start_with?('features/fixtures/') } unless match
      files.each do |fn|
        next if match&.none? { fn.match? it }

        lines = File.foreach(fn).grep(/#\s*NOTE/)
        puts fn.blue, lines unless lines.empty?
      end
    end
  end
end
