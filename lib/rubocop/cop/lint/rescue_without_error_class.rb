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
      #
      # @example
      #
      #   # good
      #   foo rescue BarError; "baz"
      #
      #   # bad
      #   foo rescue "baz"
      class RescueWithoutErrorClass < Cop
        MSG = 'Avoid rescuing without specifying an error class.'.freeze

        def_node_matcher :rescue_without_error_class?, <<-PATTERN
          (resbody nil _ !(const ...))
        PATTERN

        def on_resbody(node)
          return unless rescue_without_error_class?(node)

          add_offense(node, :keyword)
        end
      end
    end
  end
end
