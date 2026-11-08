# frozen_string_literal: true

# ## wile todo ##
# Puts TODO.md's bullet lines.
# If match, greps matching ruby files for TODO's.
# Usage:
#   wile todo [<match>+] # display TODO.md or scrape TODO comments
module Wile
  # This file is loaded upon a :todo task request.
  class Tasks
    using UtilitiesRefinements

    TODO_USAGE = ['todo: Optionally takes one or more arguments.', Set[]].freeze

    def todo(options)
      Utilities.verify_project_root!
      match = Usage.new(options, *TODO_USAGE).args
      return do_todo if File.file?('TODO.md') && !match

      do_todo_files(match)
    end

    private

    def do_todo
      system('colora', '--on=^#\\sTODO', '--off=^#', 'TODO.md')
    end

    # :reek:ControlParameter :reek:TooManyStatements
    def do_todo_files(match)
      files = Project.rbfiles.weird_filename!
      files = files.reject { it.start_with?('features/fixtures/') } unless match
      files.each do |fn|
        next if match&.none? { fn.match? it }

        lines = File.foreach(fn).grep(/#\s*TODO/)
        puts fn.blue, lines unless lines.empty?
      end
    end
  end
end
