# frozen_string_literal: true

# ## wile dependencies ##
# If the 'git' token is given, then
# it will only look at ruby file in git.
# Usage:
#   wile dependencies [git] # list ruby dependencies
module Wile
  # This file is loaded upon a :dependencies task request.
  class Tasks
    using Refinement

    DEPENDENCIES_USAGE = ['dependencies: Optionally only "git" as an argument.',
                          (..1), /^git$/].freeze

    # :reek:FeatureEnvy
    def dependencies(options)
      token, = Usage.new(options, *DEPENDENCIES_USAGE).args
      dpc = Dependencies.new
      run, dev, ros, dos = dpc.dependencies(token&.to_sym)
                              .as do |run, dev, ros, dos|
                                [dpc.geminfo(run), dpc.geminfo(dev),
                                 dpc.osinfo(ros), dpc.osinfo(dos)]
      end
      report_dependencies(run, dev, ros, dos)
    end

    private

    # :reek:ControlParameter
    def puts_blue(str, tty = $stdout.tty?) = puts(tty ? str.blue : str)

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
