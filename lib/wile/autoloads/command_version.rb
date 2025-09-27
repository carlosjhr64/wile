# frozen_string_literal: true

# Wile namespace.
module Wile
  # This module knows how to get the version of a command.
  module CommandVersion
    COMMAND_VERSION = {
      'bash' => 'bash --version',
      'carlosjhr64/goto' => "fish -c 'goto --version'",
      'carlosjhr64/theme-local' => :fish_plugin,
      'cat' => 'cat --version',
      'clear' => 'clear -V',
      'colora' => 'colora --version',
      'colordiff' => 'colordiff --version',
      'cucumber' => 'cucumber --version',
      'diff' => 'diff --version',
      'egrep' => 'egrep --version',
      'fish' => 'fish --version',
      'gem' => 'gem --version',
      'GET' => 'GET -v 2>&1',
      'git' => 'git --version',
      'grep' => 'grep --version',
      'head' => 'head --version',
      'irb' => 'irb --version',
      'jorgebucaran/fisher' => "fish -c 'fisher --version'",
      'kill' => :man,
      'ls' => 'ls --version',
      'man' => 'man --version',
      'md5sum' => 'md5sum --version',
      'ncal' => :man,
      'nvim' => 'nvim --version',
      'rbenv' => 'rbenv --version',
      'reek' => 'reek --version',
      'ripper-tags' => 'ripper-tags --version',
      'rubocop' => 'rubocop --version',
      'ruby' => 'ruby --version',
      'ruby-parse' => 'ruby-parse --version',
      'sort' => 'sort --version',
      'stree' => 'stree version',
      'tmux' => 'tmux -V',
      'tput' => 'tput -V',
      'tmuxinator' => 'tmuxinator -v',
      'todo.sh' => 'todo.sh -V',
      'tr' => 'tr --version',
      'which' => :man,
      'wile' => 'wile --version',
      'xdg-open' => 'xdg-open --version'
    }.freeze

    def self.[](command)
      cmdver = COMMAND_VERSION[command]
      case cmdver
      when String
        `#{cmdver}`.lines.first.strip.scan(/\d+\.\d+/).first
      when Symbol
        send(cmdver, command)
      end
    end

    def self.fish_plugin(plugin)
      system("egrep -q '^#{plugin}$' ~/.config/fish/fish_plugins") ? '0' : nil
    end

    def self.man(cmd)
      year = `man #{cmd} | tail -n 1 | egrep -o '[12][0-9][0-9][0-9]'`.strip
      year.empty? ? nil : year
    end
  end
end
