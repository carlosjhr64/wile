# frozen_string_literal: true

# ## wile order ##
# Suggests an order to your methods.
# Sort types:
# * bcmv:  best combination move
# * nswp:  neighbour swap
# * cswp:  combination swap
# * bnswp: best neighbour swap
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
  # :reek:UncommunicativeVariableName
  class Tasks
    ORDER_USAGE = ['order: Takes one or two arguments.', (1..2), Set[]].freeze

    # :reek:TooManyStatements
    def order(options)
      filename, sort = Usage.new(options, ORDER_USAGE).args
      sort = sort&.to_sym || :bcmv
      raise "does not exist: #{filename}" unless File.exist?(filename)

      data = CodeData.new(filename)
      order_subcommands(data, sort) unless OrderOptimizer::SORTS.include?(sort)

      valuation = CodeDataValuation.new(data)
      order_do(data.names, valuation, sort) || exit(EX_FAIL)
    end

    private

    def order_do(names, valuation, sort)
      opt = OrderOptimizer.new(names.dup, sort:) { valuation.total(it) }
      opt.optimize
      order_report(opt.to_a, names)
    end

    # :reek:TooManyStatements :reek:BooleanParameter
    def order_report(optimized, names, ordered: true)
      optimized.each_with_index do |name, idx|
        old = names[idx]
        if name == old then puts name.green
        else
          ordered &&= false
          j, k, a, b = jkab(idx, names, name, optimized, old)
          puts "#{name.red}\t#{a}#{(j - idx).abs}\t#{old} #{b}#{(idx - k).abs}"
        end
      end
      ordered
    end

    # :reek:LongParameterList :reek:UtilityFunction :reek:TooManyStatements
    def jkab(idx, names, name, optimized, old)
      j = names.index(name)
      k = optimized.index(old)
      a = j < idx ? '↓' : '↑'
      b = idx < k ? '↓' : '↑'
      [j, k, a, b]
    end

    # category: subcommands

    def order_subcommands(data, cmd)
      unless CodeDataFunction.public_methods.include?(cmd)
        raise "invalid sort: #{cmd}"
      end

      CodeDataFunction.method(cmd).call(data)
      exit(EX_OK)
    end
  end
end
