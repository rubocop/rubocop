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
      class MixedRegexpCaptureTypes < Base
        MSG = 'Do not mix named captures and numbered captures ' \
              'in a Regexp literal.'

        def on_regexp(node)
          return if contain_non_literal?(node)

          begin
            tree = Regexp::Parser.parse(node.content)
          # Returns if a regular expression that cannot be processed by regexp_parser gem.
          # https://github.com/rubocop-hq/rubocop/issues/8083
          rescue Regexp::Scanner::ScannerError
            return
          end

          return unless named_capture?(tree)
          return unless numbered_capture?(tree)

          add_offense(node)
        end

        private

        def contain_non_literal?(node)
          if node.respond_to?(:type) && (node.variable? || node.send_type? || node.const_type?)
            return true
          end
          return false unless node.respond_to?(:children)

          node.children.any? { |child| contain_non_literal?(child) }
        end

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
