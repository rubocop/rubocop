# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that `raise` or `fail` is called with an exception class
      # and not just a String, which will raise a RuntimeError.
      # See also Style/RaiseArgs.
      #
      # This cop is disabled by default.
      #
      # @example
      #   # bad
      #   raise 'something went wrong'
      #
      #   # good
      #   raise CustomError.new('this is exactly what went wrong')
      #
      class RaiseString < Cop
        MSG = 'Use an exception class with `%s` instead of a String.'.freeze
        TARGET_METHODS = [:raise, :fail].to_set.freeze
        STRING_TYPES = [:str, :dstr].to_set.freeze

        def on_send(node)
          _receiver, method_name, *args = *node

          return unless TARGET_METHODS.include?(method_name) &&
                        !args.empty? &&
                        STRING_TYPES.include?(args.first.type)

          add_offense(args.first, :expression, format(MSG, method_name))
        end
      end
    end
  end
end
