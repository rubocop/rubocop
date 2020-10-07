# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop identifies places where `if-elsif` constructions
      # can be replaced with `case-when`.
      #
      # @example
      #   # bad
      #   if status == :active
      #     perform_action
      #   elsif status == :inactive || status == :hibernating
      #     check_timeout
      #   else
      #     final_action
      #   end
      #
      #   # good
      #   case status
      #   when :active
      #     perform_action
      #   when :inactive, :hibernating
      #     check_timeout
      #   else
      #     final_action
      #   end
      #
      class CaseLikeIf < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Convert `if-elsif` to `case-when`.'

        def on_if(node)
          return unless should_check?(node)

          target = find_target(node.condition)
          return unless target

          conditions = []
          convertible = true

          branch_conditions(node).each do |branch_condition|
            return false if regexp_with_working_captures?(branch_condition)

            conditions << []
            convertible = collect_conditions(branch_condition, target, conditions.last)
            break unless convertible
          end

          return unless convertible

          add_offense(node) { |corrector| autocorrect(corrector, node) }
        end

        private

        def autocorrect(corrector, node)
          target = find_target(node.condition)

          corrector.insert_before(node, "case #{target.source}\n#{indent(node)}")

          branch_conditions(node).each do |branch_condition|
            conditions = []
            collect_conditions(branch_condition, target, conditions)

            range = correction_range(branch_condition)
            branch_replacement = "when #{conditions.map(&:source).join(', ')}"
            corrector.replace(range, branch_replacement)
          end
        end

        def should_check?(node)
          !node.unless? && !node.elsif? && !node.modifier_form? && !node.ternary? &&
            node.elsif_conditional?
        end

        # rubocop:disable Metrics/MethodLength
        def find_target(node)
          case node.type
          when :begin
            find_target(node.children.first)
          when :or
            find_target(node.lhs)
          when :match_with_lvasgn
            lhs, rhs = *node
            if lhs.regexp_type?
              rhs
            elsif rhs.regexp_type?
              lhs
            end
          when :send
            find_target_in_send_node(node)
          end
        end
        # rubocop:enable Metrics/MethodLength

        def find_target_in_send_node(node)
          case node.method_name
          when :is_a?
            node.receiver
          when :==, :eql?, :equal?
            find_target_in_equality_node(node)
          when :===
            node.arguments.first
          when :include?, :cover?
            receiver = deparenthesize(node.receiver)
            node.arguments.first if receiver.range_type?
          when :match, :match?, :=~
            find_target_in_match_node(node)
          end
        end

        def find_target_in_equality_node(node)
          argument = node.arguments.first
          receiver = node.receiver
          return unless argument && receiver

          if argument.literal? || const_reference?(argument)
            receiver
          elsif receiver.literal? || const_reference?(receiver)
            argument
          end
        end

        def find_target_in_match_node(node)
          argument = node.arguments.first
          receiver = node.receiver
          return unless receiver

          if receiver.regexp_type?
            argument
          elsif argument.regexp_type?
            receiver
          end
        end

        def collect_conditions(node, target, conditions)
          condition =
            case node.type
            when :begin
              return collect_conditions(node.children.first, target, conditions)
            when :or
              return collect_conditions(node.lhs, target, conditions) &&
                     collect_conditions(node.rhs, target, conditions)
            when :match_with_lvasgn
              lhs, rhs = *node
              condition_from_binary_op(lhs, rhs, target)
            when :send
              condition_from_send_node(node, target)
            end

          conditions << condition if condition
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        def condition_from_send_node(node, target)
          case node.method_name
          when :is_a?
            node.arguments.first if node.receiver == target
          when :==, :eql?, :equal?
            condition_from_equality_node(node, target)
          when :=~, :match, :match?
            condition_from_match_node(node, target)
          when :===
            lhs, _method, rhs = *node
            lhs if rhs == target
          when :include?, :cover?
            receiver = deparenthesize(node.receiver)
            receiver if receiver.range_type? && node.arguments.first == target
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        def condition_from_equality_node(node, target)
          lhs, _method, rhs = *node
          condition = condition_from_binary_op(lhs, rhs, target)
          condition if condition && !class_reference?(condition)
        end

        def condition_from_match_node(node, target)
          lhs, _method, rhs = *node
          condition_from_binary_op(lhs, rhs, target)
        end

        def condition_from_binary_op(lhs, rhs, target)
          lhs = deparenthesize(lhs)
          rhs = deparenthesize(rhs)

          if lhs == target
            rhs
          elsif rhs == target
            lhs
          end
        end

        def branch_conditions(node)
          conditions = []
          while node&.if_type?
            conditions << node.condition
            node = node.else_branch
          end
          conditions
        end

        def const_reference?(node)
          return false unless node.const_type?

          name = node.children[1].to_s

          # We can no be sure if, e.g. `C`, represents a constant or a class reference
          name.length > 1 &&
            name == name.upcase
        end

        def class_reference?(node)
          node.const_type? && node.children[1].match?(/[[:lower:]]/)
        end

        def deparenthesize(node)
          node = node.children.last while node.begin_type?
          node
        end

        def correction_range(node)
          range_between(node.parent.loc.keyword.begin_pos, node.loc.expression.end_pos)
        end

        def indent(node)
          ' ' * node.loc.column
        end

        # Named captures work with `=~` (if regexp is on lhs) and with `match` (both sides)
        def regexp_with_working_captures?(node)
          case node.type
          when :match_with_lvasgn
            lhs, _rhs = *node
            node.loc.selector.source == '=~' && regexp_with_named_captures?(lhs)
          when :send
            lhs, method, rhs = *node
            method == :match && [lhs, rhs].any? { |n| regexp_with_named_captures?(n) }
          end
        end

        def regexp_with_named_captures?(node)
          node.regexp_type? && node.each_capture(named: true).count.positive?
        end
      end
    end
  end
end
