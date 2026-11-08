# frozen_string_literal: true

# SampleRefinements fixture tests refine and singleton_class scopes.
module SampleRefinements
  refine Array do
    def report
      :ready
    end
  end

  refine String do
    def report
      perform
    end

    def perform
      :done
    end
  end

  refine File.singleton_class do
    def activate
      :active
    end
  end
end
