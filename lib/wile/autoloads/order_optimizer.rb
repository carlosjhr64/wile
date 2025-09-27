# frozen_string_literal: true

# Wile namespace.
module Wile
  # OrderOptimizer class provides a way to optimize the order of elements
  # :reek:TooManyInstanceVariables
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
      # Autoload and include OrderSwap if sort type is not the default :bcmv
      OrderOptimizer.include OrderSwap unless @sort == :bcmv

      rj = ->(v) { v.to_s.rjust(8) }
      start = Time.now
      warn "# Start: #{rj[@value]}\tSort: #{@sort}\tN: #{@order.size}".magenta
      method(@sort).call
      elapsed = Time.now - start
      warn "# End:   #{rj[@value]}\tTime: #{elapsed}".magenta
    end

    def to_a
      @order
    end

    private

    # Best combination move
    # :reek:TooManyStatements :reek:UncommunicativeVariableName
    def bcmv
      # rubocop:disable Style/ParallelAssignment
      min, a, @improved = @value, (0...@order.size).to_a, true
      while @improved
        @improved, best = false, nil
        a.combination(2).each do |i, j|
          v = move_valuation(i, j)
          min, best = v, [i, j] if v < min
        end
        move(*best, min) if best
      end
      # rubocop:enable Style/ParallelAssignment
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
  end
end
