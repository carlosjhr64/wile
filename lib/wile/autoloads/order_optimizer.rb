# frozen_string_literal: true

# Wile namespace.
module Wile
  # OrderOptimizer class provides a way to optimize the order of elements
  # :reek:DataClump :reek:DuplicateMethodCall :reek:RepeatedConditional
  # :reek:TooManyInstanceVariables
  # rubocop:disable-next Metrics/ClassLength
  class OrderOptimizer
    SORTS = %i[bcmv nswp cswp bnswp bcswp bprm].freeze

    def initialize(order, sort: :bcmv, &valuation)
      raise 'Invalid sort method' unless SORTS.include?(sort)

      @order     = order
      @sort      = sort
      @valuation = valuation
      @value     = @valuation.call(@order)
      @improved  = nil
    end

    # :reek:DuplicateMethodCall Time.now are different times!
    # :reek:TooManyStatements :reek:UncommunicativeVariableName
    def optimize
      rj = ->(v) { v.to_s.rjust(8) }
      start = Time.now
      warn "# Start: #{rj[@value]}\tSort: #{@sort}\tN: #{@order.size}".gray
      method(@sort).call
      elapsed = Time.now - start
      warn "# End:   #{rj[@value]}\tTime: #{elapsed}".gray
    end

    def to_a
      @order
    end

    private

    # rubocop:disable Style/ParallelAssignment

    # Best combination move
    # :reek:TooManyStatements :reek:UncommunicativeVariableName
    def bcmv
      min, a, @improved = @value, (0...@order.size).to_a, true
      while @improved
        @improved, best = false, nil
        a.combination(2).each do |i, j|
          v = move_valuation(i, j)
          min, best = v, [i, j] if v < min
        end
        move(*best, min) if best
      end
    end

    # :reek:UncommunicativeVariableName
    def move_valuation(one, two)
      move(one, two)
      v = @valuation.call(@order)
      move(two, one)
      v
    end

    def move(one, two, val = nil)
      @order.insert(two, @order.delete_at(one))
      val ||= @valuation.call(@order)
      if val < @value
        @value = val
        @improved ||= true
      else
        @order.insert(one, @order.delete_at(two))
      end
    end

    # Best neighbour swaps
    # :reek:TooManyStatements :reek:UncommunicativeVariableName
    def bnswp
      min, n, @improved = @value, @order.size - 2, true
      while @improved
        @improved, best = false, nil
        0.upto(n) do |i|
          v = swap_valuation(i)
          min, best = v, i if v < min
        end
        swap(best, best + 1, min) if best
      end
    end

    # :reek:UncommunicativeVariableName
    def swap_valuation(one, two = one + 1)
      @order[one], @order[two] = @order[two], @order[one]
      v = @valuation.call(@order)
      @order[one], @order[two] = @order[two], @order[one]
      v
    end

    # Best combination swaps
    # :reek:TooManyStatements :reek:UncommunicativeVariableName
    def bcswp
      min, a, @improved = @value, (0...@order.size).to_a, true
      while @improved
        @improved, best = false, nil
        a.combination(2).each do |i, j|
          v = swap_valuation(i, j)
          min, best = v, [i, j] if v < min
        end
        swap(*best, min) if best
      end
    end

    # :reek:DuplicateMethodCall :reek:UncommunicativeVariableName
    def swap(one, two, val = nil)
      @order[one], @order[two] = @order[two], @order[one]
      val ||= @valuation.call(@order)
      if val < @value
        @value = val
        @improved ||= true
      else
        @order[one], @order[two] = @order[two], @order[one]
      end
    end

    # Combination swaps
    # :reek:TooManyStatements :reek:UncommunicativeVariableName
    def cswp
      a, @improved = (0...@order.size).to_a, true
      while @improved
        @improved = false
        a.combination(2).each { |i, j| swap(i, j) }
      end
    end

    # Neighbour swaps
    # :reek:TooManyStatements :reek:UncommunicativeVariableName
    def nswp
      n = @order.size - 2
      @improved = true
      while @improved
        @improved = false
        0.upto(n) { |i| swap(i, i + 1) }
        (n - 1).downto(0) { |i| swap(i, i + 1) }
      end
    end

    # :reek:NestedIterators :reek:TooManyStatements
    # :reek:UncommunicativeVariableName
    def permutations(start, slice)
      best = slice
      slice.permutation.each do |slc|
        slc.each_with_index { |s, j| @order[start + j] = s }
        v = @valuation.call(@order)
        best, @value, @improved = slc, v, true if v < @value
      end
      best.each_with_index { |s, j| @order[start + j] = s }
    end

    # Best permutation
    # :reek:DuplicateMethodCall :reek:TooManyStatements
    # :reek:UncommunicativeVariableName
    def bprm
      n, m, @improved = @order.size, 7, true
      m = n if n < m
      while @improved
        @improved = false
        0.upto(n - m) { |i| permutations(i, @order.slice(i...(i + m))) }
        break unless @improved

        @improved = false
        (n - m - 1).downto(0) { |i| permutations(i, @order.slice(i...(i + m))) }
      end
    end

    # rubocop:enable Style/ParallelAssignment
  end
end
