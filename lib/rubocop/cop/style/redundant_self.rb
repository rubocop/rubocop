# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for redundant uses of `self`. It is only needed when
      # calling a write accessor on self.
      #
      # Special cases:
      #
      # We allow uses of `self` with operators because it would be awkward
      # otherwise.
      class RedundantSelf < Cop
        MSG = 'Redundant `self` detected.'

        def inspect(source_buffer, source, tokens, ast, comments)
          @allowed_send_nodes = []
          @local_variables = []
          super
        end

        # Assignment of self.x

        def on_or_asgn(node)
          lhs, _rhs = *node
          allow_self(lhs)
          super
        end

        alias_method :on_and_asgn, :on_or_asgn

        def on_op_asgn(node)
          lhs, _op, _rhs = *node
          allow_self(lhs)
          super
        end

        # Using self.x to distinguish from local variable x

        def on_def(node)
          @local_variables = []
          super
        end

        def on_defs(node)
          @local_variables = []
          super
        end

        def on_lvasgn(node)
          lhs, _rhs = *node
          @local_variables << lhs
          super
        end

        # Detect offences

        def on_send(node)
          receiver, method_name, *_args = *node
          if receiver && receiver.type == :self
            unless operator?(method_name) || keyword?(method_name) ||
                @allowed_send_nodes.include?(node) ||
                @local_variables.include?(method_name)
              add_offence(:convention, receiver.loc.expression, MSG)
            end
          end
          super
        end

        private

        def operator?(method_name)
          method_name.to_s =~ /\W/
        end

        def keyword?(method_name)
          [:class, :for].include?(method_name)
        end

        def allow_self(node)
          if node.type == :send
            receiver, _method_name, *_args = *node
            @allowed_send_nodes << node if receiver && receiver.type == :self
          end
        end
      end
    end
  end
end
