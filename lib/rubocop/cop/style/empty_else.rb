# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for empty else-clauses, possibly including comments and/or an
      # explicit `nil` depending on the EnforcedStyle.
      #
      # @example EnforcedStyle: empty
      #   # warn only on empty else
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
      #   # good
      #   if condition
      #     statement
      #   else
      #     statement
      #   end
      #
      #   # good
      #   if condition
      #     statement
      #   end
      #
      # @example EnforcedStyle: nil
      #   # warn on else with nil in it
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
      #   # good
      #   if condition
      #     statement
      #   else
      #     statement
      #   end
      #
      #   # good
      #   if condition
      #     statement
      #   end
      #
      # @example EnforcedStyle: both (default)
      #   # warn on empty else and else with nil in it
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
      #
      #   # good
      #   if condition
      #     statement
      #   else
      #     statement
      #   end
      #
      #   # good
      #   if condition
      #     statement
      #   end
      class EmptyElse < Cop
        include OnNormalIfUnless
        include ConfigurableEnforcedStyle

        MSG = 'Redundant `else`-clause.'.freeze

        def on_normal_if_unless(node)
          check(node)
        end

        def on_case(node)
          check(node)
        end

        def autocorrect(node)
          return false if autocorrect_forbidden?(node.type.to_s)
          return false if comment_in_else?(node)

          lambda do |corrector|
            end_pos = base_if_node(node).loc.end.begin_pos
            corrector.remove(range_between(node.loc.else.begin_pos, end_pos))
          end
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

        def empty_check(node)
          return unless node.else? && !node.else_branch

          add_offense(node, location: :else)
        end

        def nil_check(node)
          return unless node.else_branch && node.else_branch.nil_type?

          add_offense(node, location: :else)
        end

        def comment_in_else?(node)
          range = else_line_range(node.loc)
          processed_source.find_comment { |c| range.include?(c.loc.line) }
        end

        def else_line_range(loc)
          return 0..0 if loc.else.nil? || loc.end.nil?
          loc.else.first_line..loc.end.first_line
        end

        def base_if_node(node)
          return node unless node.case_type? || node.elsif?
          node.each_ancestor(:if).find { |parent| parent.loc.end } || node
        end

        def autocorrect_forbidden?(type)
          [type, 'both'].include?(missing_else_style)
        end

        def missing_else_style
          missing_cfg = config.for_cop('Style/MissingElse')
          missing_cfg.fetch('Enabled') ? missing_cfg['EnforcedStyle'] : nil
        end
      end
    end
  end
end
