# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop identifies Float literals which are, like, really really really
      # really really really really really big. Too big. No-one needs Floats
      # that big. If you need a float that big, something is wrong with you.
      #
      # @example
      #
      #   # bad
      #
      #   float = 3.0e400
      #
      # @example
      #
      #   # good
      #
      #   float = 42.9
      class FloatOutOfRange < Cop
        MSG = 'Float out of range.'.freeze

        def on_float(node)
          value, = *node

          return unless value.infinite? ||
                        value.zero? && node.source =~ /[1-9]/

          add_offense(node)
        end
      end
    end
  end
end
