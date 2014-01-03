# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # Checks for space between a the name of a called method and a left
      # parenthesis.
      #
      # @example
      #
      # puts (x + y)
      class ParenthesesAsGroupedExpression < Cop
        MSG = '(...) interpreted as grouped expression.'

        def on_send(node)
          _receiver, method_name, args = *node
          if OPERATOR_METHODS.include?(method_name) ||
              method_name.to_s.end_with?('=')
            return
          end
          if args && args.loc.expression.source.start_with?('(')
            space_length = spaces_before_left_parenthesis(node)
            if space_length > 0
              expr = args.loc.expression
              space_range = new_range(expr.begin_pos - space_length,
                                      expr.begin_pos)
              add_offence(nil, space_range)
            end
          end
        end

        private

        def spaces_before_left_parenthesis(node)
          receiver, method_name, _args = *node
          receiver_length = if receiver
                              receiver.loc.expression.source.length
                            else
                              0
                            end
          without_receiver = node.loc.expression.source[receiver_length..-1]

          # Escape question mark if any.
          method_regexp = Regexp.escape(method_name)

          match = without_receiver.match(/^\s*\.?\s*#{method_regexp}(\s+)\(/)
          match ? match.captures[0].length : 0
        end
      end
    end
  end
end
