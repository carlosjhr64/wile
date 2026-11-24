# frozen_string_literal: true

# Wile namespace.
module Wile
  # Gemspec class generates a gemspec file.
  # :reek:MissingSafeMethod
  class Gemspec
    RUBY_FLOOR = /\A(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)(?:\.(?:0|[1-9]\d*))?\z/
    private_constant :RUBY_FLOOR

    attr_reader :info, :gemspec

    alias to_s gemspec

    def devgems = @deps[:devgems]

    def dos = @deps[:dos]

    def files
      @files ||= Git.files.grep_v(@info.gemignore)
    end

    def executables
      files.select { it.start_with?('bin/') }.map { File.basename(it) }
    end

    def ros = @deps[:ros]

    def rungems = @deps[:rungems]

    def update! = File.write(File.join(@info.dirname, @info.gemspec), @gemspec)

    def self.load_dependencies(info)
      deps = Dependencies.new(info)
      run, dev, ros, dos = deps.dependencies
      {
        rungems: deps.geminfo(run),
        devgems: deps.geminfo(dev),
        ros: deps.osinfo(ros),
        dos: deps.osinfo(dos)
      }
    end

    def initialize(info = Info.info)
      @info = info
      @deps = Gemspec.load_dependencies(info)
      @gemspec = Renderer.render(self, Readme.new(info))
    end

    def ruby_requirement(version)
      Renderer.ruby_requirement(ruby_floor(version))
    end

    private

    def ruby_floor(version)
      file = File.join(@info.dirname, '.ruby-version-floor')
      return "#{version.to_s[/\d+/] || '4'}.0" unless File.file?(file)

      floor = File.read(file).strip
      return floor if RUBY_FLOOR.match?(floor)

      raise "DATAERR: Invalid .ruby-version-floor: #{floor.inspect}"
    end
  end

  # Renders a Gem::Specification file string from Gemspec metadata.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Gemspec::Renderer
    def self.ruby_requirement(floor)
      major = floor[/\d+/] || '4'
      if floor.split('.').size >= 3
        "'~> #{major}.0', '>= #{floor}'"
      else
        "'~> #{floor}'"
      end
    end

    def self.format_info(info)
      project = info.project
      user = info.username
      [
        '  ## INFO ##', "  s.name     = '#{project}'",
        "  s.version  = '#{info.version}'",
        "  s.homepage = 'https://github.com/#{user.downcase}/#{project}'",
        "  s.author   = '#{user}'", "  s.email    = '#{info.email}'",
        "  s.date     = '#{info.date}'", "  s.licenses = ['MIT']\n"
      ].join("\n")
    end

    def self.render(spec, readme)
      [
        "Gem::Specification.new do |s|\n",
        format_info(spec.info),
        format_description(readme),
        format_files(spec.files, spec.executables),
        format_requirements(spec),
        "end\n"
      ].join
    end

    def self.format_description(readme)
      <<-GEMSPEC
  ## DESCRIPTION ##
  s.summary  = <<~SUMMARY
    #{readme.summary.gsub("\n", "\n    ")}
  SUMMARY
  s.description = <<~DESCRIPTION
    #{readme.description.gsub("\n", "\n    ")}
  DESCRIPTION
      GEMSPEC
    end

    def self.format_files(files, executables)
      lines = <<-GEMSPEC
  ## FILES ##
  s.require_paths = ['lib']
  s.files = %w[
    #{files.join("\n    ")}
  ]
      GEMSPEC
      execs = executables.map { "  s.executables << '#{it}'\n" }.join
      "#{lines}#{execs}"
    end

    def self.format_requirements(spec)
      seen = Set.new
      deps = format_deps(spec.rungems, seen)
      os_reqs = format_os_list(spec.ros, seen) { spec.ruby_requirement(it) }
      "  ## REQUIREMENTS ##\n#{deps}#{os_reqs}"
    end

    def self.format_deps(rungems, seen)
      rungems.sort.filter_map do |gem|
        format_dep(gem) if seen.add?(gem.name)
      end.join
    end

    def self.format_dep(gem)
      version = gem.version
      mm = version.split('.')[..1].join('.')
      "  s.add_runtime_dependency '#{gem.name}', '~> #{mm}', '>= #{version}'\n"
    end

    def self.format_os_list(ros, seen, &)
      ros.sort.filter_map do |cmd|
        format_os(cmd, &) if seen.add?(cmd.name)
      end.join
    end

    def self.format_os(cmd)
      name = cmd.name
      version = cmd.version
      req = if name == 'ruby'
              "s.required_ruby_version = #{yield(version)}"
            else
              "s.requirements << '#{name}: #{version || '-'}'"
            end
      "  #{req}\n"
    end
  end
  Gemspec.private_constant :Renderer
end
