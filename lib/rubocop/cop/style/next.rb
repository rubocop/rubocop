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
        METHODS = [:collect, :detect, :downto, :each, :find, :find_all,
                   :inject, :loop, :map!, :map, :reduce, :reverse_each,
                   :select, :times, :upto]

        def on_block(node)
          method, _, body = *node
          return unless method.type == :send
          return if body.nil?

          _, method_name = *method
          return unless method?(method_name)
          return unless ends_with_condition?(body)

          add_offense(method, :selector, MSG)
        end

        def on_while(node)
          _, body = *node
          return unless ends_with_condition?(body)

          add_offense(node, :keyword, MSG)
        end
        alias_method :on_until, :on_while

        def on_for(node)
          _, _, body = *node
          return unless ends_with_condition?(body)

          add_offense(node, :keyword, MSG)
        end

        private

        def method?(method_name)
          METHODS.include?(method_name) || /\Aeach_/.match(method_name)
        end

        def ends_with_condition?(body)
          return true if simple_if_without_break?(body)

          body.type == :begin && simple_if_without_break?(body.children.last)
        end

        def simple_if_without_break?(body)
          return false if ternary_op?(body)
          return false if if_else?(body)
          return false unless body.type == :if
          return false if style == :skip_modifier_ifs && modifier_if?(body)

          _, return_method, return_body  = *body
          (return_method || return_body).type != :break
        end
      end
    end
  end
end
