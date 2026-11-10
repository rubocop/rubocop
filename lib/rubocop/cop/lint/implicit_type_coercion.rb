# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for operations that mathematically do nothing, but nevertheless
      # implicitly change the type of the receiver. These should be replaced
      # with explicit type conversions.
      #
      # @safety
      #   This cop is unsafe if the receiver is a complex number, as only the
      #   real part of the number has its type coerced.
      #
      # @example
      #
      #   # bad
      #   x + 0.0
      #   x - 0.0
      #   x * 1.0
      #   x / 1.0
      #   x ** 1.0
      #
      #   # good
      #   x.to_f
      #
      #   # bad
      #   x + 0r
      #   x - 0r
      #   x * 1r
      #   x / 1r
      #   x ** 1r
      #
      #   # good
      #   x.to_r
      #
      #   # bad
      #   x + 0i
      #   x - 0i
      #
      #   # good
      #   x.to_c
      #
      class ImplicitTypeCoercion < Base
        extend AutoCorrector

        RESTRICT_ON_SEND = %i[+ - * / **].freeze
        TYPE_MAPPINGS = { 0.0 => '.to_f', 0r => '.to_r', 0i => '.to_c',
                          1.0 => '.to_f', 1r => '.to_r' }.freeze

        # @!method implicit_type_coercion?(node)
        def_node_matcher :implicit_type_coercion?,
                         '(call (call nil? $_) $_ { (float $_) | (rational $_) | (complex $_) })'

        def on_send(node)
          return unless implicit_type_coercion?(node)

          variable, operation, number = implicit_type_coercion?(node)

          type = type_coercion?(operation, number)
          return unless type

          add_offense(node,
                      message: 'This operation is mathematically inconsequential, ' \
                               'but it implicitly changes the type of the receiver. ' \
                               "Use #{type} instead.") do |corrector|
            corrector.replace(node, variable.to_s + type)
          end
        end
        alias on_csend on_send

        private

        def type_coercion?(operation, number)
          if number.zero?
            TYPE_MAPPINGS[number] if %i[+ -].include?(operation)
          elsif number == 1
            TYPE_MAPPINGS[number] if %i[* / **].include?(operation)
          end
        end
      end
    end
  end
end
