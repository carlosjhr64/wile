# frozen_string_literal: true

# Wile namespace.
module Wile
  # Usage class validates the command-line arguments for a task.
  class Usage
    attr_reader :args

    def initialize(options, message, *validators)
      keys        = options.to_h.keys
      @args       = options.args
      @opts       = keys.grep(String).select { it.length > 1 } - %w[task args]
      @message    = message
      @validators = validators
      validate
    end

    private

    def validate
      @validators.each do |validator|
        raise UsageError, @message unless validator_type_check(validator)
      end
    end

    VALIDATORS = {
      Range => :in_range?,
      Regexp => :match?,
      Integer => :size_of?,
      Set => :allowed_opt?
    }.freeze
    private_constant :VALIDATORS

    def validator_type_check(validator)
      _, mth = VALIDATORS.detect { |type, _| validator.is_a? type }
      raise ArgumentError, "invalid validator: #{validator.inspect}" unless mth

      send(mth, validator)
    end

    def allowed_opt?(validator) = @opts.all? { validator.include?(it) }

    def match?(validator) = !@args || @args.all? { validator.match?(it) }

    def args_size = @args&.size.to_i

    def in_range?(validator) = validator.include?(args_size)

    def size_of?(validator) = validator == args_size
  end
end
