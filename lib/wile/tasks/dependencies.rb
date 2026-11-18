# frozen_string_literal: true

# ## wile dependencies ##
# List ruby dependencies.
# Usage:
#   wile dependencies # list ruby dependencies
module Wile
  # This file is loaded upon a :dependencies task request.
  class Tasks
    using WileRefinements

    DEPENDENCIES_USAGE = ['dependencies: Takes no arguments.', 0, Set[]].freeze

    # :reek:FeatureEnvy
    # rubocop:disable-next Metrics/MethodLength
    def dependencies(options, dpc = Dependencies.new)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      Usage.new(options, *DEPENDENCIES_USAGE)
      run, dev, ros, dos = dpc.dependencies
      report_dependencies(
        '## runtime ##' => dpc.geminfo(run),
        '## development ##' => dpc.geminfo(dev),
        '## system-run ##' => dpc.osinfo(ros),
        '## system-dev ##' => dpc.osinfo(dos)
      )
    end

    private

    def puts_blue(str) = puts(str.blue)

    def report_dependencies(sections)
      sections.each do |title, list|
        puts_blue title
        name_version(list) { puts it }
      end
    end

    # :reek:FeatureEnvy
    def name_version(list)
      list.sort.each do |info|
        if (name = info.name)
          yield "#{name.ljust(12)} #{info.version || info.type}"
        else
          warn "Missing: #{info.require}".red
        end
      end
    end
  end
end
