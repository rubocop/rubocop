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
          receiver, method_name, args = *node
          if OPERATOR_METHODS.include?(method_name) ||
              method_name.to_s.end_with?('=')
            return
          end
          if args && args.loc.expression.source.start_with?('(')
            receiver_length = if receiver
                                receiver.loc.expression.source.length
                              else
                                0
                              end
            without_receiver = node.loc.expression.source[receiver_length..-1]

            # Escape question mark if any.
            method_regexp = Regexp.escape(method_name)

            if (match =
                without_receiver.match(/^\s*\.?\s*#{method_regexp}(\s+)\(/))
              expr = args.loc.expression
              space_length = match.captures[0].length
              space_range =
                Parser::Source::Range.new(expr.source_buffer,
                                          expr.begin_pos - space_length,
                                          expr.begin_pos)
              warning(nil, space_range)
            end
          end
        end
      end
    end
  end
end
