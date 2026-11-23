# frozen_string_literal: true

# wile: os `man`

# Wile namespace.
module Wile
  # Stateless helpers for parsing and probing command versions.
  class VersionProbe
    using UtilitiesRefinements

    def self.fish_plugin(plugin)
      path = File.expand_path('~/.config/fish/fish_plugins')
      return nil unless File.file?(path)

      name, ver = File.foreach(path, chomp: true)
                      .map { it.split('@') }
                      .assoc(plugin)
      name && (ver&.slice(/\d+(\.\d+)*/) || '0')
    end

    def self.man(cmd)
      return nil unless (last_line = `man #{cmd.sw} 2>/dev/null`.lines.last)

      scrape(last_line)
    end

    def self.scrape(str)
      return nil if str.start_with?('sh:')

      str[/\d+\.\d+/] || str[/[12]\d\d\d/] || str[/\d+/]
    end

    def self.probing_string(probe)
      return nil unless (first_line = `#{probe} 2>&1`.strip.lines.first)

      scrape(first_line)
    end

    def self.guessing_flag(command)
      %w[--version -v -V].each do |flag|
        version = probing_string("#{command.sw} #{flag}")
        return version if version
      end
      nil
    end

    def self.parse_probe(probe)
      probe.start_with?(':') ? probe[1..].to_sym : probe
    end

    def self.parse_tsv(filename)
      File.foreach(filename, chomp: true).to_h do |line|
        cmd, probe = line.split("\t")
        [cmd, parse_probe(probe)]
      end.freeze
    end
  end

  # This class knows how to get the version of a command.
  # :reek:MissingSafeMethod
  class CommandVersion
    include Enumerable

    DEFAULT_FILE = File.join(ROOT, 'data/command_version.tsv')

    def fish_plugin(plugin) = @probe.fish_plugin(plugin)

    def initialize(filename = DEFAULT_FILE, probe: VersionProbe)
      @command_version = probe.parse_tsv(filename)
      @probe = probe
    end

    def key?(command) = @command_version.key?(command)

    def size = @command_version.size
    alias length size

    def commands = @command_version.keys

    def each(&) = @command_version.each(&)

    def empty? = @command_version.empty?

    def expected!(command)
      self[command] || raise("Failed to determine version for #{command}")
    end

    def guessing_flag(command) = @probe.guessing_flag(command)

    def version(command) = self[command] || guess(command)

    def guess(command)
      guessing_flag(command) || man(command)
    rescue StandardError
      nil
    end

    def man(cmd) = @probe.man(cmd)

    def [](command)
      return nil unless (probe = @command_version[command])

      probing(probe, command)
    rescue StandardError
      nil
    end

    private

    def probing(probe, command)
      case probe
      when String then @probe.probing_string(probe) || man(command)
      when Symbol then send(probe, command)
      end
    end
  end
end
