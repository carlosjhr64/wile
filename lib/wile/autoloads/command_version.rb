# frozen_string_literal: true

# Wile namespace.
module Wile
  # This class knows how to get the version of a command.
  # :reek:TooManyMethods
  # :reek:MissingSafeMethod
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

    def expected!(command)
      self[command] || raise("Failed to determine version for #{command}")
    end

    def key?(command) = @command_version.key?(command)

    def length = size

    def size = @command_version.size

    def each(&) = @command_version.each(&)

    def [](command)
      return nil unless (probe = @command_version[command])

      probing(probe, command)
    rescue StandardError
      nil
    end

    def guessing_flag(command)
      %w[--version -v -V].each do |flag|
        probe = "#{command.sw} #{flag}"
        version = probing_string(probe)
        return version if version
      end
      nil
    end

    def guess(command)
      guessing_flag(command) || man(command)
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

      scrape(last_line)
    end

    private

    # :reek:UtilityFunction
    def scrape(str)
      return nil if str.start_with?('sh:')

      str[/\d+\.\d+/] || str[/[12]\d\d\d/] || str[/\d+/]
    end

    def probing_string(probe)
      return nil unless (first_line = `#{probe} 2>&1`.strip.lines.first)

      scrape(first_line)
    end

    def probing(probe, command)
      case probe
      when String
        probing_string(probe) || man(command)
      when Symbol
        send(probe, command)
      end
    end
  end
end
