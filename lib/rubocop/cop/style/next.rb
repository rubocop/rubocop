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

        MSG = 'Use `next` to skip iteration.'
        ENUMERATORS = [:collect, :detect, :downto, :each, :find, :find_all,
                       :inject, :loop, :map!, :map, :reduce, :reverse_each,
                       :select, :times, :upto]

        def on_block(node)
          block_owner, _, body = *node
          return unless block_owner.type == :send
          return if body.nil?

          _, method_name = *block_owner
          return unless enumerator?(method_name)
          return unless ends_with_condition?(body)

          add_offense(block_owner, :selector, MSG)
        end

        def on_while(node)
          _, body = *node
          return unless body && ends_with_condition?(body)

          add_offense(node, :keyword, MSG)
        end
        alias_method :on_until, :on_while

        def on_for(node)
          _, _, body = *node
          return unless ends_with_condition?(body)

          add_offense(node, :keyword, MSG)
        end

        private

        def enumerator?(method_name)
          ENUMERATORS.include?(method_name) || /\Aeach_/.match(method_name)
        end

        def ends_with_condition?(body)
          return true if simple_if_without_break?(body)

          body.type == :begin && simple_if_without_break?(body.children.last)
        end

        def simple_if_without_break?(node)
          return false if ternary_op?(node)
          return false if if_else?(node)
          return false unless node.type == :if
          return false if style == :skip_modifier_ifs && modifier_if?(node)

          _conditional, if_body, else_body = *node
          ![:break, :return].include?((if_body || else_body).type)
        end
      end
    end
  end
end
