# frozen_string_literal: true

# ## wile order ##
# Suggests an order to your methods.
# Sort types:
# * bcmv:  best combination move
# * nswp:  neighbor swap
# * cswp:  combination swap
# * bnswp: best neighbor swap
# * bcswp: best combination swap
# * bprm:  best permutation
# Specials:
# * dump: prints the data in JSON format
# * index: prints the name.dependency index
# * isolate: prints the isolated methods
# * total: prints the total valuation
# * qc: checks integrity of the data
# Usage:
#   wile order <filename> [<sort-type|specials>] # suggest a methods order
module Wile
  # This file is loaded upon a :order task request.
  class Tasks
    ORDER_USAGE = ['order: Takes one or two arguments.', (1..2), Set[]].freeze

    def order(options)
      filename, sort = Usage.new(options, *ORDER_USAGE).args
      raise "does not exist: #{filename}" unless File.exist?(filename)

      OrderRunner.new(filename, sort&.to_sym || :bcmv).run
    end
  end

  # Runs method-order optimization or CodeDataFunction subcommands.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::OrderRunner
    SPECIALS = %i[dump index isolate total qc].freeze
    MODES = (OrderOptimizer::SORTS + SPECIALS).freeze

    def initialize(filename, sort = :bcmv)
      raise "invalid sort: #{sort}" unless MODES.include?(sort)

      @data = CodeData.new(filename)
      @sort = sort
      @names = @data.names
      @optimized = nil
    end

    def self.delta(from, dest)
      arrow = from < dest ? '↓' : '↑' # UTF-8
      "#{arrow}#{(from - dest).abs}"
    end

    def run
      return run_subcommand if SPECIALS.include?(@sort)

      optimize
      report
      raise unless @optimized == @names
    end

    private

    def run_subcommand
      CodeDataFunction.method(@sort).call(@data)
    end

    def optimize
      valuation = CodeDataValuation.new(@data)
      opt = OrderOptimizer.new(@names.dup, sort: @sort) { valuation.total(it) }
      opt.optimize
      @optimized = opt.to_a
    end

    def report
      @optimized.each_with_index { |name, idx| report_line(name, idx) }
    end

    def format_move(name, old, idx)
      kls = self.class
      moved = kls.delta(@names.index(name), idx)
      shifted = kls.delta(idx, @optimized.index(old))
      "#{name.red}\t#{moved}\t#{old} #{shifted}"
    end

    def report_line(name, idx)
      old = @names[idx]
      return puts name.green if name == old

      puts format_move(name, old, idx)
    end
  end
  Tasks.private_constant :OrderRunner
end
