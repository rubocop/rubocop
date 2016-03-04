# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for implicit string concatenation of string literals
      # which are on the same line.
      #
      # @example
      #   @bad
      #   array = ['Item 1' 'Item 2']
      #
      #   @good
      #   array = ['Item 1Item 2']
      #   array = ['Item 1' + 'Item 2']
      #   array = [
      #     'Item 1' \
      #     'Item 2'
      #   ]
      class ImplicitStringConcatenation < Cop
        MSG = 'Combine %s and %s into a single string literal, rather than ' \
              'using implicit string concatenation.'.freeze
        FOR_ARRAY = ' Or, if they were intended to be separate array ' \
                    'elements, separate them with a comma.'.freeze
        FOR_METHOD = ' Or, if they were intended to be separate method ' \
                     'arguments, separate them with a comma.'.freeze

        def on_dstr(node)
          each_bad_cons(node) do |child1, child2|
            range   = child1.source_range.join(child2.source_range)
            message = format(MSG, display_str(child1), display_str(child2))
            if node.parent && node.parent.array_type?
              message << FOR_ARRAY
            elsif node.parent && node.parent.send_type?
              message << FOR_METHOD
            end
            add_offense(node, range, message)
          end
        end

        private

        def each_bad_cons(node)
          node.children.each_cons(2) do |child1, child2|
            # `'abc' 'def'` -> (dstr (str "abc") (str "def"))
            next unless string_literal?(child1) && string_literal?(child2)
            next unless child1.loc.last_line == child2.loc.line

            # Make sure we don't flag a string literal which simply has
            # embedded newlines
            # `"abc\ndef"` also -> (dstr (str "abc") (str "def"))
            next unless child1.source[-1] == ending_delimiter(child1)

            yield child1, child2
          end
        end

        def ending_delimiter(str)
          # implicit string concatenation does not work with %{}, etc.
          if str.source[0] == "'"
            "'"
          elsif str.source[0] == '"'
            '"'
          end
        end

        def string_literal?(node)
          node.str_type? ||
            (node.dstr_type? && node.children.all? { |c| string_literal?(c) })
        end

        def display_str(node)
          if node.source =~ /\n/
            str_content(node).inspect
          else
            node.source
          end
        end

        def str_content(node)
          if node.str_type?
            node.children[0]
          else
            node.children.map { |c| str_content(c) }.join
          end
        end
      end
    end
  end
end
