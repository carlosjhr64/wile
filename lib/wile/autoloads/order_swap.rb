# frozen_string_literal: true

# Wile namespace.
module Wile
  # OrderSwap module provides methods to rearrange an array.
  # :reek:DuplicateMethodCall :reek:TooManyStatements
  # :reek:UncommunicativeVariableName
  module OrderSwap
    # rubocop:disable Style/ParallelAssignment

    # Best neighbour swaps
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

    def swap_valuation(one, two = one + 1)
      @order[one], @order[two] = @order[two], @order[one]
      v = @valuation.call(@order)
      @order[one], @order[two] = @order[two], @order[one]
      v
    end

    # Best combination swaps
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
    def cswp
      a, @improved = (0...@order.size).to_a, true
      while @improved
        @improved = false
        a.combination(2).each { |i, j| swap(i, j) }
      end
    end

    # Neighbour swaps
    def nswp
      n = @order.size - 2
      @improved = true
      while @improved
        @improved = false
        0.upto(n) { |i| swap(i, i + 1) }
        (n - 1).downto(0) { |i| swap(i, i + 1) }
      end
    end

    # :reek:NestedIterators
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
