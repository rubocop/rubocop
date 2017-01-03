# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for empty else-clauses, possibly including comments and/or an
      # explicit `nil` depending on the EnforcedStyle.
      #
      # SupportedStyles:
      #
      # @example
      #   # good for all styles
      #
      #   if condition
      #     statement
      #   else
      #     statement
      #   end
      #
      #   # good for all styles
      #   if condition
      #     statement
      #   end
      #
      # @example
      #   # empty - warn only on empty else
      #
      #   # bad
      #   if condition
      #     statement
      #   else
      #   end
      #
      #   # good
      #   if condition
      #     statement
      #   else
      #     nil
      #   end
      #
      # @example
      #   # nil - warn on else with nil in it
      #
      #   # bad
      #   if condition
      #     statement
      #   else
      #     nil
      #   end
      #
      #   # good
      #   if condition
      #     statement
      #   else
      #   end
      #
      # @example
      #   # both - warn on empty else and else with nil in it
      #
      #   # bad
      #   if condition
      #     statement
      #   else
      #     nil
      #   end
      #
      #   # bad
      #   if condition
      #     statement
      #   else
      #   end
      class EmptyElse < Cop
        include OnNormalIfUnless
        include ConfigurableEnforcedStyle

        MSG = 'Redundant `else`-clause.'.freeze

        def on_normal_if_unless(node)
          check(node, if_else_clause(node))
        end

        def on_case(node)
          check(node, case_else_clause(node))
        end

        private
        
        def check(node)
          empty_check(node) if empty_style?
          nil_check(node) if nil_style?
        end

        def nil_style?
          style == :nil || style == :both
        end

        def empty_style?
          style == :empty || style == :both
        end

        def empty_check(node, else_clause)
          add_offense(node, :else, MSG) if node.loc.else && else_clause.nil?
        end

        def nil_check(node, else_clause)
          return unless else_clause && else_clause.nil_type?
          add_offense(node, :else, MSG)
        end

        def both_check(node, else_clause)
          empty_check(node, else_clause)
          nil_check(node, else_clause)
        end

        def autocorrect(node)
          return false if autocorrect_forbidden?(node.type.to_s)

          lambda do |corrector|
            end_pos = base_if_node(node).loc.end.begin_pos

            corrector.remove(range_between(node.loc.else.begin_pos, end_pos))
          end
        end

        def base_if_node(node)
          parent_node = node
          parent_node = parent_node.parent until parent_node.loc.end
          parent_node
        end

        def autocorrect_forbidden?(type)
          [type, 'both'].include? missing_else_style
        end

        def missing_else_style
          missing_config = config.for_cop('Style/MissingElse')
          missing_config['Enabled'] ? missing_config['EnforcedStyle'] : nil
        end
      end
    end
  end
end
