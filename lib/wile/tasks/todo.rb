# frozen_string_literal: true

# ## wile todo ##
# Puts TODO.md's bullet lines.
# If match, greps matching ruby files for TODO's.
# Usage:
#   wile todo [<match>+] # scrape file's TODO's
module Wile
  # This file is loaded upon a :todo task request.
  class Tasks
    TODO_USAGE = ['todo: Optionally takes one or more arguments.', Set[]].freeze

    def todo(options)
      if (match = Usage.new(options, *TODO_USAGE).args)
        do_todo_in_files(match)
      else
        do_todo
      end
    end

    private

    def do_todo
      system "colora --on='^#\\sTODO' --off='^#' TODO.md"
    end

    # :reek:TooManyStatements
    def do_todo_in_files(match)
      Project.rbfiles.each do |fn|
        next if match.none? { fn.match? it }

        string = `egrep '#\s+TODO' #{Shellwords.escape(fn)}`
        next if string.empty?

        puts fn.blue
        puts string
      end
    end
  end
end
