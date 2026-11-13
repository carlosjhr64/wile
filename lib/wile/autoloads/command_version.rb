# frozen_string_literal: true

# wile: os `diff`

# Wile namespace.
module Wile
  # This module knows how to get the version of a command.
  module CommandVersion
    using UtilitiesRefinements

    COMMAND_VERSION = {
      'agy' => ['agy --version', '1.5'],
      'bash' => ['bash --version', '5.2'],
      'carlosjhr64/pkg-goto' => ["fish -c 'goto --version'", '2.1'],
      'carlosjhr64/theme-local' => [:fish_plugin, '0'],
      'cat' => ['cat --version', '9.1'],
      'clear' => ['clear -V', '6.4'],
      'colora' => ['colora --version', '1.0'],
      'cucumber' => ['cucumber --version', '11.1'],
      'diff' => ['diff --version', '3.8'],
      'egrep' => ['egrep --version', '3.8'],
      'fish' => ['fish --version', '4.0'],
      'gem' => ['gem --version', '4.0'],
      'GET' => ['GET -v 2>&1', '6.68'],
      'git' => ['git --version', '2.39'],
      'grep' => ['grep --version', '3.8'],
      'head' => ['head --version', '9.1'],
      'irb' => ['irb --version', '1.16'],
      'jorgebucaran/fisher' => ["fish -c 'fisher --version'", '4.4'],
      'kill' => [:man, '2021'],
      'ls' => ['ls --version', '9.1'],
      'man' => ['man --version', '2.11'],
      'md5sum' => ['md5sum --version', '9.1'],
      'ncal' => [:man, '2019'],
      'nvim' => ['nvim --version', '0.12'],
      'pandoc' => ['pandoc -v', '2.17'],
      'rbenv' => ['rbenv --version', '1.3'],
      'ripper-tags' => ['ripper-tags --version', '1.0'],
      'reek' => ['reek --version', '6.6'],
      'rubocop' => ['rubocop --version', '1.92'],
      'ruby' => ['ruby --version', '4.0'],
      'ruby-parse' => ['ruby-parse --version', '3.3'],
      'sort' => ['sort --version', '9.1'],
      'stree' => ['stree version', '6.3'],
      'tmux' => ['tmux -V', '3.3'],
      'tput' => ['tput -V', '6.4'],
      'tmuxinator' => ['tmuxinator -v', '3.4'],
      'todo.sh' => ['todo.sh -V', '2.12'],
      'tr' => ['tr --version', '9.1'],
      'which' => [:man, '2016'],
      'wile' => ['wile --version', '0.0'],
      'xdg-open' => ['xdg-open --version', '1.1']
    }.freeze

    extend Enumerable

    def self.commands = COMMAND_VERSION.keys

    def self.empty? = COMMAND_VERSION.empty?

    def self.expected(command) = COMMAND_VERSION[command]&.last

    def self.include?(command) = key?(command)

    def self.key?(command) = COMMAND_VERSION.key?(command)

    def self.length = size

    def self.probe(command) = COMMAND_VERSION[command]&.first

    def self.size = COMMAND_VERSION.size

    def self.each
      return to_enum(__method__) unless block_given?

      COMMAND_VERSION.each do |command, (_, expected)|
        yield(command, expected)
      end
    end

    def self.[](command)
      probe, = COMMAND_VERSION[command]
      case probe
      when String
        `#{probe}`[/\d+\.\d+/]
      when Symbol
        send(probe, command)
      end
    rescue StandardError
      nil
    end

    def self.fish_plugin(plugin)
      path = File.expand_path('~/.config/fish/fish_plugins')
      return nil unless File.file?(path)

      name, ver = File.foreach(path, chomp: true)
                      .map { it.split('@') }
                      .assoc(plugin)
      name && (ver&.slice(/\d+(\.\d+)*/) || '0')
    end

    def self.man(cmd)
      last_line = `man #{cmd.sw} 2>/dev/null`.lines.last
      last_line&.slice(/[12]\d{3}/)
    end
  end
end
