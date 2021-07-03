# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks if spaces are used around the singleton class operator <<.
      #
      # @example EnforcedStyle: space (default)
      #   # bad
      #   class SomeClass
      #     class<<self
      #     end
      #   end
      #
      #   # good
      #   class SomeClass
      #     class << self
      #     end
      #   end
      #
      # @example EnforcedStyle: no_space
      #   # bad
      #   class SomeClass
      #     class << self
      #     end
      #   end
      #
      #   # good
      #   class SomeClass
      #     class<<self
      #     end
      #   end
      #
      class SpaceAroundSingletonClassOperator < Base
        include RangeHelp
        include ConfigurableEnforcedStyle

        MSG_SPACE = 'Use a single space around the singleton class operator.'
        MSG_NO_SPACE = 'Use no space around the singleton class operator.'

        def on_sclass(node)
          range = range_with_surrounding_space(range: node.loc.operator)
          case style
          when :space
            add_offense(range, message: MSG_SPACE) if range.source != ' << '
          else
            add_offense(range, message: MSG_NO_SPACE) if range.source != '<<'
          end
        end
      end
    end
  end
end
