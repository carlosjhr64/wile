# frozen_string_literal: true

# Wile namespace.
module Wile
  # Tasks class manages the tasks available in the Wile framework.
  class Tasks
    using Refinement
    include Sysexits

    def start_with(string)
      @tasks.select { it.start_with? string }.unique
    end

    def end_with(string)
      @tasks.select { it.end_with? string }.unique
    end

    def find(string, task = nil)
      return nil if string.length < 2
      return task if (task = start_with(string))
      return task if (task = end_with(string))
      return task if (task = includes(string))

      nil
    end

    def includes(string)
      @tasks.select { it.to_s.include? string }.unique
    end

    def initialize
      @tasks = Dir.glob("#{__dir__}/tasks/*.rb")
                  .map { File.basename(it, '.rb').to_sym }
    end
  end
end
