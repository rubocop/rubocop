# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for useless assignment as the final expression
      # of a function definition.
      #
      # @example
      #
      #  def something
      #    x = 5
      #  end
      #
      #  def something
      #    x = Something.new
      #    x.attr = 5
      #  end
      class UselessAssignment < Cop
        MSG = 'Useless assignment to local variable %s.'

        def on_def(node)
          _name, args, body = *node

          check_for_useless_assignment(body, args)
        end

        def on_defs(node)
          _target, _name, args, body = *node

          check_for_useless_assignment(body, args)
        end

        private

        def check_for_useless_assignment(body, args)
          return unless body

          if body.type == :begin
            expression = body.children
          else
            expression = body
          end

          last_expr = expression.is_a?(Array) ? expression.last : expression
          return unless last_expr

          case last_expr.type
          when :lvasgn
            var_name, = *last_expr
            warning(last_expr, :name, MSG.format(var_name))
          when :send
            receiver, method, _args = *last_expr
            return unless receiver
            return unless receiver.type == :lvar
            return unless method =~ /\w=$/

            var_name, = *receiver
            return if contains_object_passed_as_argument?(var_name, body, args)

            warning(receiver,
                    :name,
                    MSG.format(receiver.loc.name.source))
          end
        end

        def contains_object_passed_as_argument?(lvar_name, body, args)
          variable_table = {}

          args.children.each do |arg_node|
            arg_name, = *arg_node
            variable_table[arg_name] = true
          end

          on_node([:lvasgn, :ivasgn, :cvasgn, :gvasgn], body) do |asgn_node|
            lhs_var_name, rhs_node = *asgn_node

            if [:lvar, :ivar, :cvar, :gvar].include?(rhs_node.type)
              rhs_var_name, = *rhs_node
              variable_table[lhs_var_name] = variable_table[rhs_var_name]
            else
              variable_table[lhs_var_name] = false
            end
          end

          variable_table[lvar_name]
        end
      end
    end
  end
end
