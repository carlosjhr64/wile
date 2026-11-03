# frozen_string_literal: true

# Wile namespace.
module Wile
  # Tasks class manages the tasks available in the Wile framework.
  class Tasks
    using Refinement
    include Sysexits

    def initialize
      @tasks = (Dir.glob('.tasks/*.rb') + Dir.glob("#{__dir__}/tasks/*.rb"))
               .map { File.basename(it, '.rb').to_sym }.uniq
    end

    def find(string)
      return nil if string.to_s.length < 2

      start_with(string) || end_with(string) || includes(string)
    end

    private

    def start_with(string)
      @tasks.select { it.start_with? string }.unique
    end

    def end_with(string)
      @tasks.select { it.end_with? string }.unique
    end

    def includes(string)
      @tasks.select { it.to_s.include? string }.unique
    end
  end
end
