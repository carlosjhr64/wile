# frozen_string_literal: true

# ## wile ruby ##
# List ruby files in the project.
# Usage:
#   wile ruby [<match>+] # lists ruby files
module Wile
  # This file is loaded upon a :ruby task request.
  class Tasks
    RUBY_USAGE = [
      'ruby: Optionally takes file matchers.',
      Set[]
    ].freeze

    # :reek:FeatureEnvy :reek:TooManyStatements
    def ruby(options)
      Utilities.verify_project_root!
      match = Usage.new(options, *RUBY_USAGE).args || []
      files = Project.rbfiles.sort
      files.select! { |fn| match.any? { fn.match? it } } unless match.empty?
      files.each { puts it }
    end
  end
end
