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

    def ruby(options)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      match = Usage.new(options, *RUBY_USAGE).args || []
      RubyLister.new(match).list
    end
  end

  # Lists and filters project Ruby files.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::RubyLister
    def initialize(match = [])
      @match = match
    end

    def list
      Project.rbfiles.sort.each do |file|
        puts file if @match.empty? || @match.any? { file.match?(it) }
      end
    end
  end
  Tasks.private_constant :RubyLister
end
