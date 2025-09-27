# frozen_string_literal: true

# ## wile publish ##
# Usage:
#   wile publish <version> # publish a new version
module Wile
  # This file is loaded upon a :publish task request.
  # :reek:MissingSafeMethod
  class Tasks
    PUBLISH_USAGE = ['publish: Takes one argument.',
                     1, /^\d+\.\d+\.\d+$/, Set[]].freeze

    def publish(options)
      version, = Usage.new(options, *PUBLISH_USAGE).args
      verify_version! version
      gmu = project_ready!
      publish_and_archive! gmu
      commit_and_tag! version
    end

    private

    # :reek:UtilityFunction
    def verify_version!(version)
      Info.info.verify_version! version
      Git.already_published! version
    end

    # :reek:UtilityFunction
    def commit_and_tag!(version)
      Git.commit!(version)
      Git.tag!(version)
      Git.push!
    end

    # :reek:UtilityFunction
    def publish_and_archive!(gmu)
      pkg = gmu.build! # builds gem pkg
      gmu.push! pkg # pushes gem pkg to rubygems.org
      # mv pkg ./pkg/ and updates History.txt
      Project.archive pkg
    end

    # :reek:UtilityFunction
    def project_ready!
      Git.clean!
      gmu = GemUtils.new
      gmu.clean! && gmu.ready!
      Test.test!
      gmu
    end
  end
end
