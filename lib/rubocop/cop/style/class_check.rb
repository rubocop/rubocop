# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces consistent use of `Object#is_a?` or `Object#kind_of?`.
      class ClassCheck < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Prefer `Object#%s` over `Object#%s`.'.freeze

        def_node_matcher :class_check?, '(send _ ${:is_a? :kind_of?} _)'

        def on_send(node)
          class_check?(node) do |method_name|
            return if style == method_name
            add_offense(node, :selector)
          end
        end

        def message(node)
          _receiver, method_name, *_args = *node

          if method_name == :is_a?
            format(MSG, 'kind_of?', 'is_a?')
          else
            format(MSG, 'is_a?', 'kind_of?')
          end
        end

        def autocorrect(node)
          _receiver, method_name, *_args = *node

          lambda do |corrector|
            corrector.replace(node.loc.selector,
                              method_name == :is_a? ? 'kind_of?' : 'is_a?')
          end
        end
      end
    end
  end
end
