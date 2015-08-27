# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Use `next` to skip iteration instead of a condition at the end.
      #
      # @example
      #   # bad
      #   [1, 2].each do |a|
      #     if a == 1 do
      #       puts a
      #     end
      #   end
      #
      #   # good
      #   [1, 2].each do |a|
      #     next unless a == 1
      #     puts a
      #   end
      class Next < Cop
        include IfNode
        include ConfigurableEnforcedStyle
        include MinBodyLength

        MSG = 'Use `next` to skip iteration.'.freeze
        EXIT_TYPES = [:break, :return].freeze
        EACH_ = 'each_'.freeze
        ENUMERATORS = [:collect, :collect_concat, :detect, :downto, :each,
                       :find, :find_all, :find_index, :inject, :loop, :map!,
                       :map, :reduce, :reject, :reject!, :reverse_each, :select,
                       :select!, :times, :upto].freeze

        def on_block(node)
          block_owner, _, body = *node
          return unless block_owner.send_type?
          return unless body && ends_with_condition?(body)

          _, method_name = *block_owner
          return unless enumerator?(method_name)

          offense_node = offense_node(body)
          add_offense(offense_node, offense_location(offense_node), MSG)
        end

        def on_while(node)
          _, body = *node
          return unless body && ends_with_condition?(body)

          offense_node = offense_node(body)
          add_offense(offense_node, offense_location(offense_node), MSG)
        end
        alias_method :on_until, :on_while

        def on_for(node)
          _, _, body = *node
          return unless body && ends_with_condition?(body)

          offense_node = offense_node(body)
          add_offense(offense_node, offense_location(offense_node), MSG)
        end

        private

        def enumerator?(method_name)
          ENUMERATORS.include?(method_name) ||
            method_name.to_s.start_with?(EACH_)
        end

        def ends_with_condition?(body)
          return true if simple_if_without_break?(body)

          body.begin_type? && simple_if_without_break?(body.children.last)
        end

        def simple_if_without_break?(node)
          return false unless node.if_type?
          return false if ternary_op?(node)
          return false if if_else?(node)
          return false if style == :skip_modifier_ifs && modifier_if?(node)
          return false if !modifier_if?(node) && !min_body_length?(node)

          # The `if` node must have only `if` body since we excluded `if` with
          # `else` above.
          _conditional, if_body, _else_body = *node
          return true unless if_body

          !EXIT_TYPES.include?(if_body.type)
        end

        def offense_node(body)
          *_, condition = *body
          (condition && condition.if_type?) ? condition : body
        end

        def offense_location(offense_node)
          condition_expression, = *offense_node
          offense_begin_pos = offense_node.loc.expression.begin
          offense_begin_pos.join(condition_expression.loc.expression)
        end
      end
    end
  end
end
