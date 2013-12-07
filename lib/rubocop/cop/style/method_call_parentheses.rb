# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for unwanted parentheses in parameterless method calls.
      class MethodCallParentheses < Cop
        MSG = 'Do not use parentheses for method calls with no arguments.'

        def on_send(node)
          _receiver, method_name, *args = *node

          # methods starting with a capital letter should be skipped
          return if method_name =~ /\A[A-Z]/

          add_offence(node, :begin) if args.empty? && node.loc.begin
        end

        def autocorrect(node)
          # Bail out if the call is going to be auto-corrected by EmptyLiteral.
          if config.for_cop('EmptyLiteral')['Enabled'] &&
              [EmptyLiteral::HASH_NODE,
               EmptyLiteral::ARRAY_NODE,
               EmptyLiteral::STR_NODE].include?(node)
            fail CorrectionNotPossible
          end
          @corrections << lambda do |corrector|
            corrector.remove(node.loc.begin)
            corrector.remove(node.loc.end)
          end
        end
      end
    end
  end
end
