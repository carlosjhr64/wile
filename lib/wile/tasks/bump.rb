# frozen_string_literal: true

# ## wile bump ##
# Bumps the project version (major, minor, or date-stamped build) across
# .version, lib/<project>.rb, README.md, and <project>.gemspec.
# Usage:
#   wile bump [major|minor|build] # bump the version number
module Wile
  # This file is loaded upon a :bump task request.
  class Tasks
    BUMP_USAGE = ['bump: Optionally takes one argument (major|minor|build).',
                  (..1), /^(major|minor|build)$/, Set[]].freeze

    def bump(options, info = Info.info)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      type, = Usage.new(options, *BUMP_USAGE).args
      Bumper.new(info, type).bump
    end
  end

  # Computes and writes bumped project versions.
  class Bumper
    using WileRefinements

    BUMPS = {
      'major' => ->(maj, _min) { [maj + 1, 0] },
      'minor' => ->(maj, min) { [maj, min + 1] }
    }.freeze
    private_constant :BUMPS

    def initialize(info = Info.info, type = nil)
      @info = info
      @type = type
    end

    def self.bumped(version, type = nil, now = Time.now)
      major, minor, = version.split('.').map(&:to_i)
      major, minor = BUMPS[type].call(major, minor) if BUMPS.key?(type)
      "#{major}.#{minor}.#{now.strftime('%y%m%d')}"
    end

    def bump
      write_version(Bumper.bumped(@info.version, @type, @info.now))
    end

    private

    def write_version(version)
      dir = @info.dirname
      File.write(File.join(dir, '.version'), "#{version}\n")
      [@info.project_rb, @info.readme, @info.gemspec].each do |file|
        path = File.join(dir, file)
        File.sub!(path, /\d+\.\d+\.\d+/, version) if File.exist?(path)
      end
    end
  end
end
