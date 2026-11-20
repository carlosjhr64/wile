# frozen_string_literal: true

# Sample fixture exercising attr_reader, attr_writer, and attr_accessor.
module SampleAttrs
  # Sample record with instance and singleton attribute macros.
  # :reek:Attribute
  class Record
    class << self
      attr_reader :default
    end

    attr_reader :name, :count
    attr_writer :label
    attr_accessor :state

    def initialize(name)
      @name = name
      @count = 0
      @label = nil
      @state = :new
    end

    def summary
      "#{name}:#{state}"
    end
  end
end
