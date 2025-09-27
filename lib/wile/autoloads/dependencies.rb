# frozen_string_literal: true

# Wile namespace.
module Wile
  # Project module provides methods to manage project files.
  class Dependencies
    using Refinement

    attr_reader :info

    def initialize(info = Info.info)
      @info = info
    end

    # :reek:TooManyStatements
    # rubocop:disable Metrics/MethodLength
    # :reek:DuplicateMethodCall Set['ruby'] are new distinct instances of set
    def dependencies(token = nil)
      run = Set.new
      dev = Set.new
      ros = Set['ruby'] # run os
      dos = Set['ruby'] # dev os
      ignore = @info.gemignore
      Project.rbfiles(token).each do |rbfile|
        if ignore.match?(rbfile)
          dependencies_populate(rbfile, dev, dos)
        else
          dependencies_populate(rbfile, run, ros)
        end
      end
      [run, dev, ros, dos]
    end
    # rubocop:enable Metrics/MethodLength

    def geminfo(libs)
      libs.map { gem_which(it) }.select { it.type == :gem }.uniq
    end

    def osinfo(os)
      os.map { os_which(it) }.select { it.type == :os }.uniq
    end

    private

    DEPENDENCY_SCRAPES = [
      [/^\s*#\s*`([-\w.]+)`$/, :os, 1],
      [%r{^[^#]* `([-\w.]+)\b[^/]}, :os, 1],
      [%r{\b(system|spawn)[\s(]["'](\w[-\w]+)\b[^/]}, :os, 2],
      [%r{\brequire\s*'([-\w/]+)'}, :gem, 1],
      [%r{\bautoload\s+:\w+,\s*'([-\w/]+)'}, :gem, 1]
    ].freeze

    LIB_TYPE = {
      stdrb: %r{/ruby/\d+\.\d+\.\d+/([-\w]+)(/[-\w]+)*.rb$},
      stdso: %r{/ruby/\d+\.\d+\.\d+/[-\w]+/([-\w]+).so$},
      lib: %r{\./lib/([-\w]+)}
    }.freeze

    # This struct is used to store gem information.
    GemInfo = Struct.new(:name, :version, :type, :filename, :require) do
      def <=>(other)
        (cmp = name <=> other.name).zero? ? version <=> other.version : cmp
      end
    end

    OS_CMDS = %w[which].freeze

    private_constant :DEPENDENCY_SCRAPES, :GemInfo, :LIB_TYPE, :OS_CMDS

    # :reek:ControlParameter :reek:LongParameterList :reek:NestedIterators
    def dependencies_populate(rbfile, gemset, osset, project = @info.project)
      File.readlines(rbfile).each do |line|
        DEPENDENCY_SCRAPES.first_truthy_value do |rgx, type, index|
          if (md = rgx.match(line)) && (name = md[index])
            unless name.split('/').first == project
              type == :os ? osset << name : gemset << name
            end
            true
          end
        end
      end
    end

    # :reek:FeatureEnvy :reek:TooManyStatements
    def gem_which(name)
      fn = `gem which -q #{name}`.strip
      if (mdt = %r{/gems/([-\w]+)-(\d+\.\d+\.\d+)}.match(fn))
        return GemInfo.new(mdt[1], mdt[2], :gem, fn, name)
      elsif (type, = LIB_TYPE.detect { |_, rgx| rgx.match? fn })
        return GemInfo.new(::Regexp.last_match(1), nil, type, fn, name)
      end

      warn "Missing gem: #{name}".red
      GemInfo.new(nil, nil, nil, nil, name)
    end

    # :reek:TooManyStatements
    def os_which(cmd)
      fn = `which #{cmd}`.strip
      if fn.empty?
        warn "Missing command: #{cmd}".red
      elsif (version = CommandVersion[cmd] || os_cmd_version(cmd))
        return GemInfo.new(cmd, version, :os, fn, cmd)
      else
        warn "Missing command version: #{cmd}".gray unless OS_CMDS.include? cmd
        return GemInfo.new(cmd, nil, :os, fn, cmd)
      end
      GemInfo.new(nil, nil, nil, nil, cmd)
    end

    # :reek:UtilityFunction
    def os_cmd_version(cmd)
      ['--version', '-v', '-V'].each do |flag|
        warn "trying `#{cmd} #{flag}`".magenta
        version = `#{cmd} #{flag} 2>&1`.strip.scan(/\d+\.\d+/)&.first
        return version if version
      end
      nil
    end
  end
end
