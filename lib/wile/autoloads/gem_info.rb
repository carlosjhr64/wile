# frozen_string_literal: true

# Namespace: Wile
module Wile
  # Stores gem or OS command dependency metadata.
  GemInfo = Struct.new(:name, :version, :type, :filename, :require) do
    def <=>(other)
      (cmp = name <=> other.name).zero? ? version <=> other.version : cmp
    end
  end
end
