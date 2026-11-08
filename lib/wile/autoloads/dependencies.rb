# frozen_string_literal: true

# Wile namespace.
module Wile
  # rubocop:disable-next Metrics/ClassLength
  # Project module provides methods to manage project files.
  class Dependencies
    using Refinement
    using UtilitiesRefinements

    attr_reader :info

    def initialize(info = Info.info)
      @info = info
      @missing_gems = Set.new
    end

    # :reek:TooManyStatements
    # :reek:DuplicateMethodCall Set['ruby'] are new distinct instances of set
    def dependencies(token = nil)
      run = Set.new
      dev = Set.new
      ros = Set['ruby'] # run os
      dos = Set['ruby'] # dev os
      ignore = @info.gemignore
      project_files(token).each do |rbfile|
        gemset, osset = ignore.match?(rbfile) ? [dev, dos] : [run, ros]
        dependencies_populate(rbfile, gemset, osset)
      end
      [run, dev, ros, dos]
    end

    def geminfo(libs)
      libs.map { gem_which(it) }.select { it.type == :gem }.uniq(&:name)
    end

    def osinfo(os)
      os.map { os_which(it) }.select { it.type == :os }.uniq
    end

    private

    def project_files(token)
      Project.rbfiles(token).tap { it << '.irbrc' if irbrc?(token) }
    end

    # :reek:ControlParameter :reek:UtilityFunction
    def irbrc?(token)
      File.file?('.irbrc') && (token != :git || Git.files.include?('.irbrc'))
    end

    DEPENDENCY_SCRAPES = [
      [/^\s*#\s*`([-\w.]+)`$/, :os, 1],
      [%r{^[^#]* `([-\w.]+)\b[^/]}, :os, 1],
      [%r{\b(system|spawn)[\s(]["'](\w[-\w]+)\b[^/]}, :os, 2],
      [/^\s*#\s*wile:\s*require\s*'([-\w]+)'/, :gem, 1],
      [%r{^[^#]*\brequire\s*'([-\w/]+)'}, :gem, 1],
      [%r{^[^#]*\bautoload\s+:\w+,\s*'([-\w/]+)'}, :gem, 1]
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

    PROJECT_DIRS = %w[bin .bin cache/bin cache/.bin].freeze

    private_constant :DEPENDENCY_SCRAPES, :GemInfo, :LIB_TYPE, :OS_CMDS,
                     :PROJECT_DIRS

    # :reek:NestedIterators
    def dependencies_populate(rbfile, gemset, osset)
      File.readlines(rbfile).each do |line|
        DEPENDENCY_SCRAPES.first_truthy_value do |rgx, type, index|
          next unless (md = rgx.match(line)) && (name = md[index])

          record_dep(type, name, gemset, osset)
          true
        end
      end
    end

    # :reek:ControlParameter :reek:LongParameterList
    def record_dep(type, name, gemset, osset)
      if type == :os
        osset << name unless project_command?(name)
      elsif name.split('/').first != @info.project
        gemset << name
      end
    end

    def project_command?(cmd)
      cmd == @info.project ||
        PROJECT_DIRS.any? { File.executable?("#{it}/#{cmd}") }
    end

    # :reek:FeatureEnvy :reek:TooManyStatements
    def gem_which(name)
      fn = `gem which -q #{name.sw}`.strip
      if (mdt = %r{/gems/([-\w]+)-(\d+\.\d+\.\d+)}.match(fn))
        GemInfo.new(mdt[1], mdt[2], :gem, fn, name)
      elsif (type, = LIB_TYPE.detect { |_, rgx| rgx.match? fn })
        GemInfo.new(::Regexp.last_match(1), nil, type, fn, name)
      else
        missing_gem(name)
      end
    end

    def missing_gem(name)
      gem = name.split('/').first
      warn "Missing gem: #{gem}".red if @missing_gems.add?(gem)
      GemInfo.new(nil, nil, nil, nil, gem)
    end

    # :reek:TooManyStatements
    def os_which(cmd)
      fn = `which #{cmd.sw}`.strip
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
        warn "trying `#{cmd} #{flag}`".gray
        version = `#{cmd.sw} #{flag} 2>&1`.strip.scan(/\d+\.\d+/)&.first
        return version if version
      end
      nil
    end
  end
end
