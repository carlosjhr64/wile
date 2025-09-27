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

    REQUIREMENTS = {
      'bash' => '5.1',
      'carlosjhr64/goto' => '1.2',
      'carlosjhr64/theme-local' => '0',
      'cat' => '8.32',
      'clear' => '6.2',
      'colora' => '1.0',
      'colordiff' => '3.7',
      'cucumber' => '9.2',
      'diff' => '3.7',
      'egrep' => '3.6',
      'fish' => '3.7',
      'gem' => '3.6',
      'GET' => '6.52',
      'git' => '2.30',
      'grep' => '3.6',
      'head' => '8.32',
      'irb' => '1.14',
      'jorgebucaran/fisher' => '4.4',
      'kill' => '2020',
      'ls' => '8.32',
      'man' => '2.9',
      'md5sum' => '8.32',
      'ncal' => '2019',
      'nvim' => '0.10',
      'rbenv' => '1.3',
      'ripper-tags' => '1.0',
      'reek' => '6.5',
      'rubocop' => '1.75',
      'ruby' => '3.4',
      'ruby-parse' => '3.3',
      'sort' => '8.32',
      'stree' => '6.2',
      'tmux' => '3.1',
      'tmuxinator' => '3.3',
      'todo.sh' => '2.12',
      'tput' => '6.2',
      'tr' => '8.32',
      'which' => '2016',
      'wile' => '0.0',
      'xdg-open' => '1.1'
    }.freeze

    def requirements(options)
      Usage.new(options, *REQUIREMENTS_USAGE)
      REQUIREMENTS.sort.each do |command, expected|
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
