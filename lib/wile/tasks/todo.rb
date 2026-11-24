# frozen_string_literal: true

# wile: os `colora`

# ## wile todo ##
# Puts TODO.md's bullet lines.
# If match, greps matching ruby files for TODO's.
# Usage:
#   wile todo [<match>+] # display TODO.md or scrape TODO comments
module Wile
  # This file is loaded upon a :todo task request.
  class Tasks
    TODO_USAGE = ['todo: Optionally takes one or more arguments.', Set[]].freeze

    def todo(options)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      match = Usage.new(options, *TODO_USAGE).args
      TodoLister.new(match).display
    end
  end

  # Displays TODO.md or greps project Ruby files for TODO comments.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::TodoLister
    using UtilitiesRefinements

    def initialize(match = nil)
      @match = match
    end

    def self.display_file(filename)
      lines = File.foreach(filename).grep(/#\s*TODO/)
      puts filename.blue, lines unless lines.empty?
    end

    def display
      return system('colora', '--on=^#\\sTODO', '--off=^#', 'TODO.md') if
        File.file?('TODO.md') && !@match

      selected_files.each { self.class.display_file(it) }
    end

    private

    def selected_files
      files = Project.rbfiles.weird_filename!
      return files.reject { it.start_with?('features/fixtures/') } unless @match

      files.grep(Regexp.union(@match.map { Regexp.new(it) }))
    end
  end
  Tasks.private_constant :TodoLister
end
