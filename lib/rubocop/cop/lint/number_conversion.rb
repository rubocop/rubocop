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
      #
      #   # good
      #
      #   Integer('10', 10)
      #   Float('10.2')
      #   Complex('10')
      class NumberConversion < Cop
        CONVERSION_METHOD_CLASS_MAPPING = {
          to_i: "#{Integer.name}(%<number_object>s, 10)",
          to_f: "#{Float.name}(%<number_object>s)",
          to_c: "#{Complex.name}(%<number_object>s)"
        }.freeze
        MSG = 'Replace unsafe number conversion with number '\
              'class parsing, instead of using '\
              '%<number_object>s.%<to_method>s, use stricter '\
              '%<corrected_method>s.'

        def_node_matcher :to_method, <<-PATTERN
          (send $_ ${:to_i :to_f :to_c})
        PATTERN

        def_node_matcher :datetime?, <<-PATTERN
          (send (const {nil? (cbase)} {:Time :DateTime}) ...)
        PATTERN

        def on_send(node)
          to_method(node) do |receiver, to_method|
            next if date_time_object?(receiver)

            message = format(
              MSG,
              number_object: receiver.source,
              to_method: to_method,
              corrected_method: correct_method(node, receiver)
            )
            add_offense(node, message: message)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression,
                              correct_method(node, node.receiver))
          end
        end

        private

        def date_time_object?(node)
          child = node
          while child&.send_type?
            return true if datetime? child

            child = child.children[0]
          end
        end

        def correct_method(node, receiver)
          format(CONVERSION_METHOD_CLASS_MAPPING[node.method_name],
                 number_object: receiver.source)
        end
      end
    end
  end
end
