# frozen_string_literal: true

# Wile namespace.
module Wile
  # GemUtils class provides methods that uses Ruby's gem command-line tool.
  # :reek:MissingSafeMethod build!, clean!, push!, ready!
  # :reek:TooManyMethods
  class GemUtils
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
      gem!('build', gemspec)
      gempkg
    end

    def rm_pkg
      File.unlink gempkg
    end

    def push!(pkg = gempkg)
      pkg.weird_filename!
      gem!('push', pkg)
    end

    def install!
      gem!('install', '--no-document', '--local', "./#{gempkg}")
    end

    def installed?
      Utilities.gem_installed?(project, version:)
    end

    def uninstall!
      gem!('uninstall', project, '--version', version, '--executables')
    end

    private

    # :reek:UtilityFunction
    def gem!(*)
      Utilities.run('gem', *, echo: true) { |_, msg| raise msg }
    end
  end
end
