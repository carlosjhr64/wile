# frozen_string_literal: true

# Wile namespace.
module Wile
  # Readme module provides methods to update the README file.
  # :reek:DuplicateMethodCall on attributes
  # :reek:MissingSafeMethod
  class Readme
    using Refinement

    attr_reader :readme

    def initialize(info = Info.info)
      @info = info
    end

    DESCRIPTION = /\n#+\s*DESCRIPTION[^\n]*(.*?)\n#/mi
    private_constant :DESCRIPTION

    def description
      @description ||= File.match!(@info.readme, DESCRIPTION)[1].strip
    end

    def summary
      @summary ||= description.split("\n\n").first.strip
    end

    # :reek:TooManyStatements
    def update!
      lines = File.readlines(@info.readme)
      readme_version_check(lines)
      readme_copyright_check(lines)
      readme_console_check(lines) if File.exist? "bin/#{@info.project}"
      File.open(@info.readme, 'w') { it.puts lines }
    end

    private

    # :reek:UncommunicativeVariableName i is an index
    def readme_version_check(lines)
      if (i = lines.index { /\d+\.\d+\.\d+/.match? it })
        lines[i].sub!(/\d+\.\d+\.\d+/, @info.version)
      else
        warn 'Warning: README does not have VERSION'.yellow
      end
    end

    # :reek:UncommunicativeVariableName i is an index
    def readme_copyright_check(lines)
      # replace whatever looks like the copyright line with Wile's way
      if (i = lines.index { /^Copyright\s\D+\d\d\d\d\s/.match? it })
        lines[i] = "Copyright (c) #{@info.year} #{@info.username}\n"
      else
        warn 'Warning: README does not have Copyright'.yellow
      end
    end

    # :reek:FeatureEnvy
    # :reek:TooManyStatements
    # rubocop: disable-next Metrics
    def readme_console_check(lines)
      flg = false
      idx = -1
      project = @info.project
      while (line = lines[idx += 1]&.chomp)
        next unless line == '```console'

        line = lines[idx += 1]&.chomp
        next unless line.start_with?("$ #{project} ") && line.end_with?(' #>>')

        flg ||= true
        cmd = line[2..-5]
        readme_console_insert(cmd, idx, lines)
      end
      return if flg

      warn 'Warning: README does not have an active console output'.yellow
    end

    # :reek:UtilityFunction
    def readme_console_insert(cmd, idx, lines)
      output = "$ #{cmd} #>>\n"
      output << `./bin/#{cmd}`
      lines.insert(idx, output)
      lines[idx] = nil until lines[idx += 1].start_with?('```')
      lines.compact!
    end
  end
end
