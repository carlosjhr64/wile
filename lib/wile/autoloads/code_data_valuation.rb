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
    # :reek:TooManyStatements
    # :reek:UncommunicativeVariableName
    def total(order)
      # Reject if the sections is different
      return Float::INFINITY unless @sections == get_sections(order)

      # Preference of alphabetical order:
      sum = order.each_cons(2).sum { |a, b| a > b ? 1 : 0 }
      warn "Alphabetical: #{sum}".gray if @trace
      # Want to minimize the distance from the dependencies:
      (@order = order).each_with_index do |name, start|
        d2 = dependencies_sum(name, start, @data.dependencies(name))
        warn "#{name}: #{d2}".gray if @trace
        sum += d2
      end
      sum
    end

    private

    def get_sections(order)
      order.map { @data.category it }.chunk { it }.map(&:first)
    end

    # :reek:TooManyStatements
    # :reek:UncommunicativeVariableName d0
    def dependencies_sum(name, start, dependencies)
      dependencies.sum do |dependency|
        j = @order.index(dependency)
        # rubocop:disable Style/ParallelAssignment
        (flipped = j < start) ? (i, j = j, start) : (i = start)
        # rubocop:enable Style/ParallelAssignment
        d0 = flipped ? dflipped(name, dependency) : dinit(name, dependency)
        distance_squared(d0, i, j)
      end
    end

    def dflipped(nme, dpc) = @data.dependency_index(nme, dpc)
    def dinit(nme, dpc) = 1 + @data.size(nme) - dflipped(nme, dpc)

    def distance_squared(distance, start, stop)
      distance += (start + 1).upto(stop - 1).sum { @data.size @order[it] }
      distance * distance
    end
  end
end
