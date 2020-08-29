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
      # cop. For example, a `MinSize` of `3` will not enforce a style on an
      # array of 2 or fewer elements.
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
      class SymbolArray < Base
        include ArrayMinSize
        include ArraySyntax
        include ConfigurableEnforcedStyle
        include PercentArray
        extend AutoCorrector

        PERCENT_MSG = 'Use `%i` or `%I` for an array of symbols.'
        ARRAY_MSG = 'Use `[]` for an array of symbols.'

        class << self
          attr_accessor :largest_brackets
        end

        def on_array(node)
          if bracketed_array_of?(:sym, node)
            return if symbols_contain_spaces?(node)

            check_bracketed_array(node, 'i')
          elsif node.percent_literal?(:symbol)
            check_percent_array(node)
          end
        end

        private

        def symbols_contain_spaces?(node)
          node.children.any? do |sym|
            content, = *sym
            / /.match?(content)
          end
        end

        def correct_bracketed(corrector, node)
          syms = node.children.map do |c|
            if c.dsym_type?
              string_literal = to_string_literal(c.source)

              ":#{trim_string_interporation_escape_character(string_literal)}"
            else
              to_symbol_literal(c.value.to_s)
            end
          end

          corrector.replace(node, "[#{syms.join(', ')}]")
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
          /\A[a-zA-Z_]\w*[!?]?\z/.match?(string) ||
            # instance / class variable
            /\A@@?[a-zA-Z_]\w*\z/.match?(string) ||
            # global variable
            /\A\$[1-9]\d*\z/.match?(string) ||
            /\A\$[a-zA-Z_]\w*\z/.match?(string) ||
            special_gvars.include?(string) ||
            redefinable_operators.include?(string)
        end
      end
    end
  end
end
