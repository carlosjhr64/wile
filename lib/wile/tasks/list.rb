# frozen_string_literal: true

# ## wile list ##
# Usage:
#   wile list [<match>+] # list tasks(by match)
module Wile
  # This file is loaded upon a :list task request.
  # :reek:InstanceVariableAssumption
  class Tasks
    LIST_USAGE = ['list: Optionally takes one or more tasks.', Set[]].freeze

    # :reek:NestedIterators :reek:TooManyStatements
    def list(options, tasks = @tasks)
      if (args = Usage.new(options, *LIST_USAGE).args)
        tasks = @tasks.select { |tsk| args.any? { |arg| tsk.match?(arg) } }
      end
      raise 'No task matched' if tasks.empty?

      puts
      tasks.each { puts_usage(it) }
      puts
    end

    private

    # :reek:TooManyStatements
    def puts_usage(task)
      usage, comment = Help.usage(task).split(/\s*#\s*/, 2)
      cmd, task, args = usage.split(/\s+/, 3)
      puts comment ? "# #{comment.capitalize}:".gray : '# ---'.gray
      print "  #{cmd}  #{task.blue.bold}"
      print "  #{args}" if args
      puts
    end
  end
end
