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
      readme_help_check(lines) if File.exist? "bin/#{@info.project}"
      File.open(@info.readme, 'w') { it.puts lines }
    end

    private

    # :reek:UncommunicativeVariableName i is an index
    def readme_version_check(lines)
      if (i = lines.index { /\d+\.\d+\.\d+/.match? it })
        lines[i].sub!(/\d+\.\d+\.\d+/, @info.version)
      else
        warn 'Warning: README does not have VERSION'.cyan
      end
    end

    # :reek:UncommunicativeVariableName i is an index
    def readme_copyright_check(lines)
      # replace whatever looks like the copyright line with Wile's way
      if (i = lines.index { /^Copyright\s\D+\d\d\d\d\s/.match? it })
        lines[i] = "Copyright (c) #{@info.year} #{@info.username}\n"
      else
        warn 'Warning: README does not have Copyright'.cyan
      end
    end

    # :reek:UncommunicativeVariableName i is an index
    def readme_help_check(lines)
      if (i = lines.index { /^#+\s*HELP/i.match? it }) &&
         lines[i += 1].start_with?('```')
        readme_help_insert(i, lines)
      else
        warn 'Warning: README does not have a HELP```console``` section'.cyan
      end
    end

    # :reek:FeatureEnvy lines
    def readme_help_insert(idx, lines)
      project = @info.project
      help = "$ #{project} --help\n"
      help << `./bin/#{Shellwords.escape(project)} --help`
      lines.insert(idx += 1, help)
      lines[idx] = nil until lines[idx += 1].start_with?('```')
      lines.compact!
    end
  end
end
