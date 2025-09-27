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
      help
    end

    # :reek:TooManyStatements
    def self.scrape_help(task)
      filename = File.join(__dir__, "/tasks/#{task}.rb")
      continue = false
      File.open(filename, 'r') do |file|
        while (line = file.gets)
          next unless continue ||= /^# #/.match?(line)
          break unless /^#/.match?(line)

          yield line[2..]
        end
      end
    end

    def self.usage(task)
      last = nil
      Help.scrape_help(task) { last = it }
      last.strip
    end
  end
end
