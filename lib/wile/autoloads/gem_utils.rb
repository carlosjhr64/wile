# frozen_string_literal: true

# wile: os `gem`

# Wile namespace.
module Wile
  # Runs Ruby's gem command-line tool for the current project.
  # :reek:MissingSafeMethod
  class GemUtils
    using UtilitiesRefinements

    def initialize(info = Info.info)
      @info = info
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

    def gemspec = "#{project}.gemspec"

    def clean!
      raise 'found gem file in working directory' unless clean?
    end

    def clean? = !File.exist?(gempkg)

    def build!
      gemspec.weird_filename!
      GemUtils.gem!('build', gemspec)
      gempkg
    end

    def project = @project ||= @info.project.tap(&:weird_filename!)

    def installed? = Utilities.gem_installed?(project, version:)

    def version = @version ||= @info.version.tap(&:weird_filename!)

    def gempkg = "#{project}-#{version}.gem"

    def uninstall!
      GemUtils.gem!('uninstall', project, '--version', version, '--executables')
    end

    def rm_pkg = File.unlink(gempkg)

    def self.gem!(*)
      Utilities.run('gem', *, echo: true) { |_, msg| raise msg }
    end

    def install!
      GemUtils.gem!('install', '--no-document', '--local', "./#{gempkg}")
    end

    def push!(pkg = gempkg)
      pkg.weird_filename!
      GemUtils.gem!('push', pkg)
    end
  end
end
