# frozen_string_literal: true

# Wile namespace.
module Wile
  # Project module provides methods to manage project files.
  # rubocop:disable-next Metrics/ClassLength
  # :reek:TooManyMethods
  class Dependencies
    using WileRefinements
    using UtilitiesRefinements

    attr_reader :info

    # :reek:BooleanParameter
    def initialize(info = Info.info, verbose: false,
                   cmd_ver: CommandVersion.new)
      @info = info
      @verbose = verbose
      @cmd_ver = cmd_ver
      @cache = { gem: {}, os: {}, missing_gems: Set.new }
    end

    # :reek:TooManyStatements
    def dependencies
      run, dev, ros, dos = dependency_sets
      ignore = @info.gemignore
      project_files.each do |rbfile|
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

    # :reek:DuplicateMethodCall Set['ruby'] are new distinct instances
    # :reek:UtilityFunction
    def dependency_sets
      [Set.new, Set.new, Set['ruby'], Set['ruby']]
    end

    def project_files
      Project.rbfiles.tap { it << '.irbrc' if irbrc? }
    end

    # :reek:UtilityFunction
    def irbrc? = File.file?('.irbrc') && Git.files.include?('.irbrc')

    DEPENDENCY_SCRAPES = [
      [/^\s*#\s*wile:\s*os\s*`(\w[-\w.,]*)`/, :os, 1],
      [%r{^[^#]* `(\w[-\w.]*)\b[^/]}, :os, 1],
      [%r{\b(system|spawn)[\s(]["'](\w[-\w]+)\b[^/]}, :os, 2],
      [/^\s*#\s*wile:\s*require\s*'([-\w,]+)'/, :gem, 1],
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
    def record_dep(type, names, gemset, osset)
      names.split(',').each do |name|
        if type == :os
          osset << name unless project_command?(name)
        elsif name.split('/').first != @info.project
          gemset << name
        end
      end
    end

    def project_command?(cmd)
      cmd == @info.project ||
        PROJECT_DIRS.any? { File.executable?(File.join(it, cmd)) }
    end

    def gem_which(name)
      @cache[:gem][name] ||= resolve_gem_which(name)
    end

    # :reek:FeatureEnvy :reek:TooManyStatements
    def resolve_gem_which(name)
      fn = `gem which -q #{name.sw}`.strip
      if (mdt = %r{/gems/([-\w]+)-(\d+\.\d+\.\d+)}.match(fn))
        GemInfo.new(mdt[1], mdt[2], :gem, fn, name)
      elsif (type, md = lib_type(fn))
        GemInfo.new(md[1], nil, type, fn, name)
      else
        missing_gem(name)
      end
    end

    # :reek:UtilityFunction
    def lib_type(path)
      LIB_TYPE.each do |type, rgx|
        md = rgx.match(path)
        return [type, md] if md
      end
      nil
    end

    def missing_gem(name)
      gem = name.split('/').first
      warn "Missing gem: #{gem}".red if
        @verbose && @cache[:missing_gems].add?(gem)
      GemInfo.new(nil, nil, nil, nil, gem)
    end

    def os_which(cmd)
      @cache[:os][cmd] ||= resolve_os_which(cmd)
    end

    # :reek:TooManyStatements
    def resolve_os_which(cmd)
      unless (fn = Utilities.which(cmd))
        warn "Missing command: #{cmd}".red if @verbose
        return GemInfo.new(nil, nil, nil, nil, cmd)
      end
      version = @cmd_ver.version(cmd)
      warn_missing_version(cmd) if @verbose && !version
      GemInfo.new(cmd, version, :os, fn, cmd)
    end

    # :reek:UtilityFunction
    def warn_missing_version(cmd)
      warn "Missing command version: #{cmd}".gray unless OS_CMDS.include? cmd
    end
  end
end
