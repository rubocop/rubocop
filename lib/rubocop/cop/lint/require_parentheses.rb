# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for expressions where there is a call to a predicate
      # method with at least one argument, where no parentheses are used around
      # the parameter list, and a boolean operator, && or ||, is used in the
      # last argument.
      #
      # The idea behind warning for these constructs is that the user might
      # be under the impression that the return value from the method call is
      # an operand of &&/||.
      #
      # @example
      #
      # if day.is? :tuesday && month == :jan
      #   ...
      # end
      class RequireParentheses < Cop
        include IfNode

        MSG = 'Use parentheses in the method call to avoid confusion about ' \
          'precedence.'

        def on_send(node)
          _receiver, method_name, *args = *node

          return if parentheses?(node)
          return if args.empty?

          if ternary_op?(args.first)
            check_ternary(args.first, node)
          else
            # We're only checking predicate methods. There would be false
            # positives otherwise.
            check_send(args.last, node) if predicate?(method_name)
          end
        end

        private

        def check_ternary(arg, node)
          condition, _, _ = *arg
          if offence?(condition)
            expr = node.loc.expression
            range = Parser::Source::Range.new(expr.source_buffer,
                                              expr.begin_pos,
                                              condition.loc.expression.end_pos)
            add_offence(range, range)
          end
        end

        def check_send(arg, node)
          add_offence(node, :expression) if offence?(arg)
        end

        def predicate?(method_name)
          method_name =~ /\w\?$/
        end

        def parentheses?(node)
          node.loc.respond_to?(:end) && !!node.loc.end
        end

        def offence?(node)
          [:and, :or].include?(node.type)
        end
      end
    end
  end
end
