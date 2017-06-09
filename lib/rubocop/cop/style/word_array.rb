# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop can check for array literals made up of word-like
      # strings, that are not using the %w() syntax.
      #
      # Alternatively, it can check for uses of the %w() syntax, in projects
      # which do not want to include that syntax.
      #
      # Configuration option: MinSize
      # If set, arrays with fewer elements than this value will not trigger the
      # cop. For example, a `MinSize of `3` will not enforce a style on an array
      # of 2 or fewer elements.
      #
      # @example
      #   EnforcedStyle: percent (default)
      #
      #   # good
      #   %w[foo bar baz]
      #
      #   # bad
      #   ['foo', 'bar', 'baz']
      #
      # @example
      #   EnforcedStyle: brackets
      #
      #   # good
      #   ['foo', 'bar', 'baz']
      #
      #   # bad
      #   %w[foo bar baz]
      class WordArray < Cop
        include ArrayMinSize
        include ArraySyntax
        include ConfigurableEnforcedStyle
        include PercentLiteral

        PERCENT_MSG = 'Use `%w` or `%W` for an array of words.'.freeze
        ARRAY_MSG = 'Use `[]` for an array of words.'.freeze
        QUESTION_MARK_SIZE = '?'.size

        class << self
          attr_accessor :largest_brackets
        end

        def on_array(node)
          if bracketed_array_of?(:str, node)
            check_bracketed_array(node)
          elsif node.percent_literal?(:string)
            check_percent_array(node)
          end
        end

        def autocorrect(node)
          if style == :percent
            correct_percent(node, 'w')
          else
            correct_bracketed(node)
          end
        end

        private

        def check_bracketed_array(node)
          return if complex_content?(node.values) ||
                    comments_in_array?(node) ||
                    below_array_length?(node)

          array_style_detected(:brackets, node.values.size)
          add_offense(node) if style == :percent
        end

        def check_percent_array(node)
          array_style_detected(:percent, node.values.size)
          add_offense(node) if style == :brackets
        end

        def message(_node)
          style == :percent ? PERCENT_MSG : ARRAY_MSG
        end

        def percent_syntax?(node)
          node.loc.begin && node.loc.begin.source =~ /\A%[wW]/
        end

        def comments_in_array?(node)
          comments = processed_source.comments
          array_range = node.source_range.to_a

          comments.any? do |comment|
            !(comment.loc.expression.to_a & array_range).empty?
          end
        end

        def complex_content?(strings)
          strings.any? do |s|
            string = s.str_content
            !string.dup.force_encoding(::Encoding::UTF_8).valid_encoding? ||
              string !~ word_regex || string =~ / /
          end
        end

        def word_regex
          Regexp.new(cop_config['WordRegex'])
        end

        def correct_bracketed(node)
          words = node.children.map { |w| to_string_literal(w.children[0]) }

          lambda do |corrector|
            corrector.replace(node.source_range, "[#{words.join(', ')}]")
          end
        end
      end
    end
  end
end
