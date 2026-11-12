# frozen_string_literal: true

# Wile namespace.
module Wile
  # Readme class provides methods to read and update the README file.
  class Readme
    using WileRefinements

    attr_reader :info, :path

    alias readme path

    def initialize(info = Info.info)
      @info = info
      @path = info.readme
    end

    DESCRIPTION = /\n#+\s*DESCRIPTION[^\n]*(.*?)\n#/mi
    private_constant :DESCRIPTION

    def description
      @description ||= File.match!(@path, DESCRIPTION)[1].strip
    end

    def summary
      @summary ||= description.split("\n\n").first.strip
    end

    def update
      lines = File.readlines(@path)
      update_version(lines)
      update_copyright(lines)
      update_console(lines).join
    end

    def update!
      File.write(@path, update)
    end

    private

    def update_version(lines)
      index = lines.index { /\d+\.\d+\.\d+/.match? it }
      if index
        lines[index] = lines[index].sub(/\d+\.\d+\.\d+/, @info.version)
      else
        warn 'Warning: README does not have VERSION'.yellow
      end
    end

    def update_copyright(lines)
      index = lines.index { /^Copyright\s\D+\d\d\d\d\s/.match? it }
      if index
        lines[index] = "Copyright (c) #{@info.year} #{@info.username}\n"
      else
        warn 'Warning: README does not have Copyright'.yellow
      end
    end

    def update_console(lines)
      project = @info.project
      return lines unless File.exist?("bin/#{project}")

      ConsoleBlocks.new(lines, project).update
    end

    # Helper class to update active console blocks in README lines.
    class ConsoleBlocks
      def initialize(lines, project)
        @lines = lines
        @project = project
        @updated = []
        @found = false
      end

      def update
        process_lines
        warn_missing unless @found
        @updated
      end

      private

      def process_lines
        index = 0
        index = append_line(index) while index < @lines.length
      end

      def append_line(index)
        @updated << @lines[index]
        next_index = index + 1
        console_start?(index) ? update_block(next_index) : next_index
      end

      def update_block(cmd_index)
        @found = true
        replace_block(cmd_index)
      end

      def console_start?(index)
        @lines[index]&.chomp == '```console' &&
          target_cmd?(@lines[index + 1])
      end

      def target_cmd?(line)
        line&.start_with?("$ #{@project} ") && line.chomp.end_with?(' #>>')
      end

      def replace_block(cmd_index)
        cmd = @lines[cmd_index].chomp[2..-5]
        @updated << "$ #{cmd} #>>\n"
        @updated << run_console(cmd)
        skip_to_fence(cmd_index + 1)
      end

      def skip_to_fence(index)
        index += 1 until fence?(index)
        index
      end

      def fence?(index)
        @lines[index]&.start_with?('```') || index >= @lines.length
      end

      # :reek:UtilityFunction
      def run_console(cmd)
        output = `./bin/#{cmd}`
        output.end_with?("\n") ? output : "#{output}\n"
      end

      def warn_missing
        warn 'Warning: README does not have an active console output'.yellow
      end
    end
    private_constant :ConsoleBlocks
  end
end
