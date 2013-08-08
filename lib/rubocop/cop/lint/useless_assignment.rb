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
          _name, _args, body = *node

          check_for_useless_assignment(body)
        end

        def on_defs(node)
          _target, _name, _args, body = *node

          check_for_useless_assignment(body)
        end

        private

        def check_for_useless_assignment(body)
          return unless body

          if body.type == :begin
            expression = body.children
          else
            expression = body
          end

          last_expr = expression.is_a?(Array) ? expression.last : expression

          if last_expr && last_expr.type == :lvasgn
            var_name, = *last_expr
            add_offence(:warning, last_expr.loc.name, MSG.format(var_name))
          elsif last_expr && last_expr.type == :send
            receiver, method, _args = *last_expr

            if receiver && receiver.type == :lvar && method =~ /\w=$/
              add_offence(:warning,
                          receiver.loc.name,
                          MSG.format(receiver.loc.name.source))
            end
          end
        end
      end
    end
  end
end
