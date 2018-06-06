# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for unnecessary leading blank lines at the beginning
      # of a file.
      #
      # @example
      #
      #   # bad
      #   # (start of file)
      #
      #   class Foo
      #   end
      #
      #   # bad
      #   # (start of file)
      #
      #   # a comment
      #
      #   # good
      #   # (start of file)
      #   class Foo
      #   end
      #
      #   # good
      #   # (start of file)
      #   # a comment
      class LeadingBlankLines < Cop
        MSG = 'Unnecessary blank line at the beginning of the source.'.freeze

        def investigate(processed_source)
          token = processed_source.tokens[0]
          return unless token && token.line > 1

          add_offense(processed_source.tokens[0],
                      location: processed_source.tokens[0].pos)
        end

        def autocorrect(node)
          range = Parser::Source::Range.new(processed_source.raw_source,
                                            0,
                                            node.begin_pos)

          lambda do |corrector|
            corrector.remove(range)
          end
        end
      end
    end
  end
end
