# encoding: utf-8
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

          # asserting that there was an argument at all
          return unless last_arg

          # asserting last argument is an optional argument
          return unless last_arg.optarg_type?

          arg, default_value = *last_arg

          # asserting default value is a hash
          return unless default_value.hash_type?

          # asserting default value is empty hash
          *key_value_pairs = *default_value
          return unless key_value_pairs.empty?

          # Check for suspicious argument names
          return unless name_in_suspicious_param_names?(arg)

          add_offense(last_arg, :expression, MSG)
        end

        def validate_config
          return unless target_ruby_version < 2.0

          raise ValidationError, 'The `Style/OptionHash` cop is only ' \
                                'compatible with Ruby 2.0 and up, but the ' \
                                'target Ruby version for your project is ' \
                                "1.9.\nPlease disable this cop or adjust " \
                                'the `TargetRubyVersion` parameter in your ' \
                                'configuration.'
        end

        private

        def name_in_suspicious_param_names?(arg_name)
          cop_config.key?('SuspiciousParamNames') &&
            cop_config['SuspiciousParamNames'].include?(arg_name.to_s)
        end
      end
    end
  end
end
