# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop can check for array literals made up of symbols that are not
      # using the %i() syntax.
      #
      # Alternatively, it checks for symbol arrays using the %i() syntax on
      # projects which do not want to use that syntax.
      #
      # This check makes sense only on Ruby 2.0+.
      class SymbolArray < Cop
        include ConfigurableEnforcedStyle
        include ArraySyntax

        PERCENT_MSG = 'Use `%i` or `%I` for an array of symbols.'
        ARRAY_MSG = 'Use `[]` for an array of symbols.'

        def on_array(node)
          # %i and %I were introduced in Ruby 2.0
          return if RUBY_VERSION < '2.0.0'

          if bracketed_array_of?(:sym, node)
            return if comments_in_array?(node)
            return if symbols_contain_spaces?(node)
            style_detected(:brackets)
            add_offense(node, :expression, PERCENT_MSG) if style == :percent
          elsif node.loc.begin && node.loc.begin.source =~ /\A%[iI]/
            style_detected(:percent)
            add_offense(node, :expression, ARRAY_MSG) if style == :brackets
          end
        end

        private

        def comments_in_array?(node)
          comments = processed_source.comments
          array_range = node.loc.expression.to_a

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
      end
    end
  end
end
