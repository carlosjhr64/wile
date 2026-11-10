# frozen_string_literal: true

# Wile namespace.
module Wile
  # Gemspec class generates a gemspec file.
  # :reek:TooManyInstanceVariables :reek:MissingSafeMethod
  class Gemspec
    attr_reader :rungems, :devgems, :ros, :dos, :gemspec

    alias to_s gemspec

    def update!
      File.write(File.join(@info.dirname, @info.gemspec), @gemspec)
    end

    # :reek:BooleanParameter
    def initialize(info = Info.info, token: :git, verbose: false)
      @info = info
      @token = token&.to_sym
      @verbose = verbose
      @rungems, @devgems, @ros, @dos = load_dependencies(info)
      @gemspec = String.new
      generate(Readme.new(info))
    end

    def executables
      @executables ||= files.select { it.start_with?('bin/') }
                            .map { File.basename it }
    end

    def files
      @files ||= Git.files.grep_v(@info.gemignore)
    end

    private

    # :reek:FeatureEnvy
    def load_dependencies(info)
      deps = Dependencies.new(info)
      run, dev, ros, dos = deps.dependencies(@token)
      [
        deps.geminfo(run),
        deps.geminfo(dev),
        deps.osinfo(ros),
        deps.osinfo(dos)
      ]
    end

    def gemspec_files
      @gemspec << <<-GEMSPEC
  ## FILES ##
  s.require_paths = ['lib']
  s.files = %w[
    #{files.join("\n    ")}
  ]
      GEMSPEC
      executables.each { @gemspec << "  s.executables << '#{it}'\n" }
    end

    # :reek:TooManyStatements
    def generate(readme)
      @gemspec << "Gem::Specification.new do |s|\n"
      gemspec_info
      gemspec_description(readme)
      gemspec_files
      gemspec_requirements
      @gemspec << "end\n"
    end

    # :reek:FeatureEnvy
    def gemspec_description(readme)
      @gemspec << <<-GEMSPEC
  ## DESCRIPTION ##
  s.summary  = <<~SUMMARY
    #{readme.summary.gsub("\n", "\n    ")}
  SUMMARY
  s.description = <<~DESCRIPTION
    #{readme.description.gsub("\n", "\n    ")}
  DESCRIPTION
      GEMSPEC
    end

    # :reek:DuplicateMethodCall
    def gemspec_info
      @gemspec << <<-GEMSPEC
  ## INFO ##
  s.name     = '#{@info.project}'
  s.version  = '#{@info.version}'
  s.homepage = 'https://github.com/#{@info.username.downcase}/#{@info.project}'
  s.author   = '#{@info.username}'
  s.email    = '#{@info.email}'
  s.date     = '#{@info.date}'
  s.licenses = ['MIT']
      GEMSPEC
    end

    # :reek:TooManyStatements
    def gemspec_requirements
      @gemspec << "  ## REQUIREMENTS ##\n"
      seen = Set.new
      gemspec_deps(seen, @rungems, 'runtime')
      gemspec_deps(seen, @devgems, 'development') if @verbose
      gemspec_os(seen, @ros)
      gemspec_os(seen, @dos) if @verbose
    end

    # :reek:FeatureEnvy :reek:TooManyStatements
    def gemspec_deps(seen, gems, type)
      gems.sort.each do |gem|
        name = gem.name
        next unless seen.add?(name)

        version = gem.version
        mm = version.split('.')[..1].join('.')
        @gemspec << "  s.add_#{type}_dependency '#{name}', " \
                    "'~> #{mm}', '>= #{version}'\n"
      end
    end

    # :reek:FeatureEnvy
    def gemspec_os(seen, os = @ros)
      os.sort.each do |cmd|
        next unless seen.add?(cmd.name)

        append_os_requirement(cmd)
      end
    end

    # :reek:FeatureEnvy
    def append_os_requirement(cmd)
      name = cmd.name
      version = cmd.version
      req = if name == 'ruby'
              "s.required_ruby_version = '>= #{version}'"
            else
              "s.requirements << '#{name}: #{version || '-'}'"
            end
      @gemspec << "  #{req}\n"
    end
  end
end
