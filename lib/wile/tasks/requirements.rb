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
      CommandVersion.each do |command, expected|
        if (version = CommandVersion[command])
          cases(command, version, expected)
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

    def cases(command, version, expected)
      case Gem::Version.new(version) <=> Gem::Version.new(expected)
      when 0  then show(command, version, :green)
      when 1  then show(command, "#{version} > #{expected}", :blue)
      when -1 then show(command, "#{version} < #{expected}", :magenta)
      end
    end
  end
end
