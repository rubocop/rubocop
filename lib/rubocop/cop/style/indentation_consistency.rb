# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cops checks for inconsistent indentation.
      #
      # @example
      #
      # class A
      #   def test
      #     puts 'hello'
      #      puts 'world'
      #   end
      # end
      class IndentationConsistency < Cop
        MSG = 'Inconsistent indentation detected.'

        def on_begin(node)
          check(node)
        end

        def on_kwbegin(node)
          check(node)
        end

        private

        def check(node)
          children_to_check = node.children.reject do |child|
            # Don't check nodes that have special indentation and will be
            # checked by the AccessModifierIndentation cop.
            AccessModifierIndentation.modifier_node?(child)
          end

          children_to_check.map(&:loc).each_cons(2) do |child1, child2|
            if child2.line > child1.line && child2.column != child1.column
              expr = child2.expression
              indentation = expr.source_line =~ /\S/
              end_pos = expr.begin_pos
              begin_pos = end_pos - indentation
              add_offence(nil,
                          Parser::Source::Range.new(expr.source_buffer,
                                                    begin_pos, end_pos))
            end
          end
        end
      end
    end
  end
end
