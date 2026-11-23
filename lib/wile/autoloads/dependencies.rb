# frozen_string_literal: true

# wile: os `gem`

# Wile namespace.
module Wile
  # Resolves gem and OS command paths/versions with caching.
  class DependencyResolver
    using UtilitiesRefinements

    LIB_TYPE = {
      stdrb: %r{/ruby/\d+\.\d+\.\d+/([-\w]+)(/[-\w]+)*.rb$},
      stdso: %r{/ruby/\d+\.\d+\.\d+/[-\w]+/([-\w]+).so$},
      lib: %r{\./lib/([-\w]+)}
    }.freeze

    OS_CMDS = %w[which].freeze

    private_constant :LIB_TYPE, :OS_CMDS

    def initialize(verbose, cmd_ver)
      @verbose = verbose
      @cmd_ver = cmd_ver
      @cache = { gem: {}, os: {}, missing_gems: Set.new }
    end

    def self.lib_type(path)
      LIB_TYPE.each do |type, rgx|
        md = rgx.match(path)
        return [type, md] if md
      end
      nil
    end

    def self.parse_gem_path(path, name)
      if (mdt = %r{/gems/([-\w]+)-(\d+\.\d+\.\d+)}.match(path))
        Dependencies::GemInfo.new(mdt[1], mdt[2], :gem, path, name)
      elsif (type, md = DependencyResolver.lib_type(path))
        Dependencies::GemInfo.new(md[1], nil, type, path, name)
      end
    end

    def missing_gem(name)
      gem = name.split('/').first
      warn "Missing gem: #{gem}".red if
        @verbose && @cache[:missing_gems].add?(gem)
      Dependencies::GemInfo.new(nil, nil, nil, nil, gem)
    end

    def self.warn_missing_version(cmd)
      warn "Missing command version: #{cmd}".gray unless OS_CMDS.include?(cmd)
    end

    def gem_which(name) = @cache[:gem][name] ||= resolve_gem_which(name)

    def os_which(cmd) = @cache[:os][cmd] ||= resolve_os_which(cmd)

    private

    def resolve_gem_which(name)
      path = `gem which -q #{name.sw}`.strip
      DependencyResolver.parse_gem_path(path, name) || missing_gem(name)
    end

    def resolve_os_which(cmd)
      return missing_os(cmd) unless (path = Utilities.which(cmd))

      version = @cmd_ver.version(cmd)
      DependencyResolver.warn_missing_version(cmd) if @verbose && !version
      Dependencies::GemInfo.new(cmd, version, :os, path, cmd)
    end

    def missing_os(cmd)
      warn "Missing command: #{cmd}".red if @verbose
      Dependencies::GemInfo.new(nil, nil, nil, nil, cmd)
    end
  end

  # Scrapes and resolves Ruby gem and OS command dependencies.
  class Dependencies
    using WileRefinements

    DEPENDENCY_SCRAPES = [
      [/^\s*# wile: os `(\w[-\w.]*(?:,\w[-\w.]*)*)`(?: permit)?$/, :os],
      [/^\s*# wile: require '(\w[-\w.]*(?:,\w[-\w.]*)*)'$/, :gem],
      [%r{^[^#]*\brequire\s*'([-\w/]+)'}, :gem],
      [%r{^[^#]*\bautoload\s+:\w+,\s*'([-\w/]+)'}, :gem]
    ].freeze

    PROJECT_DIRS = %w[bin .bin cache/bin cache/.bin].freeze

    private_constant :DEPENDENCY_SCRAPES, :PROJECT_DIRS

    attr_reader :info

    # :reek:BooleanParameter
    def initialize(info = Info.info, verbose: false,
                   cmd_ver: CommandVersion.new)
      @info = info
      @resolver = DependencyResolver.new(verbose, cmd_ver)
    end

    # Stores gem or OS command dependency metadata.
    GemInfo = Struct.new(:name, :version, :type, :filename, :require) do
      def <=>(other)
        (cmp = name <=> other.name).zero? ? version <=> other.version : cmp
      end
    end

    def geminfo(libs)
      libs.map { gem_which(it) }.select { it.type == :gem }.uniq(&:name)
    end

    def osinfo(os)
      os.map { os_which(it) }.select { it.type == :os }.uniq
    end

    def dependencies
      sets = [[], [], ['ruby'], ['ruby']].map(&:to_set)
      project_files.each { scan_file(it, sets) }
      sets
    end

    def self.irbrc? = File.file?('.irbrc') && Git.files.include?('.irbrc')

    private

    def gem_which(name) = @resolver.gem_which(name)

    def os_which(cmd) = @resolver.os_which(cmd)

    def project_files
      Project.rbfiles.tap { it << '.irbrc' if Dependencies.irbrc? }
    end

    def scan_file(rbfile, sets)
      run, dev, ros, dos = sets
      gemset, osset = @info.gemignore.match?(rbfile) ? [dev, dos] : [run, ros]
      File.readlines(rbfile).each { scrape_line(it, gemset, osset) }
    end

    def record_gems(names, gemset)
      names.split(',').each do |name|
        gemset << name unless name.split('/').first == @info.project
      end
    end

    def scrape_line(line, gemset, osset)
      DEPENDENCY_SCRAPES.first_truthy_value do |rgx, type|
        next unless (md = rgx.match(line)) && (names = md[1])

        type == :os ? record_os(names, osset) : record_gems(names, gemset)
        true
      end
    end

    def record_os(names, osset)
      names.split(',').each { osset << it unless project_command?(it) }
    end

    def project_command?(cmd)
      cmd == @info.project ||
        PROJECT_DIRS.any? { File.executable?(File.join(it, cmd)) }
    end

    def missing_gem(name) = @resolver.missing_gem(name)
  end
end
