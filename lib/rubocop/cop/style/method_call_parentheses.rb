# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for unwanted parentheses in parameterless method calls.
      class MethodCallParentheses < Cop
        MSG = 'Do not use parentheses for method calls with no arguments.'

        ASGN_NODES = [:lvasgn, :masgn] + Util::SHORTHAND_ASGN_NODES

        def on_send(node)
          _receiver, method_name, *args = *node

          # methods starting with a capital letter should be skipped
          return if method_name =~ /\A[A-Z]/
          return unless args.empty? && node.loc.begin
          return if same_name_assignment?(node)
          return if lambda_call_syntax?(node)

          add_offense(node, :begin)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(node.loc.begin)
            corrector.remove(node.loc.end)
          end
        end

        private

        def same_name_assignment?(node)
          _receiver, method_name, *_args = *node

          node.each_ancestor(ASGN_NODES).any? do |asgn_node|
            if asgn_node.masgn_type?
              mlhs_node, _mrhs_node = *asgn_node
              asgn_node = mlhs_node.children[node.sibling_index]
            end
            # `obj.method = value` parses as (send ... :method= ...), and will
            # not be returned as an `asgn_node` here
            # however, `obj.method ||= value` parses as (or-asgn (send ...) ...)
            # which IS an `asgn_node`
            if asgn_node.or_asgn_type? || asgn_node.and_asgn_type?
              asgn_node, _value = *asgn_node
              return false if asgn_node.send_type?
            end

            asgn_node.loc.name.source == method_name.to_s
          end
        end

        # don't check `lambda.()` syntax; the Style/LambdaCall cop does that
        def lambda_call_syntax?(node)
          node.method_name == :call && node.loc.selector.nil?
        end
      end
    end
  end
end
