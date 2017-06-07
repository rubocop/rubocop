# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for unnecessary additional spaces inside the delimiters of
      # %i/%w/%x literals.
      #
      # @example
      #
      #   # good
      #   %i(foo bar baz)
      #
      #   # bad
      #   %w( foo bar baz )
      #
      #   # bad
      #   %x(  ls -l )
      class SpaceInsidePercentLiteralDelimiters < Cop
        include MatchRange
        include PercentLiteral

        MSG = 'Do not use spaces inside percent literal delimiters.'.freeze
        BEGIN_REGEX = /\A( +)/
        END_REGEX = /(?<!\\)( +)\z/

        def on_array(node)
          process(node, '%i', '%I', '%w', '%W')
        end

        def on_xstr(node)
          process(node, '%x')
        end

        def on_percent_literal(node)
          add_offenses_for_unnecessary_spaces(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            regex_matches(node) do |match_range|
              corrector.remove(match_range)
            end
          end
        end

        private

        def add_offenses_for_unnecessary_spaces(node)
          return unless node.single_line?

          regex_matches(node) do |match_range|
            add_offense(node, match_range)
          end
        end

        def regex_matches(node, &blk)
          [BEGIN_REGEX, END_REGEX].each do |regex|
            each_match_range(contents_range(node), regex, &blk)
          end
        end
      end
    end
  end
end
