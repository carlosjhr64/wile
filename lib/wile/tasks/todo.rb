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
      return do_todo_in_files(match) if match

      do_todo
    end

    private

    def do_todo
      return warn('TODO.md not found.'.yellow) unless File.file?('TODO.md')

      system('colora', '--on=^#\\sTODO', '--off=^#', 'TODO.md')
    end

    def do_todo_in_files(match)
      Project.rbfiles.weird_filename!.each do |fn|
        next if match.none? { fn.match? it }

        lines = File.foreach(fn).grep(/#\s*TODO/)
        puts fn.blue, lines unless lines.empty?
      end
    end
  end
end
