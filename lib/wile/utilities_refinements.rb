# frozen_string_literal: true

# Wile namespace.
module Wile
  # Refinements for Utilities.
  module UtilitiesRefinements
    ALLOWED = /\A[a-zA-Z0-9._][a-zA-Z0-9._-]*\z/

    # category: array

    refine Array do
      # Returns self, the array.
      def weird_filename!
        each(&:weird_filename!)
      end
    end

    # category: object

    refine Object do
      def weird_filename!
        raise "Expected a String filename, got #{self.class} instead"
      end
    end

    # category: string

    refine String do
      def sw
        Shellwords.escape(self)
      end

      def weird_filename!
        return self if valid_encoding? &&
                       split('/').reject(&:empty?).all? { ALLOWED.match?(it) }

        raise "Weird filename: #{self}"
      end
    end
  end
end
