# frozen_string_literal: true

# ## wile build ##
# Builds the gem pkg.
# Will refuse(unless forced) if git status is not clean.
# Usage:
#   wile build [-f|--force] # build gem pkg
module Wile
  # This file is loaded upon a :build task request.
  class Tasks
    BUILD_USAGE = ['build: Takes no arguments with optional force flag.',
                   0, Set['force']].freeze

    # :reek:UtilityFunction
    def build(options)
      Usage.new(options, *BUILD_USAGE)
      gmu = GemUtils.new
      Git.clean! && gmu.clean! unless options.force?
      gmu.ready!
      gmu.build!
    end
  end
end
