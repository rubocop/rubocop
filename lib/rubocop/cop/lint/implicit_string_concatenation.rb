# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for implicit string concatenation of string literals
      # which are on the same line.
      #
      # @example
      #
      #   # bad
      #
      #   array = ['Item 1' 'Item 2']
      #
      # @example
      #
      #   # good
      #
      #   array = ['Item 1Item 2']
      #   array = ['Item 1' + 'Item 2']
      #   array = [
      #     'Item 1' \
      #     'Item 2'
      #   ]
      class ImplicitStringConcatenation < Cop
        MSG = 'Combine %<string1>s and %<string2>s into a single string ' \
              'literal, rather than using implicit string concatenation.'.freeze
        FOR_ARRAY = ' Or, if they were intended to be separate array ' \
                    'elements, separate them with a comma.'.freeze
        FOR_METHOD = ' Or, if they were intended to be separate method ' \
                     'arguments, separate them with a comma.'.freeze

        def on_dstr(node)
          each_bad_cons(node) do |child_node1, child_node2|
            range   = child_node1.source_range.join(child_node2.source_range)
            message = format(MSG,
                             string1: display_str(child_node1),
                             string2: display_str(child_node2))
            if node.parent && node.parent.array_type?
              message << FOR_ARRAY
            elsif node.parent && node.parent.send_type?
              message << FOR_METHOD
            end
            add_offense(node, location: range, message: message)
          end
        end

        private

        def each_bad_cons(node)
          node.children.each_cons(2) do |child_node1, child_node2|
            # `'abc' 'def'` -> (dstr (str "abc") (str "def"))
            next unless string_literals?(child_node1, child_node2)
            next unless child_node1.last_line == child_node2.first_line

            # Make sure we don't flag a string literal which simply has
            # embedded newlines
            # `"abc\ndef"` also -> (dstr (str "abc") (str "def"))
            next unless child_node1.source[-1] == ending_delimiter(child_node1)

            yield child_node1, child_node2
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

        def string_literals?(node1, node2)
          string_literal?(node1) && string_literal?(node2)
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
