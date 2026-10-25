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

    # :reek:NestedIterators
    # :reek:UncommunicativeVariableName i is just index
    def self.index(data)
      data.names.each do |name|
        data.dependencies(name).each do |dep|
          i = data.dependency_index(name, dep)
          puts "#{name}-#{dep}:\t#{i}"
        end
      end
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

    # :reek:TooManyStatements
    def self.qc(data)
      ok = true
      data.names.each do |name|
        qc_circular(name, data)     or ok = false
        qc_dependencies(name, data) or ok = false
        qc_dependants(name, data)   or ok = false
      end
      exit(EX_DATAERR) unless ok
      puts 'OK'.green
    end

    # category: private

    # :reek:TooManyStatements
    def self.qc_dependencies(name, data)
      ok = true
      data.dependencies(name).each do |dependency|
        next if data.dependants(dependency).include?(name)

        warn "#{name} => #{dependency}".red
        ok = false
      end
      ok
    end

    # :reek:TooManyStatements
    def self.qc_dependants(name, data)
      ok = true
      data.dependants(name).each do |dependant|
        next if data.dependencies(dependant).include?(name)

        warn "#{name} <= #{dependant}".red
        ok = false
      end
      ok
    end

    # :reek:TooManyStatements :reek:UncommunicativeVariableName
    def self.qc_circular(name, data)
      ok = true
      a = Set.new data.dependencies(name)
      b = Set.new data.dependants(name)
      c = a & b
      unless c.empty?
        warn "#{name}: #{c.join(', ')}".red
        ok = false
      end
      ok
    end

    private_class_method :qc_circular, :qc_dependencies, :qc_dependants
  end
end
