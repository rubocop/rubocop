# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for uses of `rescue` with no error class specified.
      #
      # @example
      #
      #   # good
      #   begin
      #     foo
      #   rescue BarError
      #     bar
      #   end
      #
      #   # bad
      #   begin
      #     foo
      #   rescue
      #     bar
      #   end
      class RescueWithoutErrorClass < Cop
        include RescueNode

        MSG = 'Avoid rescuing without specifying an error class.'.freeze

        def_node_matcher :rescue_without_error_class?, <<-PATTERN
          (resbody nil? _ _)
        PATTERN

        def on_resbody(node)
          return unless rescue_without_error_class?(node) &&
                        !rescue_modifier?(node)

          add_offense(node, location: :keyword)
        end
      end
    end
  end
end
