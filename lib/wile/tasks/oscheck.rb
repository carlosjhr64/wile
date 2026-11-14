# frozen_string_literal: true

# ## wile oscheck ##
# Checks for system commands and reports their installed versions.
# By default, only displays found commands.
# Options:
#   --all # report all commands including missing ones (exits 1 on missing)
# Usage:
#   wile oscheck [--all] # check system command versions
module Wile
  # This file is loaded upon a :oscheck task request.
  class Tasks
    OSCHECK_USAGE = [
      'oscheck: Takes no arguments with optional all flag.',
      0,
      Set['all']
    ].freeze

    def oscheck(options)
      Usage.new(options, *OSCHECK_USAGE)
      failed = oscheck_do(options.all?)
      exit(EX_FAIL) if failed
    end

    private

    def oscheck_do(all)
      cmd_ver = CommandVersion.new
      cmd_ver.commands.reject { command_found?(it, cmd_ver) }.tap do |missing|
        missing.each { show(it, '-', :red) } if all
      end.any? && all
    end

    def command_found?(cmd, cmd_ver)
      return false unless (ver = cmd_ver[cmd])

      show(cmd, ver, :green)
      true
    end

    # :reek:LongParameterList
    def show(cmd, ver, col = :green, jst = 39)
      print "#{cmd.colorize(col)}:".ljust(jst)
      puts ver
    end
  end
end
