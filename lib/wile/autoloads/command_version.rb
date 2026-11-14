# frozen_string_literal: true

# wile: os `diff`

# Wile namespace.
module Wile
  # This module knows how to get the version of a command.
  module CommandVersion
    using UtilitiesRefinements

    COMMAND_VERSION =
      File.foreach(File.join(ROOT, 'data/command_version.tsv'), chomp: true)
          .to_h do |line|
            cmd, probe = line.split("\t")
            [cmd, probe.start_with?(':') ? probe[1..].to_sym : probe]
          end.freeze

    extend Enumerable

    def self.commands = COMMAND_VERSION.keys

    def self.empty? = COMMAND_VERSION.empty?

    def self.expected(command)
      return nil unless COMMAND_VERSION.key?(command)

      version = case (probe = COMMAND_VERSION[command])
                when String
                  output = `#{probe}`
                  output[/\d+\.\d+/] if $CHILD_STATUS.success?
                when Symbol
                  send(probe, command)
                end
      version || raise("Failed to determine version for #{command}")
    end

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
