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

    def self.probe(command)
      case (probe = COMMAND_VERSION[command])
      when String
        output = `#{probe}`
        output[/\d+\.\d+/] if $CHILD_STATUS.success?
      when Symbol
        send(probe, command)
      end
    end
    private_class_method :probe

    def self.expected(command)
      return nil unless COMMAND_VERSION.key?(command)

      probe(command) || raise("Failed to determine version for #{command}")
    end

    def self.include?(command) = key?(command)

    def self.key?(command) = COMMAND_VERSION.key?(command)

    def self.length = size

    def self.size = COMMAND_VERSION.size

    def self.each(&) = COMMAND_VERSION.each(&)

    def self.[](command)
      expected(command)
    rescue StandardError
      nil
    end

    def self.guess(command)
      %w[--version -v -V].each do |flag|
        ver = `#{command.sw} #{flag} 2>&1`[/\d+\.\d+/]
        return ver if $CHILD_STATUS.success? && ver
      end
      man(command)
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
