# frozen_string_literal: true

# ## wile requirements ##
# Checks if required commands exist.
# Reports the version of each command.
# Usage:
#   wile requirements # checks for missing system commands
module Wile
  # This file is loaded upon a :requirements task request.
  class Tasks
    REQUIREMENTS_USAGE = ['requirements: Takes no arguments.', 0, Set[]].freeze

    def requirements(options)
      Usage.new(options, *REQUIREMENTS_USAGE)
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
