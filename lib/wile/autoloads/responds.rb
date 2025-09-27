# frozen_string_literal: true

# Wile namespace.
module Wile
  # Responds class provides a way to check if a class responds to a method
  # in a pristine Ruby environment.
  class Responds
    # One-liner that will check if a given class is defined and
    # responds to a given method in a pristine Ruby environment.
    oneliner = 'a,b=$_.strip.split(%q(.),2).map(&:to_sym);' \
               'puts (Object.const_defined?(a) &&' \
               'Object.const_get(a).respond_to?(b));' \
               '$stdout.flush;'
    ONELINER = "ruby -n -e '#{oneliner}'".freeze

    def initialize
      IO.popen(ONELINER, 'r+') do |io|
        @io = io
        yield self
      end
    end

    def ok?(string)
      return false unless /^[A-Z]\w+\.\w+[!=?]?$/.match?(string)

      @io.puts(string)
      @io.gets.chomp == 'true'
    end
  end
end
