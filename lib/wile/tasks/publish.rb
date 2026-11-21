# frozen_string_literal: true

# ## wile publish ##
# Verifies version, git state, gemspec freshness, and tests, then builds and
# pushes the gem to RubyGems, archives it to pkg/ and History.txt, and
# commits, tags, and pushes with --follow-tags.
# Usage:
#   wile publish <version> # publish a new version
module Wile
  # This file is loaded upon a :publish task request.
  class Tasks
    PUBLISH_USAGE = ['publish: Takes one argument.',
                     1, /^\d+\.\d+\.\d+$/, Set[]].freeze

    def publish(options)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      version, = Usage.new(options, *PUBLISH_USAGE).args
      Publisher.new(version).publish
    end
  end

  # Orchestrates gem publication, archiving, and git tagging.
  class Publisher
    def initialize(version, gmu = GemUtils.new)
      @version = version
      @gmu = gmu
    end

    def publish
      verify_version
      verify_ready
      publish_and_archive
      commit_and_tag
    end

    private

    def verify_version
      Info.info.verify_version! @version
      Git.verify_unpublished! @version
    end

    def publish_and_archive
      pkg = @gmu.build!
      @gmu.push! pkg
      Project.archive pkg
    end

    def verify_ready
      Git.clean!
      @gmu.clean!
      @gmu.ready!
      Test.test!
    end

    def commit_and_tag
      Git.add! 'History.txt'
      Git.commit! @version, no_verify: true
      Git.tag! @version
      Git.push!
    end
  end
end
