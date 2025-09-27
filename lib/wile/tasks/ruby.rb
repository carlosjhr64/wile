# frozen_string_literal: true

# ## wile ruby ###
# List all ruby files in the project.
# If the 'git' token is given, then
# it list all the ruby files in git.
# Usage:
#   wile ruby [git] # lists all ruby files
module Wile
  # This file is loaded upon a :ruby task request.
  class Tasks
    RUBY_USAGE = ['ruby: May only take "git" an an argument',
                  (..1), /^git$/, Set[]].freeze

    def ruby(options)
      token, = Usage.new(options, *RUBY_USAGE).args
      Project.rbfiles(token&.to_sym).sort.each { puts it }
    end
  end
end
