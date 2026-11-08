# frozen_string_literal: true

# Wile namespace.
module Wile
  # GemUtils class provides methods that uses Ruby's gem command-line tool.
  # :reek:DataClump project, version
  # :reek:MissingSafeMethod build!, clean!, push!, ready!
  class GemUtils
    using WileRefinements
    using UtilitiesRefinements

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
      gemspec.weird_filename!
      raise 'gem build failed!' unless system2 "gem build #{gemspec.sw}"

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
      project.weird_filename!
      version.weird_filename!
      pkg = "./#{project}-#{version}.gem".sw
      system2 "gem install --no-document --local #{pkg}"
    end

    def installed?(project = @info.project, version = @info.version)
      project.weird_filename!
      version.weird_filename!
      `gem list #{project.sw} --exact`
        .scan(/\d+\.\d+\.\d+/).any? { it == version }
    end

    def push!(pkg)
      pkg.weird_filename!
      raise 'gem push failed' unless system2("gem push #{pkg.sw}")
    end

    def uninstall(project = @info.project, version = @info.version)
      project.weird_filename!
      version.weird_filename!
      opts = "--version #{version.sw} --executables"
      system2 "gem uninstall #{project.sw} #{opts}"
    end
  end
end
