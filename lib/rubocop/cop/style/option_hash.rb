# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for options hashes and discourages them if the
      # current Ruby version supports keyword arguments.
      #
      # @example
      #   Instead of:
      #
      #   def fry(options = {})
      #     temperature = options.fetch(:temperature, 300)
      #     ...
      #   end
      #
      #   Prefer:
      #
      #   def fry(temperature: 300)
      #     ...
      #   end
      class OptionHash < Cop
        MSG = 'Prefer keyword arguments to options hashes.'.freeze

        def on_args(node)
          *_but_last, last_arg = *node

          return unless last_arg && last_arg.optarg_type?

          arg, default_value = *last_arg

          return unless default_value.hash_type? && default_value.pairs.empty?
          return unless suspicious_name?(arg)

          add_offense(last_arg)
        end

        private

        def suspicious_name?(arg_name)
          cop_config.key?('SuspiciousParamNames') &&
            cop_config['SuspiciousParamNames'].include?(arg_name.to_s)
        end
      end
    end
  end
end
