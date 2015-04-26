# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks that operators have space around them, except for **
      # which should not have surrounding space.
      class SpaceAroundOperators < Cop
        TYPES = %w(and or class) + ASGN_NODES

        TYPES.each { |t| define_method(:"on_#{t}") { |node| check(node) } }

        def on_pair(node)
          check(node) if node.loc.operator.is?('=>')
        end

        def on_if(node)
          return unless node.loc.respond_to?(:question)

          check_operator(node.loc.question)
          check_operator(node.loc.colon)
        end

        def on_resbody(node)
          check_operator(node.loc.assoc) if node.loc.assoc
        end

        def on_send(node)
          if node.loc.operator
            check(node)
          elsif !unary_operation?(node) && !called_with_dot?(node)
            op = node.loc.selector
            check_operator(op) if operator?(op)
          end
        end

        private

        def operator?(range)
          range.source !~ /^\[|\w/
        end

        def unary_operation?(node)
          whole = node.loc.expression
          selector = node.loc.selector
          return unless selector
          operator?(selector) && whole.begin_pos == selector.begin_pos
        end

        def called_with_dot?(node)
          node.loc.dot
        end

        def check(node)
          check_operator(node.loc.operator) if node.loc.operator
        end

        def check_operator(op)
          with_space = range_with_surrounding_space(op)
          if op.is?('**')
            unless with_space.is?('**')
              add_offense(with_space, op,
                          'Space around operator `**` detected.')
            end
          elsif with_space.source !~ /^\s.*\s$/
            add_offense(with_space, op,
                        'Surrounding space missing for operator' \
                        " `#{op.source}`.")
          elsif with_space.source =~ /(^  |  $)/ && !multi_space_operator?(op)
            add_offense(with_space, op,
                        "Operator `#{op.source}` should be surrounded" \
                        ' with a single space.')
          end
        end

        def multi_space_operator?(op)
          cop_config['MultiSpaceAllowedForOperators'].any? do |multi_space_op|
            op.is?(multi_space_op)
          end
        end

        def autocorrect(range)
          lambda do |corrector|
            case range.source
            when /\*\*/
              corrector.replace(range, '**')
            else
              corrector.replace(range, " #{range.source.strip} ")
            end
          end
        end
      end
    end
  end
end
