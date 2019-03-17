# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop can check for array literals made up of symbols that are not
      # using the %i() syntax.
      #
      # Alternatively, it checks for symbol arrays using the %i() syntax on
      # projects which do not want to use that syntax.
      #
      # Configuration option: MinSize
      # If set, arrays with fewer elements than this value will not trigger the
      # cop. For example, a `MinSize of `3` will not enforce a style on an array
      # of 2 or fewer elements.
      #
      # @example EnforcedStyle: percent (default)
      #   # good
      #   %i[foo bar baz]
      #
      #   # bad
      #   [:foo, :bar, :baz]
      #
      # @example EnforcedStyle: brackets
      #   # good
      #   [:foo, :bar, :baz]
      #
      #   # bad
      #   %i[foo bar baz]
      class SymbolArray < Cop
        include ArrayMinSize
        include ArraySyntax
        include ConfigurableEnforcedStyle
        include PercentArray

        PERCENT_MSG = 'Use `%i` or `%I` for an array of symbols.'.freeze
        ARRAY_MSG = 'Use `[]` for an array of symbols.'.freeze

        class << self
          attr_accessor :largest_brackets
        end

        def on_array(node)
          if bracketed_array_of?(:sym, node)
            return if symbols_contain_spaces?(node)

            check_bracketed_array(node)
          elsif node.percent_literal?(:symbol)
            check_percent_array(node)
          end
        end

        def autocorrect(node)
          if style == :percent
            PercentLiteralCorrector
              .new(@config, @preferred_delimiters)
              .correct(node, 'i')
          else
            correct_bracketed(node)
          end
        end

        private

        def symbols_contain_spaces?(node)
          node.children.any? do |sym|
            content, = *sym
            content =~ / /
          end
        end

        def correct_bracketed(node)
          syms = node.children.map do |c|
            if c.dsym_type?
              string_literal = to_string_literal(c.source)

              ':' + trim_string_interporation_escape_character(string_literal)
            else
              to_symbol_literal(c.value.to_s)
            end
          end

          lambda do |corrector|
            corrector.replace(node.source_range, "[#{syms.join(', ')}]")
          end
        end

        def to_symbol_literal(string)
          if symbol_without_quote?(string)
            ":#{string}"
          else
            ":#{to_string_literal(string)}"
          end
        end

        def symbol_without_quote?(string)
          special_gvars = %w[
            $! $" $$ $& $' $* $+ $, $/ $; $: $. $< $= $> $? $@ $\\ $_ $` $~ $0
            $-0 $-F $-I $-K $-W $-a $-d $-i $-l $-p $-v $-w
          ]
          redefinable_operators = %w(
            | ^ & <=> == === =~ > >= < <= << >>
            + - * / % ** ~ +@ -@ [] []= ` ! != !~
          )

          # method name
          string =~ /\A[a-zA-Z_]\w*[!?]?\z/ ||
            # instance / class variable
            string =~ /\A\@\@?[a-zA-Z_]\w*\z/ ||
            # global variable
            string =~ /\A\$[1-9]\d*\z/ ||
            string =~ /\A\$[a-zA-Z_]\w*\z/ ||
            special_gvars.include?(string) ||
            redefinable_operators.include?(string)
        end
      end
    end
  end
end
