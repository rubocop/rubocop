# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for comparison of something with nil using `==` and
      # `nil?`.
      #
      # Supported styles are: predicate, comparison.
      #
      # @example EnforcedStyle: predicate (default)
      #
      #   # bad
      #   if x == nil
      #   end
      #
      #   # good
      #   if x.nil?
      #   end
      #
      # @example EnforcedStyle: comparison
      #
      #   # bad
      #   if x.nil?
      #   end
      #
      #   # good
      #   if x == nil
      #   end
      #
      class NilComparison < Cop
        include ConfigurableEnforcedStyle

        PREDICATE_MSG = 'Prefer the use of the `nil?` predicate.'.freeze
        EXPLICIT_MSG = 'Prefer the use of the `==` comparison.'.freeze

        def_node_matcher :nil_comparison?, '(send _ {:== :===} nil)'
        def_node_matcher :nil_check?, '(send _ :nil?)'

        def on_send(node)
          style_check?(node) do
            add_offense(node, location: :selector)
          end
        end

        def autocorrect(node)
          new_code = if prefer_comparison?
                       node.source.sub('.nil?', ' == nil')
                     else
                       node.source.sub(/\s*={2,3}\s*nil/, '.nil?')
                     end
          ->(corrector) { corrector.replace(node.source_range, new_code) }
        end

        private

        def message(_node)
          prefer_comparison? ? EXPLICIT_MSG : PREDICATE_MSG
        end

        def style_check?(node, &block)
          if prefer_comparison?
            nil_check?(node, &block)
          else
            nil_comparison?(node, &block)
          end
        end

        def prefer_comparison?
          style == :comparison
        end
      end
    end
  end
end
