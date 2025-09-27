# frozen_string_literal: true

# Wile namespace.
module Wile
  # Gemspec class generates a gemspec file.
  # :reek:TooManyInstanceVariables :reek:MissingSafeMethod
  class Gemspec
    attr_reader :rungems, :devgems, :ros, :dos

    def update!
      File.open("#{@info.project}.gemspec", 'w') { it.puts @gemspec }
    end

    # :reek:BooleanParameter
    def initialize(info = Info.info, token: :git, verbose: false)
      @info = info
      @token = token
      @verbose = verbose
      @dependencies = Dependencies.new(info)
      @readme = Readme.new(info)
      @gemspec = String.new
      @rungems = @devgems = @ros = @dos = nil # set in dependencies
      dependencies
      generate
    end

    def executables
      @executables ||= files.select { it.start_with?('bin/') }
                            .map { File.basename it }
    end

    def files
      @files ||= Git.files.grep_v(@info.gemignore)
    end

    private

    def dependencies
      run, dev, ros, dos = @dependencies.dependencies(@token)
      @rungems = @dependencies.geminfo(run)
      @devgems = @dependencies.geminfo(dev)
      @ros = @dependencies.osinfo(ros)
      @dos = @dependencies.osinfo(dos)
    end

    def gemspec_files
      @gemspec << <<-GEMSPEC
  ## FILES ##
  s.require_paths = ['lib']
  s.files = %w[
    #{files.join("\n    ")}
  ]
  #{executables.map { "  s.executables << '#{it}'" }.join("\n")}
      GEMSPEC
    end

    # :reek:TooManyStatements
    def generate
      @gemspec << "Gem::Specification.new do |s|\n"
      gemspec_info
      gemspec_description
      gemspec_files
      gemspec_requirements
      @gemspec << "end\n"
    end

    def gemspec_description
      @gemspec << <<-GEMSPEC
  ## DESCRIPTION ##
  s.summary  = <<~SUMMARY
    #{@readme.summary.lines.join('    ')}
  SUMMARY
  s.description = <<~DESCRIPTION
    #{@readme.description.lines.join('    ')}
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
      gemspec_run(seen)
      gemspec_dev(seen) if @verbose
      gemspec_os(seen, @ros)
      gemspec_os(seen, @dos) if @verbose
    end

    # :reek:FeatureEnvy :reek:DuplicateMethodCall :reek:TooManyStatements
    def gemspec_run(seen)
      @rungems.sort.each do |gem|
        seen.include?(gem.name) ? next : seen.add(gem.name)

        @gemspec << "  s.add_runtime_dependency '#{gem.name}', "
        version = gem.version.split('.')[..1].join('.')
        @gemspec << "'~> #{version}', '>= #{gem.version}'\n"
      end
    end

    # :reek:FeatureEnvy :reek:DuplicateMethodCall :reek:TooManyStatements
    def gemspec_dev(seen)
      @devgems.sort.each do |gem|
        seen.include?(gem.name) ? next : seen.add(gem.name)

        @gemspec << "  s.add_development_dependency '#{gem.name}', "
        version = gem.version.split('.')[..1].join('.')
        @gemspec << "'~> #{version}', '>= #{gem.version}'\n"
      end
    end

    # :reek:FeatureEnvy :reek:DuplicateMethodCall :reek:TooManyStatements
    def gemspec_os(seen, os = @ros)
      os.sort.each do |cmd|
        seen.include?(cmd.name) ? next : seen.add(cmd.name)

        @gemspec << '  '
        @gemspec << if cmd.name == 'ruby'
                      "s.required_ruby_version = '>= #{cmd.version}'"
                    else
                      "s.requirements << '#{cmd.name}: #{cmd.version || '-'}'"
                    end
        @gemspec << "\n"
      end
    end
  end
end
