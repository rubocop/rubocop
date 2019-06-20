# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for potential usage of the `||=` operator.
      #
      # @example
      #   # bad
      #   name = name ? name : 'Bozhidar'
      #
      #   # bad
      #   name = if name
      #            name
      #          else
      #            'Bozhidar'
      #          end
      #
      #   # bad
      #   unless name
      #     name = 'Bozhidar'
      #   end
      #
      #   # bad
      #   name = 'Bozhidar' unless name
      #
      #   # good - set name to 'Bozhidar', only if it's nil or false
      #   name ||= 'Bozhidar'
      class OrAssignment < Cop
        MSG = 'Use the double pipe equals operator `||=` instead.'

        def_node_matcher :ternary_assignment?, <<~PATTERN
          ({lvasgn ivasgn cvasgn gvasgn} _var
            (if
              ({lvar ivar cvar gvar} _var)
              ({lvar ivar cvar gvar} _var)
              _))
        PATTERN

        def_node_matcher :unless_assignment?, <<~PATTERN
          (if
            ({lvar ivar cvar gvar} _var) nil?
            ({lvasgn ivasgn cvasgn gvasgn} _var
              _))
        PATTERN

        def on_if(node)
          return unless unless_assignment?(node)

          add_offense(node)
        end

        def on_lvasgn(node)
          return unless ternary_assignment?(node)

          add_offense(node)
        end

        alias on_ivasgn on_lvasgn
        alias on_cvasgn on_lvasgn
        alias on_gvasgn on_lvasgn

        def autocorrect(node)
          if ternary_assignment?(node)
            variable, default = take_variable_and_default_from_ternary(node)
          else
            variable, default = take_variable_and_default_from_unless(node)
          end

          lambda do |corrector|
            corrector.replace(node.source_range,
                              "#{variable} ||= #{default.source}")
          end
        end

        private

        def take_variable_and_default_from_ternary(node)
          variable, if_statement = *node
          [variable, if_statement.else_branch]
        end

        def take_variable_and_default_from_unless(node)
          variable, default = *node.if_branch
          [variable, default]
        end
      end
    end
  end
end
