# frozen_string_literal: true

# ## wile bump ##
# Usage:
#   wile bump [major|minor|build] # Bump the version number
module Wile
  # This file is loaded upon a :bump task request.
  class Tasks
    using Refinement

    BUMP_USAGE = ['bump: Takes one argument(major|minor|build).',
                  (..1), /^(major|minor|build)$/, Set[]].freeze

    # :reek:FeatureEnvy :reek:TooManyStatements
    def bump(options)
      type, = Usage.new(options, *BUMP_USAGE).args
      info = Info.info
      version = bumped(info.version, type)
      File.write('.version', "#{version}\n")
      [info.project_rb, info.readme, info.gemspec].each do |file|
        File.sub!(file, /\d+\.\d+\.\d+/, version) if File.exist?(file)
      end
    end

    private

    # :reek:ControlParameter and :reek:UtilityFunction
    # :reek:TooManyStatements
    def bumped(version, type)
      major, minor, = version.split('.')
      # Bump the version number
      build = Time.now.strftime('%y%m%d')
      case type
      when 'major'
        major = major.to_i + 1
        minor = 0
      when 'minor'
        minor = minor.to_i + 1
      end
      [major, minor, build].join('.')
    end
  end
end
