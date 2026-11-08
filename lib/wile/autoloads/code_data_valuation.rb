# frozen_string_literal: true

# Wile namespace.
module Wile
  # CodeDataValuation class sums up the total distance among dependencies.
  class CodeDataValuation
    # category: initialization
    # :reek:BooleanParameter
    def initialize(data, trace: false)
      @data = data
      @trace = trace
      @sections = get_sections(data.names)
      @order = nil
    end

    # category: public
    def total(order)
      # Reject if the sections are different
      return Float::INFINITY unless @sections == get_sections(order)

      # Sum alphabetical and dependency distances:
      (@order = order).each_with_index.sum(alphabetical(order)) do |name, start|
        dep_sum = dependencies_sum(name, start)
        warn "#{name}: #{dep_sum}".gray if @trace
        dep_sum
      end
    end

    private

    def get_sections(order)
      order.map { @data.category it }.chunk { it }.map(&:first)
    end

    def alphabetical(order)
      sum = order.each_cons(2).count { |prev, curr| prev > curr }
      warn "Alphabetical: #{sum}".gray if @trace
      sum
    end

    def dependencies_sum(name, start)
      @data.dependencies(name).sum do |dep|
        dep_idx = @order.index(dep)
        if dep_idx < start
          distance_squared(dflipped(name, dep), dep_idx, start)
        else
          distance_squared(dinit(name, dep), start, dep_idx)
        end
      end
    end

    def dflipped(name, dep) = @data.dependency_index(name, dep)
    def dinit(name, dep) = 1 + @data.size(name) - dflipped(name, dep)

    def distance_squared(distance, start, stop)
      distance += (start + 1).upto(stop - 1).sum { @data.size @order[it] }
      distance * distance
    end
  end
end
