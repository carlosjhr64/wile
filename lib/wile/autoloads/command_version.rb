# frozen_string_literal: true

# Wile namespace.
module Wile
  # This class knows how to get the version of a command.
  class CommandVersion
    using UtilitiesRefinements
    include Enumerable

    DEFAULT_FILE = File.join(ROOT, 'data/command_version.tsv')

    # :reek:FeatureEnvy
    def initialize(filename = DEFAULT_FILE)
      @command_version =
        File.foreach(filename, chomp: true).to_h do |line|
          cmd, probe = line.split("\t")
          [cmd, probe.start_with?(':') ? probe[1..].to_sym : probe]
        end.freeze
    end

    def commands = @command_version.keys

    def empty? = @command_version.empty?

    def expected(command)
      return nil unless @command_version.key?(command)

      probe(command) || raise("Failed to determine version for #{command}")
    end

    def key?(command) = @command_version.key?(command)

    def length = size

    def size = @command_version.size

    def each(&) = @command_version.each(&)

    def [](command)
      expected(command)
    rescue StandardError
      nil
    end

    def guess(command)
      %w[--version -v -V].each do |flag|
        if (first_line = `#{command.sw} #{flag} 2>&1`.lines.first)
          version = first_line[/\d+(\.\d+)?/]
          return version if version
        end
      end
      man(command)
    rescue StandardError
      nil
    end

    def version(command) = self[command] || guess(command)

    def fish_plugin(plugin)
      path = File.expand_path('~/.config/fish/fish_plugins')
      return nil unless File.file?(path)

      name, ver = File.foreach(path, chomp: true)
                      .map { it.split('@') }
                      .assoc(plugin)
      name && (ver&.slice(/\d+(\.\d+)*/) || '0')
    end

    # :reek:UtilityFunction
    def man(cmd)
      return nil unless (last_line = `man #{cmd.sw} 2>/dev/null`.lines.last)

      last_line[/\d+(\.\d+)?/]
    end

    private

    def probe(command)
      case (probe = @command_version[command])
      when String
        output = `#{probe} 2>&1`
        output[/\d+(\.\d+)?/]
      when Symbol
        send(probe, command)
      end
    end
  end
end
