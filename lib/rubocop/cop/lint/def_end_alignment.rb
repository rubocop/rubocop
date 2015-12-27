# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks whether the end keywords of method definitions are
      # aligned properly.
      #
      # Two modes are supported through the AlignWith configuration
      # parameter. If it's set to `start_of_line` (which is the default), the
      # `end` shall be aligned with the start of the line where the `def`
      # keyword is. If it's set to `def`, the `end` shall be aligned with the
      # `def` keyword.
      #
      # @example
      #
      #   private def foo
      #   end
      class DefEndAlignment < Cop
        include OnMethodDef
        include EndKeywordAlignment

        MSG = '`end` at %d, %d is not aligned with `%s` at %d, %d.'

        def on_method_def(node, _method_name, _args, _body)
          check_offset_of_node(node)
        end

        def on_send(node)
          return unless modifier_and_def_on_same_line?(node)
          _, _, method_def = *node

          if style == :start_of_line
            expr = node.loc.expression
            range = Parser::Source::Range.new(expr.source_buffer,
                                              expr.begin_pos,
                                              method_def.loc.keyword.end_pos)
            check_offset(method_def, range.source,
                         method_def.loc.keyword.begin_pos - expr.begin_pos)
          else
            check_offset(method_def, 'def', 0)
          end

          ignore_node(method_def) # Don't check the same `end` again.
        end

        private

        def autocorrect(node)
          if style == :start_of_line && node.parent && node.parent.send_type?
            align(node, node.parent)
          else
            align(node, node)
          end
        end
      end
    end
  end
end
