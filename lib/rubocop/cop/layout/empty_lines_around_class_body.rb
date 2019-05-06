# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks if empty lines around the bodies of classes match
      # the configuration.
      #
      # @example EnforcedStyle: empty_lines
      #   # good
      #
      #   class Foo
      #
      #     def bar
      #       # ...
      #     end
      #
      #   end
      #
      # @example EnforcedStyle: empty_lines_except_namespace
      #   # good
      #
      #   class Foo
      #     class Bar
      #
      #       # ...
      #
      #     end
      #   end
      #
      # @example EnforcedStyle: empty_lines_special
      #   # good
      #   class Foo
      #
      #     def bar; end
      #
      #   end
      #
      # @example Enforcedstyle: beginning_only
      #   # good
      #
      #   class Foo
      #
      #     def bar
      #       # ...
      #     end
      #   end
      #
      # @example Enforcedstyle: ending_only
      #   # good
      #
      #   class Foo
      #     def bar
      #       # ...
      #     end
      #
      #   end
      #
      # @example EnforcedStyle: no_empty_lines (default)
      #   # good
      #
      #   class Foo
      #     def bar
      #       # ...
      #     end
      #   end
      class EmptyLinesAroundClassBody < Cop
        include EmptyLinesAroundBody

        KIND = 'class'

        def on_class(node)
          first_line = node.parent_class.first_line if node.parent_class

          check(node, node.body, adjusted_first_line: first_line)
        end

        def on_sclass(node)
          check(node, node.body)
        end

        def autocorrect(node)
          EmptyLineCorrector.correct(node)
        end
      end
    end
  end
end
