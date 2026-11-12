# frozen_string_literal: true

# Wile namespace.
module Wile
  # GemUtils class provides methods that uses Ruby's gem command-line tool.
  # :reek:MissingSafeMethod build!, clean!, push!, ready!
  class GemUtils
    using WileRefinements
    using UtilitiesRefinements

    def initialize(info = Info.info)
      @info = info
    end

    def project
      @project ||= @info.project.tap(&:weird_filename!)
    end

    def version
      @version ||= @info.version.tap(&:weird_filename!)
    end

    def gemspec
      "#{project}.gemspec"
    end

    def gempkg
      "#{project}-#{version}.gem"
    end

    def ready!(minutes = 5)
      raise 'missing gemspec!' unless File.exist?(gemspec)
      return if ready?(minutes)

      warn 'Ensure gemspec is up-to-date.'.yellow
      raise "gemspec has not been touched in the last #{minutes} minutes"
    end

    def ready?(minutes = 5)
      File.exist?(gemspec) && (Time.now - File.mtime(gemspec) < minutes * 60)
    end

    def clean?
      !File.exist?(gempkg)
    end

    def clean!
      raise 'found gem file in working directory' unless clean?
    end

    def build!
      gemspec.weird_filename!
      raise 'gem build failed!' unless system2 "gem build #{gemspec.sw}"

      gempkg
    end

    def rm_pkg
      File.unlink gempkg
    end

    def push!(pkg = gempkg)
      pkg.weird_filename!
      raise 'gem push failed' unless system2("gem push #{pkg.sw}")
    end

    def install
      pkg = "./#{gempkg}".sw
      system2 "gem install --no-document --local #{pkg}"
    end

    def installed?
      `gem list #{project.sw} --exact`
        .scan(/\d+\.\d+\.\d+/).any? { it == version }
    end

    def uninstall
      opts = "--version #{version.sw} --executables"
      system2 "gem uninstall #{project.sw} #{opts}"
    end
  end
end
