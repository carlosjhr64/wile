# frozen_string_literal: true

# ## wile help ##
# Usage:
#   wile help [<task>+] # show task's help
module Wile
  # This file is loaded upon a :help task request.
  class Tasks
    HELP_USAGE = ['help: Takes one or more tasks.', Set[]].freeze

    def help(options)
      tasks = Usage.new(options, *HELP_USAGE).args&.map { find it }&.compact
      tasks ||= %i[help list]
      raise UsageError, 'help: No tasks matched.' if tasks && tasks.empty?

      display_help(tasks)
    end

    def display_help(tasks)
      puts
      tasks.each do |task|
        puts Help[task]
        puts
      end
    end
  end
end
