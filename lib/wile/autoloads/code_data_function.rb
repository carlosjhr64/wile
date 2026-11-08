# frozen_string_literal: true

# Wile namespace.
module Wile
  # CodeDataFunction module provides functions to look at code data.
  module CodeDataFunction
    include Sysexits

    def self.dump(data)
      puts 'Data:'.blue
      puts JSON.pretty_generate data.data
      puts 'Index:'.blue
      puts JSON.pretty_generate data.index
    end

    def self.index(data)
      data.names.each { print_dependencies(it, data) }
    end

    def self.isolate(data)
      data.names.each do |name|
        puts name if data.dependencies(name).empty? &&
                     data.dependants(name).empty?
      end
    end

    def self.total(data)
      valuation = CodeDataValuation.new(data, trace: true)
      puts valuation.total(data.names)
    end

    def self.qc(data)
      exit(EX_DATAERR) unless data.names.map { qc_name?(it, data) }.all?
      puts 'OK'.green
    end

    # category: private

    def self.print_dependencies(name, data)
      data.dependencies(name).each do |dep|
        idx = data.dependency_index(name, dep)
        puts "#{name}-#{dep}:\t#{idx}"
      end
    end

    def self.qc_name?(name, data)
      [
        qc_circular?(name, data),
        qc_dependencies?(name, data),
        qc_dependants?(name, data)
      ].all?
    end

    def self.qc_dependencies?(name, data)
      qc_symmetric?(name, data.dependencies(name), '=>') { data.dependants(it) }
    end

    def self.qc_dependants?(name, data)
      qc_symmetric?(name, data.dependants(name), '<=') { data.dependencies(it) }
    end

    def self.qc_symmetric?(name, targets, arrow)
      missing = targets.reject { yield(it).include?(name) }
      missing.each { warn "#{name} #{arrow} #{it}".red }.empty?
    end

    def self.qc_circular?(name, data)
      circular = data.dependencies(name) & data.dependants(name)
      return true if circular.empty?

      warn "#{name}: #{circular.join(', ')}".red
      false
    end

    private_class_method :print_dependencies, :qc_name?, :qc_symmetric?,
                         :qc_circular?, :qc_dependencies?, :qc_dependants?
  end
end
