# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for literals used as operands in and/or
      # expressions in the conditions of if/while/until.
      class LiteralInCondition < Cop
        MSG = 'Literal %s appeared in a condition.'

        LITERALS = [:str, :dstr, :int, :float, :array,
                    :hash, :regexp, :nil, :true, :false]

        def on_if(node)
          check_for_literal(node)

          super
        end

        def on_while(node)
          check_for_literal(node)

          super
        end

        def on_while_post(node)
          check_for_literal(node)

          super
        end

        def on_until(node)
          check_for_literal(node)

          super
        end

        def on_until_post(node)
          check_for_literal(node)

          super
        end

        private

        def check_for_literal(node)
          cond, = *node

          on_node([:and, :or], cond) do |logic_node|
            *operands = *logic_node
            operands.each do |op|
              if LITERALS.include?(op.type)
                add_offence(:warning, op.loc.expression,
                            format(MSG, op.loc.expression.source))

              end
            end
          end
        end
      end
    end
  end
end
