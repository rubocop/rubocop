# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks if uses of quotes match the configured preference.
      class StringLiterals < Cop
        include ConfigurableEnforcedStyle
        include StringLiteralsHelp

        MSG_INCONSISTENT = 'Inconsistent quote style.'.freeze

        def on_dstr(node)
          # Strings which are continued across multiple lines using \
          # are parsed as a `dstr` node with `str` children
          # If one part of that continued string contains interpolations,
          # then it will be parsed as a nested `dstr` node
          return unless consistent_multiline?
          return if node.loc.is_a?(Parser::Source::Map::Heredoc)

          children = node.children
          return unless all_string_literals?(children)

          quote_styles = detect_quote_styles(node)

          if quote_styles.size > 1
            add_offense(node, :expression, MSG_INCONSISTENT)
          else
            check_multiline_quote_style(node, quote_styles[0])
          end

          ignore_node(node)
        end

        private

        def all_string_literals?(nodes)
          nodes.all? { |n| n.str_type? || n.dstr_type? }
        end

        def detect_quote_styles(node)
          styles = node.children.map { |c| c.loc.begin }

          # For multi-line strings that only have quote marks
          # at the beginning of the first line and the end of
          # the last, the begin and end region of each child
          # is nil. The quote marks are in the parent node.
          return [node.loc.begin.source] if styles.all?(&:nil?)

          styles.map(&:source).uniq
        end

        def message(*)
          if style == :single_quotes
            "Prefer single-quoted strings when you don't need string " \
            'interpolation or special symbols.'
          else
            'Prefer double-quoted strings unless you need single quotes to ' \
            'avoid extra backslashes for escaping.'
          end
        end

        def offense?(node)
          # If it's a string within an interpolation, then it's not an offense
          # for this cop.
          return false if inside_interpolation?(node)

          wrong_quotes?(node)
        end

        def consistent_multiline?
          cop_config['ConsistentQuotesInMultiline']
        end

        def check_multiline_quote_style(node, quote)
          range = node.source_range
          children = node.children
          if quote == "'" && style == :double_quotes
            add_offense(node, range) if children.all? { |c| wrong_quotes?(c) }
          elsif quote == '"' && style == :single_quotes
            if children.none?(&:dstr_type?) &&
               children.none? { |c| double_quotes_acceptable?(c.str_content) }
              add_offense(node, range)
            end
          end
        end
      end
    end
  end
end
