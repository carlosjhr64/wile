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

    # :reek:FeatureEnvy :reek:TooManyStatements
    def dependencies(options)
      Utilities.verify_project_root!
      Usage.new(options, *DEPENDENCIES_USAGE)
      dpc = Dependencies.new
      run, dev, ros, dos = dpc.dependencies
      report_dependencies(
        dpc.geminfo(run), dpc.geminfo(dev), dpc.osinfo(ros), dpc.osinfo(dos)
      )
    end

    private

    def puts_blue(str) = puts(str.blue)

    # :reek:DuplicateMethodCall puts(it) are different its
    # :reek:LongParameterList :reek:TooManyStatements
    def report_dependencies(run, dev, ros, dos)
      puts_blue '## runtime ##'
      name_version(run) { puts it }
      puts_blue '## development ##'
      name_version(dev) { puts it }
      puts_blue '## system-run ##'
      name_version(ros) { puts it }
      puts_blue '## system-dev ##'
      name_version(dos) { puts it }
    end

    # :reek:FeatureEnvy
    # :reek:DuplicateMethodCall on attributes
    def name_version(list)
      list.sort.map do |info|
        if info.name
          yield "#{info.name.ljust(12)} #{info.version || info.type}"
        else
          warn "Missing: #{info.require}".red
        end
      end
    end
  end
end
