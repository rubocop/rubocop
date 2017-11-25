# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for class methods that are defined using the `::`
      # operator instead of the `.` operator.
      #
      # @example
      #   # bad
      #   class Foo
      #     def self::bar
      #     end
      #   end
      #
      #   # good
      #   class Foo
      #     def self.bar
      #     end
      #   end
      #
      class ColonMethodDefinition < Cop
        MSG = 'Do not use `::` for defining class methods.'.freeze

        def on_defs(node)
          return unless node.loc.operator.source == '::'
          add_offense(node, location: :operator)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.operator, '.') }
        end
      end
    end
  end
end
