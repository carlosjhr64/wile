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

    # :reek:UtilityFunction :reek:TooManyStatements
    def build(options)
      Utilities.verify_project_root!
      Usage.new(options, *BUILD_USAGE)
      gmu = GemUtils.new
      unless options.force?
        Git.clean! && gmu.clean!
        gmu.ready!
      end
      gmu.build!
    end
  end
end
