# frozen_string_literal: true

# Wile namespace.
module Wile
  # Responds class provides a way to check if a class responds to a method
  # in a pristine Ruby environment.
  class Responds
    # One-liner script that checks if a given class is defined and
    # responds to a given method in a pristine Ruby environment.
    SCRIPT = 'a, b = $_.strip.split(".", 2).map(&:to_sym); ' \
             'puts (Object.const_defined?(a) && ' \
             'Object.const_get(a).respond_to?(b)); ' \
             '$stdout.flush'
    ONELINER = ['ruby', '-n', '-e', SCRIPT].freeze
    METHOD_CALL = /^[A-Z]\w*\.\w+[!=?]?$/

    private_constant :METHOD_CALL, :ONELINER, :SCRIPT

    def initialize
      @cache = {}
      IO.popen(ONELINER, 'r+') do |io|
        @io = io
        yield self
      end
    end

    def ok?(string)
      return false unless METHOD_CALL.match?(string)

      @cache.fetch(string) do
        @io.puts(string)
        @cache[string] = (@io.gets&.chomp == 'true')
      end
    end
  end
end
