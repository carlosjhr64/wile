# frozen_string_literal: true

# Wile namespace.
module Wile
  # Scrape help documentation from task files.
  module Help
    def self.[](sym)
      Help.help_string(sym)
    end

    def self.help_string(task)
      help = String.new
      Help.scrape_help(task) { help << it }
      help.empty? ? nil : help
    end

    def self.task_file(task)
      custom = File.expand_path(".tasks/#{task}.rb")
      file = File.file?(custom) ? custom : "#{__dir__}/tasks/#{task}.rb"
      return file if File.file?(file)

      raise ArgumentError, "does not exist: #{file}"
    end

    # :reek:TooManyStatements
    def self.scrape_help(task)
      continue = false
      File.open(task_file(task), 'r') do |file|
        while (line = file.gets)
          next unless continue ||= /^# #/.match?(line)
          break unless /^#/.match?(line)

          yield line[2..]
        end
      end
    end

    def self.usage(task)
      last = nil
      scrape_help(task) { last = it }
      last&.strip
    end
  end
end
