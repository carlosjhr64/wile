# frozen_string_literal: true

# ## wile oscheck ##
# Checks if system commands exist.
# Reports the version of each command.
# Usage:
#   wile oscheck # checks for missing system commands
module Wile
  # This file is loaded upon a :oscheck task request.
  class Tasks
    OSCHECK_USAGE = ['oscheck: Takes no arguments.', 0, Set[]].freeze

    def oscheck(options)
      Usage.new(options, *OSCHECK_USAGE)
      cv = CommandVersion.new
      cv.commands.each do |command|
        if (version = cv[command])
          show(command, version, :green)
        else
          show(command, '-', :red)
        end
      end
    end

    private

    # :reek:LongParameterList
    def show(cmd, ver, col = :green, jst = 39)
      print "#{cmd.colorize(col)}:".ljust(jst)
      puts ver
    end
  end
end
