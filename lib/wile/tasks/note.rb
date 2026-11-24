# frozen_string_literal: true

# ## wile note ##
# Puts each NOTE line.
# Usage:
#   wile note [<match>+] # scrape ruby files for NOTE comments
module Wile
  # This file is loaded upon a :note task request.
  class Tasks
    NOTE_USAGE = ['note: Optionally takes one or more arguments.', Set[]].freeze

    def note(options)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      match = Usage.new(options, *NOTE_USAGE).args
      NoteLister.new(match).display
    end
  end

  # Greps project Ruby files for NOTE comments.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::NoteLister
    using UtilitiesRefinements

    def initialize(match = nil)
      @match = match
    end

    def self.display_file(filename)
      lines = File.foreach(filename).grep(/#\s*NOTE/)
      puts filename.blue, lines unless lines.empty?
    end

    def display
      selected_files.each { self.class.display_file(it) }
    end

    private

    def selected_files
      files = Project.rbfiles.weird_filename!
      return files.reject { it.start_with?('features/fixtures/') } unless @match

      files.grep(Regexp.union(@match.map { Regexp.new(it) }))
    end
  end
  Tasks.private_constant :NoteLister
end
