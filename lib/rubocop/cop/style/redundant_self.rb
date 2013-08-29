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

        def initialize
          super
          @allowed_send_nodes = []
          @local_variables = []
        end

        # Assignment of self.x

        def on_or_asgn(node)
          lhs, _rhs = *node
          allow_self(lhs)
        end

        alias_method :on_and_asgn, :on_or_asgn

        def on_op_asgn(node)
          lhs, _op, _rhs = *node
          allow_self(lhs)
        end

        # Using self.x to distinguish from local variable x

        def on_def(node)
          @local_variables = []
        end

        def on_defs(node)
          @local_variables = []
        end

        def on_lvasgn(node)
          lhs, _rhs = *node
          @local_variables << lhs
        end

        # Detect offences

        def on_send(node)
          receiver, method_name, *_args = *node
          if receiver && receiver.type == :self
            unless operator?(method_name) || keyword?(method_name) ||
                @allowed_send_nodes.include?(node) ||
                @local_variables.include?(method_name)
              convention(node, :expression, MSG)
            end
          end
        end

        def autocorrect_action(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.expression,
                              node.loc.expression.source.gsub(/self\./, ''))
          end
        end

        private

        def operator?(method_name)
          method_name.to_s =~ /\W/
        end

        def keyword?(method_name)
          [:alias, :and, :begin, :break, :case, :class, :def, :defined, :do,
           :else, :elsif, :end, :ensure, :false, :for, :if, :in, :module,
           :next, :nil, :not, :or, :redo, :rescue, :retry, :return, :self,
           :super, :then, :true, :undef, :unless, :until, :when, :while,
           :yield].include?(method_name)
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
