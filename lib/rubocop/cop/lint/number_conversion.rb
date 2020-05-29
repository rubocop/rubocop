# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop warns the usage of unsafe number conversions. Unsafe
      # number conversion can cause unexpected error if auto type conversion
      # fails. Cop prefer parsing with number class instead.
      #
      # @example
      #
      #   # bad
      #
      #   '10'.to_i
      #   '10.2'.to_f
      #   '10'.to_c
      #   ['1', 2, 3, 4].map(&:to_i)
      #
      #   # good
      #
      #   Integer('10', 10)
      #   Float('10.2')
      #   Complex('10')
      #   ['1', 2, 3, 4].map { |i| Integer(i, 10) }
      class NumberConversion < Cop
        CONVERSION_METHOD_CLASS_MAPPING = {
          to_i: "#{Integer.name}(%<number_object>s, 10)",
          to_f: "#{Float.name}(%<number_object>s)",
          to_c: "#{Complex.name}(%<number_object>s)"
        }.freeze
        MSG = 'Replace unsafe number conversion with number '\
              'class parsing, instead of using '\
              '%<violating_expression>s, use stricter '\
              '%<corrected_expression>s.'

        def_node_matcher :to_method, <<~PATTERN
          (send $_ {:to_i :to_f :to_c})
        PATTERN

        def_node_matcher :to_method_proc?, <<~PATTERN
          (send $_ ${:map :map! :collect :collect!} (block-pass (sym ${:to_i :to_f :to_c})))
        PATTERN

        def_node_matcher :datetime?, <<~PATTERN
          (send (const {nil? (cbase)} {:Time :DateTime}) ...)
        PATTERN

        def on_send(node)
          check_to_method(node)
          check_to_method_proc(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            if to_method_proc?(node)
              corrector.replace(node, corrected_block_expression(*to_method_proc?(node)))
            else
              corrector.replace(node, to_method_corrected(node, node.receiver))
            end
          end
        end

        private

        def check_to_method(node)
          receiver = to_method(node)

          return unless receiver

          return if receiver.nil? || date_time_object?(receiver)

          message = format(
            MSG,
            violating_expression: node.source,
            corrected_expression: to_method_corrected(node, receiver)
          )
          add_offense(node, message: message)
        end

        def check_to_method_proc(node)
          captured_values = to_method_proc?(node)

          return unless captured_values

          msg = format(
            MSG,
            violating_expression: node.source,
            corrected_expression: corrected_block_expression(*captured_values)
          )
          add_offense(node, message: msg)
        end

        def date_time_object?(node)
          child = node
          while child&.send_type?
            return true if datetime? child

            child = child.children[0]
          end
        end

        def corrected_block_expression(receiver, operation, to_method)
          corrected_block = format(
            "{ |%<number_object>s| #{CONVERSION_METHOD_CLASS_MAPPING[to_method]} }",
            number_object: 'i'
          )

          format(
            '%<receiver>s.%<operation>s %<corrected_block>s',
            receiver: receiver.source,
            operation: operation,
            corrected_block: corrected_block
          )
        end

        def to_method_corrected(node, receiver)
          format(CONVERSION_METHOD_CLASS_MAPPING[node.method_name],
                 number_object: receiver.source)
        end
      end
    end
  end
end
