# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for comparison of something with nil using `==` and
      # `nil?`.
      #
      # Supported styles are: predicate_method, explicit_comparison.
      #
      # @example EnforcedStyle: predicate_method (default)
      #
      #   # bad
      #   if x == nil
      #   end
      #
      #   # good
      #   if x.nil?
      #   end
      #
      # @example EnforcedStyle: explicit_comparison
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
        EXPLICIT_MSG = 'Prefer the use of the explicit `==` comparison.'.freeze

        def_node_matcher :nil_comparison?, '(send _ {:== :===} nil)'
        def_node_matcher :nil_check?, '(send _ :nil?)'

        def on_send(node)
          style_check?(node) do
            add_offense(node, location: :selector)
          end
        end

        def autocorrect(node)
          new_code = if explicit_comparison?
                       node.source.sub('.nil?', ' == nil')
                     else
                       node.source.sub(/\s*={2,3}\s*nil/, '.nil?')
                     end
          ->(corrector) { corrector.replace(node.source_range, new_code) }
        end

        private

        def message(_node)
          explicit_comparison? ? EXPLICIT_MSG : PREDICATE_MSG
        end

        def style_check?(node, &block)
          if explicit_comparison?
            nil_check?(node, &block)
          else
            nil_comparison?(node, &block)
          end
        end

        def explicit_comparison?
          style == :explicit_comparison
        end
      end
    end
  end
end
