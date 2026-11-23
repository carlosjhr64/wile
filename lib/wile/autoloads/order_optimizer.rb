# frozen_string_literal: true

# Wile namespace.
module Wile
  # Holds mutable ordering state and primitive move/swap/permutation operations.
  class OrderState
    attr_reader :value

    def improved?
      prev = @value
      yield
      @value < prev
    end

    def indices = (0...@order.size).to_a

    def initialize(order, valuation)
      @order     = order
      @valuation = valuation
      @value     = @valuation.call(@order)
    end

    def move_score(pair)
      from, dest = pair
      @order.insert(dest, @order.delete_at(from))
      val = @valuation.call(@order)
      @order.insert(from, @order.delete_at(dest))
      val
    end

    def neighbor_pairs = (0..(@order.size - 2)).map { [it, it + 1] }

    def size = @order.size

    def to_a = @order

    def apply_move(pair, val)
      from, dest = pair
      @order.insert(dest, @order.delete_at(from))
      @value = val
    end

    def try_swap(pair)
      val = swap_score(pair)
      apply_swap(pair, val) if val < @value
    end

    def swap_score(pair)
      items = @order.values_at(*pair)
      swap_at(pair, items.reverse)
      val = @valuation.call(@order)
      swap_at(pair, items)
      val
    end

    def apply_swap(pair, val)
      swap_at(pair, @order.values_at(*pair).reverse)
      @value = val
    end

    def permute_slice(start, width)
      slice = @order[start, width]
      best = slice
      slice.permutation { best = it if better_slice?(start, width, it) }
      @order[start, width] = best
    end

    private

    def swap_at(pair, items)
      first, second = pair
      @order[first], @order[second] = items
    end

    def better_slice?(start, width, cand)
      @order[start, width] = cand
      val = @valuation.call(@order)
      return false unless val < @value

      @value = val
      true
    end
  end

  # Optimizes the order of elements using a caller-supplied valuation block.
  class OrderOptimizer
    SORTS = %i[bcmv nswp cswp bnswp bcswp bprm].freeze
    PERM_WIDTH = 7

    def initialize(order, sort: :bcmv, &valuation)
      raise 'Invalid sort method' unless SORTS.include?(sort)

      @state = OrderState.new(order, valuation)
      @sort  = sort
    end

    def to_a = @state.to_a

    def self.elapsed_since(start) = Time.now - start

    def optimize
      start = Time.now
      warn "# Start: #{padded_value}\tSort: #{@sort}\tN: #{@state.size}".gray
      method(@sort).call
      elapsed = OrderOptimizer.elapsed_since(start)
      warn "# End:   #{padded_value}\tTime: #{elapsed}".gray
    end

    private

    # category: sorts

    # Neighbor swaps
    def nswp
      pairs = @state.neighbor_pairs
      seq = pairs + pairs[0...-1].reverse
      repeat_improved { seq.each { @state.try_swap(it) } }
    end

    # Best permutation
    def bprm
      size = @state.size
      width = [size, PERM_WIDTH].min
      loop { break unless sweep_perm(size - width, width) }
    end

    # Best combination move
    def bcmv
      pairs = @state.indices.permutation(2)
      repeat_best(pairs, @state.method(:move_score)) do |best, min|
        @state.apply_move(best, min)
      end
    end

    # Combination swaps
    def cswp
      pairs = @state.indices.combination(2)
      repeat_improved { pairs.each { @state.try_swap(it) } }
    end

    # Best combination swaps
    def bcswp
      pairs = @state.indices.combination(2)
      repeat_best(pairs, @state.method(:swap_score)) do |best, min|
        @state.apply_swap(best, min)
      end
    end

    # Best neighbor swaps
    def bnswp
      repeat_best(@state.neighbor_pairs,
                  @state.method(:swap_score)) do |best, min|
        @state.apply_swap(best, min)
      end
    end

    # category: helpers

    def repeat_improved(&) = loop { break unless @state.improved?(&) }

    def padded_value = @state.value.to_s.rjust(8)

    def sweep_perm(last, width)
      [0.upto(last), (last - 1).downto(0)].all? do |range|
        @state.improved? { range.each { @state.permute_slice(it, width) } }
      end
    end

    def repeat_best(pairs, scorer)
      loop do
        best, min = best_pair(pairs, scorer)
        break unless best

        yield(best, min)
      end
    end

    def best_pair(pairs, scorer)
      best, min = pairs.map { [it, scorer.call(it)] }.min_by(&:last)
      best && min < @state.value ? [best, min] : nil
    end
  end
end
