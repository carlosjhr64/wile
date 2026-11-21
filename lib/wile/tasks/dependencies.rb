# frozen_string_literal: true

# ## wile dependencies ##
# List ruby and system dependencies.
# Usage:
#   wile dependencies # list ruby dependencies
module Wile
  # This file is loaded upon a :dependencies task request.
  class Tasks
    DEPENDENCIES_USAGE = ['dependencies: Takes no arguments.', 0, Set[]].freeze

    def dependencies(options, dpc = Dependencies.new)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      Usage.new(options, *DEPENDENCIES_USAGE)
      DependencyReport.new(dpc).display
    end
  end

  # Formats and prints runtime, development, and OS dependency sections.
  class DependencyReport
    def initialize(dpc = Dependencies.new)
      @dpc = dpc
    end

    def self.display_entry(info)
      if (name = info.name)
        puts "#{name.ljust(12)} #{info.version || info.type}"
      else
        warn "Missing: #{info.require}".red
      end
    end

    def display
      sections.each { |title, list| display_section(title, list) }
    end

    private

    def display_section(title, list)
      puts title.blue
      list.sort.each { DependencyReport.display_entry(it) }
    end

    def sections
      run, dev, ros, dos = @dpc.dependencies
      {
        '## runtime ##' => @dpc.geminfo(run),
        '## development ##' => @dpc.geminfo(dev),
        '## system-run ##' => @dpc.osinfo(ros),
        '## system-dev ##' => @dpc.osinfo(dos)
      }
    end
  end
end
