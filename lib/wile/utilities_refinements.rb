# frozen_string_literal: true

# Wile namespace.
module Wile
  # Refinements for Utilities.
  module UtilitiesRefinements
    refine String do
      def sw
        Shellwords.escape(self)
      end
    end
  end
end
