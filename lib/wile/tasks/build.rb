# frozen_string_literal: true

# ## wile build ##
# Builds the gem pkg.
# Will refuse(unless forced) if git status is not clean.
# Usage:
#   wile build [--force] # build gem pkg
module Wile
  # This file is loaded upon a :build task request.
  class Tasks
    BUILD_USAGE = ['build: Takes no arguments with optional force flag.',
                   0, Set['force']].freeze

    # :reek:UtilityFunction
    def build(options, gmu = GemUtils.new)
      Utilities.verify_project_root!
      Usage.new(options, *BUILD_USAGE)
      verify_build(gmu) unless options.force?
      gmu.build!
    end

    private

    # :reek:UtilityFunction
    def verify_build(gmu)
      Git.clean!
      gmu.clean!
      gmu.ready!
    end
  end
end
