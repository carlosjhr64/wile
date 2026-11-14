# frozen_string_literal: true

# ## wile bump ##
# Usage:
#   wile bump [major|minor|build] # bump the version number
module Wile
  # This file is loaded upon a :bump task request.
  class Tasks
    using WileRefinements

    BUMP_USAGE = ['bump: Takes one argument(major|minor|build).',
                  (..1), /^(major|minor|build)$/, Set[]].freeze

    def bump(options, info = Info.info)
      Utilities.verify_project_root!
      type, = Usage.new(options, *BUMP_USAGE).args
      version = bumped(info.version, type, info.now)
      write_version(info, version)
    end

    private

    # :reek:FeatureEnvy :reek:UtilityFunction
    def write_version(info, version)
      dir = info.dirname
      File.write(File.join(dir, '.version'), "#{version}\n")
      [info.project_rb, info.readme, info.gemspec].each do |file|
        path = File.join(dir, file)
        File.sub!(path, /\d+\.\d+\.\d+/, version) if File.exist?(path)
      end
    end

    # :reek:ControlParameter :reek:UtilityFunction
    def bumped(version, type, now = Time.now)
      major, minor, = version.split('.').map(&:to_i)
      case type
      when 'major'
        major += 1
        minor = 0
      when 'minor'
        minor += 1
      end
      "#{major}.#{minor}.#{now.strftime('%y%m%d')}"
    end
  end
end
