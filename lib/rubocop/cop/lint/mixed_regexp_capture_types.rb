# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Do not mix named captures and numbered captures in a Regexp literal
      # because numbered capture is ignored if they're mixed.
      # Replace numbered captures with non-capturing groupings or
      # named captures.
      #
      #   # bad
      #   /(?<foo>FOO)(BAR)/
      #
      #   # good
      #   /(?<foo>FOO)(?<bar>BAR)/
      #
      #   # good
      #   /(?<foo>FOO)(?:BAR)/
      #
      #   # good
      #   /(FOO)(BAR)/
      #
      class MixedRegexpCaptureTypes < Cop
        MSG = 'Do not mix named captures and numbered captures ' \
              'in a Regexp literal.'

        def on_regexp(node)
          tree = Regexp::Parser.parse(node.content)
          return unless named_capture?(tree)
          return unless numbered_capture?(tree)

          add_offense(node)
        end

        private

        def named_capture?(tree)
          tree.each_expression.any? do |e|
            e.instance_of?(Regexp::Expression::Group::Capture)
          end
        end

        def numbered_capture?(tree)
          tree.each_expression.any? do |e|
            e.instance_of?(Regexp::Expression::Group::Named)
          end
        end
      end
    end
  end
end
