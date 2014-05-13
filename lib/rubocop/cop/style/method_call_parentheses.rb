# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for unwanted parentheses in parameterless method calls.
      class MethodCallParentheses < Cop
        MSG_NO_ARGUMENTS = 'Do not use parentheses for method calls with no '\
                           'arguments.'
        MSG_OMIT_PARENTHESES = 'Omit parentheses for DSL method calls.'

        def on_send(node)
          _receiver, method_name, *args = *node

          # methods with an operator (like = * <<) should be skipped
          return unless  /\A[a-z_]*\z/.match(method_name)

          # methods starting with a capital letter should be skipped
          return if method_name =~ /\A[A-Z]/

          if args.empty?
            add_offense(node, :begin, MSG_NO_ARGUMENTS) if parentheses?(node)
            return
          end

          return unless parentheses?(node)
          return if method_call_chain?(node)
          return unless require_no_parentheses?(node)

          add_offense(node, :expression, MSG_OMIT_PARENTHESES)
        end

        def autocorrect(node)
          # Bail out if the call is going to be auto-corrected by EmptyLiteral.
          if config.for_cop('EmptyLiteral')['Enabled'] &&
              [EmptyLiteral::HASH_NODE,
               EmptyLiteral::ARRAY_NODE,
               EmptyLiteral::STR_NODE].include?(node)
            return
          end
          @corrections << lambda do |corrector|
            if require_no_parentheses?(node)
              corrector.replace(node.loc.begin, ' ')
            else
              corrector.remove(node.loc.begin)
            end
            corrector.remove(node.loc.end)
          end
        end

        private

        # finds method call chains like `should include('foo')`
        def method_call_chain?(node)
          _receiver, method_name, _args = *node
          !processed_source[node.loc.line - 1]
            .strip
            .start_with?("#{method_name}(")
        end

        def parentheses?(node)
          !node.loc.begin.nil?
        end

        def require_no_parentheses?(node)
          _receiver, method_name, _args = *node
          cop_config['RequireNoParentheses'].include?(method_name.to_s)
        end
      end
    end
  end
end
