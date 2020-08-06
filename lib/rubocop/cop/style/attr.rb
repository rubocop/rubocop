# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of Module#attr.
      #
      # @example
      #   # bad - creates a single attribute accessor (deprecated in Ruby 1.9)
      #   attr :something, true
      #   attr :one, :two, :three # behaves as attr_reader
      #
      #   # good
      #   attr_accessor :something
      #   attr_reader :one, :two, :three
      #
      class Attr < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Do not use `attr`. Use `%<replacement>s` instead.'

        def on_send(node)
          return unless node.command?(:attr) && node.arguments?
          # check only for method definitions in class/module body
          return if node.parent &&
                    !node.parent.class_type? &&
                    !class_eval?(node.parent)

          message = message(node)
          add_offense(node.loc.selector, message: message) do |corrector|
            autocorrect(corrector, node)
          end
        end

        private

        def autocorrect(corrector, node)
          attr_name, setter = *node.arguments

          node_expr = node.source_range
          attr_expr = attr_name.source_range

          remove = range_between(attr_expr.end_pos, node_expr.end_pos) if setter&.boolean_type?

          corrector.replace(node.loc.selector, replacement_method(node))
          corrector.remove(remove) if remove
        end

        def message(node)
          format(MSG, replacement: replacement_method(node))
        end

        def replacement_method(node)
          setter = node.last_argument

          if setter&.boolean_type?
            setter.true_type? ? 'attr_accessor' : 'attr_reader'
          else
            'attr_reader'
          end
        end

        def_node_matcher :class_eval?, <<~PATTERN
          (block (send _ {:class_eval :module_eval}) ...)
        PATTERN
      end
    end
  end
end
