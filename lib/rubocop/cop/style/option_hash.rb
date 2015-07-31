# encoding: utf-8

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
        MSG = 'Prefer keyword arguments to options hashes.'

        def on_args(node)
          return unless supports_keyword_arguments?

          *_but_last, last_arg = *node

          # asserting that there was an argument at all
          return unless last_arg

          # asserting last argument is an optional argument
          return unless last_arg.optarg_type?

          _, default_value = *last_arg

          # asserting default value is a hash
          return unless default_value.hash_type?

          # asserting default value is empty hash
          *key_value_pairs = *default_value
          return unless key_value_pairs.empty?

          add_offense(last_arg, :expression, MSG)
        end

        private

        def supports_keyword_arguments?
          RUBY_VERSION >= '2.0.0'
        end
      end
    end
  end
end
