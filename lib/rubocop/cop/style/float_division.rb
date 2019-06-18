# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for division with integers coerced to floats.
      # It is recommended to either always use `fdiv` or coerce one side only.
      # This cop also provides other options for code consistency.
      #
      # @example EnforcedStyle: single_coerce (default)
      #   # bad
      #   a.to_f / b.to_f
      #
      #   # good
      #   a.to_f / b
      #   a / b.to_f
      #
      # @example EnforcedStyle: left_coerce
      #   # bad
      #   a / b.to_f
      #   a.to_f / b.to_f
      #
      #   # good
      #   a.to_f / b
      #
      # @example EnforcedStyle: right_coerce
      #   # bad
      #   a.to_f / b
      #   a.to_f / b.to_f
      #
      #   # good
      #   a / b.to_f
      #
      # @example EnforcedStyle: fdiv
      #   # bad
      #   a / b.to_f
      #   a.to_f / b
      #   a.to_f / b.to_f
      #
      #   # good
      #   a.fdiv(b)
      class FloatDivision < Cop
        include ConfigurableEnforcedStyle

        def_node_matcher :right_coerce?, <<-PATTERN
          (send _ :/ (send _ :to_f))
        PATTERN
        def_node_matcher :left_coerce?, <<-PATTERN
          (send (send _ :to_f) :/ _)
        PATTERN
        def_node_matcher :both_coerce?, <<-PATTERN
          (send (send _ :to_f) :/ (send _ :to_f))
        PATTERN
        def_node_matcher :any_coerce?, <<-PATTERN
          {(send _ :/ (send _ :to_f)) (send (send _ :to_f) :/ _)}
        PATTERN

        def on_send(node)
          add_offense(node) if offense_condition?(node)
        end

        private

        def offense_condition?(node)
          case style
          when :left_coerce
            right_coerce?(node)
          when :right_coerce
            left_coerce?(node)
          when :single_coerce
            both_coerce?(node)
          when :fdiv
            any_coerce?(node)
          else
            false
          end
        end

        def message(_node)
          case style
          when :left_coerce
            'Prefer using `.to_f` on the left side.'
          when :right_coerce
            'Prefer using `.to_f` on the right side.'
          when :single_coerce
            'Prefer using `.to_f` on one side only.'
          when :fdiv
            'Prefer using `fdiv` for float divisions.'
          end
        end
      end
    end
  end
end
