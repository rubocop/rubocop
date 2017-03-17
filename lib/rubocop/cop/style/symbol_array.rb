# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop can check for array literals made up of symbols that are not
      # using the %i() syntax.
      #
      # Alternatively, it checks for symbol arrays using the %i() syntax on
      # projects which do not want to use that syntax, perhaps because they
      # support a version of Ruby lower than 2.0.
      #
      # @example
      #
      # # EnforcedStyle: percent (default)
      #
      # # good
      # %i[foo bar baz]
      #
      # # bad
      # [:foo, :bar, :baz]
      #
      # @example
      #
      # # EnforcedStyle: brackets
      #
      # # good
      # [:foo, :bar, :baz]
      #
      # # bad
      # %i[foo bar baz]
      class SymbolArray < Cop
        include ConfigurableEnforcedStyle
        include ArraySyntax
        include PercentLiteral
        extend TargetRubyVersion

        minimum_target_ruby_version 2.0

        PERCENT_MSG = 'Use `%i` or `%I` for an array of symbols.'.freeze
        ARRAY_MSG = 'Use `[]` for an array of symbols.'.freeze

        def on_array(node)
          if bracketed_array_of?(:sym, node)
            check_bracketed_array(node)
          elsif node.percent_literal?(:symbol)
            check_percent_array(node)
          end
        end

        private

        def check_bracketed_array(node)
          return if comments_in_array?(node)
          return if symbols_contain_spaces?(node)

          style_detected(:brackets)
          add_offense(node, :expression, PERCENT_MSG) if style == :percent
        end

        def check_percent_array(node)
          style_detected(:percent)
          add_offense(node, :expression, ARRAY_MSG) if style == :brackets
        end

        def comments_in_array?(node)
          comments = processed_source.comments
          array_range = node.source_range.to_a

          comments.any? do |comment|
            !(comment.loc.expression.to_a & array_range).empty?
          end
        end

        def symbols_contain_spaces?(node)
          node.children.any? do |sym|
            content, = *sym
            content =~ / /
          end
        end

        def autocorrect(node)
          if style == :percent
            correct_percent(node, 'i')
          else
            correct_bracketed(node)
          end
        end

        def correct_bracketed(node)
          syms = node.children.map { |c| to_symbol_literal(c.children[0].to_s) }

          lambda do |corrector|
            corrector.replace(node.source_range, "[#{syms.join(', ')}]")
          end
        end
      end
    end
  end
end
