# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the consistent usage of `%`-literal delimiters.
      #
      # Specify the 'default' key to set all preferred delimiters at once. You
      # can continue to specify individual preferred delimiters to override the
      # default.
      #
      # @example
      #   # Style/PercentLiteralDelimiters:
      #   #   PreferredDelimiters:
      #   #     default: '[]'
      #   #     '%i':    '()'
      #
      #   # good
      #   %w[alpha beta] + %i(gamma delta)
      #
      #   # bad
      #   %W(alpha #{beta})
      #
      #   # bad
      #   %I(alpha beta)
      class PercentLiteralDelimiters < Cop
        include PercentLiteral

        def on_array(node)
          process(node, '%w', '%W', '%i', '%I')
        end

        def on_regexp(node)
          process(node, '%r')
        end

        def on_str(node)
          process(node, '%', '%Q', '%q')
        end
        alias on_dstr on_str

        def on_sym(node)
          process(node, '%s')
        end

        def on_xstr(node)
          process(node, '%x')
        end

        def message(node)
          type = type(node)
          delimiters = preferred_delimiters_for(type)

          "`#{type}`-literals should be delimited by " \
          "`#{delimiters[0]}` and `#{delimiters[1]}`."
        end

        def autocorrect(node)
          type = type(node)

          opening_delimiter, closing_delimiter = preferred_delimiters_for(type)

          lambda do |corrector|
            corrector.replace(node.loc.begin, "#{type}#{opening_delimiter}")
            corrector.replace(node.loc.end, closing_delimiter)
          end
        end

        private

        def on_percent_literal(node)
          type = type(node)
          return if uses_preferred_delimiter?(node, type) ||
                    contains_preferred_delimiter?(node, type) ||
                    include_same_character_as_used_for_delimiter?(node, type)

          add_offense(node)
        end

        def preferred_delimiters_for(type)
          PreferredDelimiters
            .new(type, @config, nil)
            .delimiters
        end

        def uses_preferred_delimiter?(node, type)
          preferred_delimiters_for(type)[0] == begin_source(node)[-1]
        end

        def contains_preferred_delimiter?(node, type)
          contains_delimiter?(node, preferred_delimiters_for(type))
        end

        def include_same_character_as_used_for_delimiter?(node, type)
          return false unless %w[%w %i].include?(type)

          used_delimiters = matchpairs(begin_source(node)[-1])
          contains_delimiter?(node, used_delimiters)
        end

        def contains_delimiter?(node, delimiters)
          delimiters_regexp = Regexp.union(delimiters)
          node
            .children.map { |n| string_source(n) }.compact
            .any? { |s| delimiters_regexp.match?(s) }
        end

        def string_source(node)
          if node.is_a?(String)
            node.scrub
          elsif node.respond_to?(:type) && (node.str_type? || node.sym_type?)
            node.source
          end
        end

        def matchpairs(begin_delimiter)
          {
            '(' => %w[( )],
            '[' => %w[[ ]],
            '{' => %w[{ }],
            '<' => %w[< >]
          }.fetch(begin_delimiter, [begin_delimiter])
        end
      end
    end
  end
end
