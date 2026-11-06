# frozen_string_literal: true

# ## wile ruby ##
# List all ruby files in the project.
# With --git, lists only ruby files in git.
# Usage:
#   wile ruby [<match>+] [--git] # lists all ruby files
module Wile
  # This file is loaded upon a :ruby task request.
  class Tasks
    RUBY_USAGE = [
      'ruby: Optionally takes file matchers with optional git flag.',
      Set['git']
    ].freeze

    # :reek:FeatureEnvy :reek:TooManyStatements
    def ruby(options)
      Utilities.verify_project_root!
      match = Usage.new(options, *RUBY_USAGE).args || []
      git = options.git? || (match.first == 'git' && match.shift)
      files = Project.rbfiles(git ? :git : nil).sort
      files.select! { |fn| match.any? { fn.match? it } } unless match.empty?
      files.each { puts it }
    end
  end
end
