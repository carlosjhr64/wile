# frozen_string_literal: true

# Wile namespace.
module Wile
  # GemUtils class provides methods that uses Ruby's gem command-line tool.
  # :reek:DataClump project, version
  # :reek:MissingSafeMethod build!, clean!, push!, ready!
  class GemUtils
    using Refinement

    # :reek:NilCheck
    def ready!(minutes = 5)
      return if (ready = ready?(minutes))
      raise 'missing gemspec!' if ready.nil?

      warn 'Ensure gemspec is up-to-date.'.yellow
      raise "gemspec has not been touched in the last #{minutes} minutes"
    end

    def ready?(minutes = 5)
      # rubocop:disable-next Style/ReturnNilInPredicateMethodDefinition
      return nil unless File.exist?(gemspec)

      # ensure an up-to-date gemspec
      Time.now - File.mtime("#{@info.project}.gemspec") < minutes * 60
    end

    def gemspec
      "#{@info.project}.gemspec"
    end

    def build!
      raise 'gem build failed!' unless system2 "gem build #{gemspec}"

      gempkg
    end

    def gempkg
      "#{@info.project}-#{@info.version}.gem"
    end

    def rm_pkg
      File.unlink gempkg
    end

    def clean?
      !File.exist?(gempkg)
    end

    def clean!
      raise 'found gem file in working directory' unless clean?
    end

    def initialize(info = Info.info)
      @info = info
    end

    def install(project = @info.project, version = @info.version)
      system2 "gem install --no-document --local ./#{project}-#{version}.gem"
    end

    # :reek:UncommunicativeVariableName p
    def installed?(project = @info.project, version = @info.version)
      p = Shellwords.escape(project)
      `gem list #{p} --exact`.scan(/\d+\.\d+\.\d+/).any? { it == version }
    end

    def push!(pkg)
      raise 'gem push failed' unless system2("gem push #{pkg}")
    end

    def uninstall(project = @info.project, version = @info.version)
      system2 "gem uninstall #{project} --version #{version} --executables"
    end
  end
end
