# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for literals used as the conditions or as
      # operands in and/or expressions serving as the conditions of
      # if/while/until.
      #
      # @example
      #
      #   if 20
      #     do_something
      #   end
      #
      #   if some_var && true
      #     do_something
      #   end
      #
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

          # if the code node is literal we obviously have a problem
          if LITERALS.include?(cond.type)
            add_offence(:warning, cond.loc.expression,
                        format(MSG, cond.loc.expression.source))
          elsif cond.type == :send
            receiver, method_name, *_args = *cond

            if method_name == :! && LITERALS.include?(receiver.type)
              add_offence(:warning, receiver.loc.expression,
                          format(MSG, receiver.loc.expression.source))
            end
          elsif [:and, :or].include?(cond.type)
            # alternatively we have to consider a logical node with a
            # literal argument
            *operands = *cond
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
