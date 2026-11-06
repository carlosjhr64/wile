# frozen_string_literal: true

# :reek:IrresponsibleModule
module SampleCalls
  CONFIG = { port: 8080 }.freeze
  PATTERN = /^\w+$/

  # :reek:IrresponsibleModule
  class Caller
    # :reek:TooManyStatements :reek:UtilityFunction
    def perform(val)
      File.exist?(val)
      puts val
      warn val
      CONFIG.fetch(:port)
      PATTERN.match?(val)
      nil
    end

    def validate(val)
      perform(val)
    end
  end
end
