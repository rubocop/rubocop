# frozen_string_literal: true

# This cop programmatically shortens certain long lines.
# It works on method calls, hashes, and arrays. Let's look at hashes as an
# example:
#
# We know hash keys are safe to break across lines. This cop will insert
# linebreaks into hashes on lines longer than the specified maximum. Then
# in further passes other cops will clean up the multi-line hash. For example,
# say the maximum line length is as indicated below:
#
#                                         |
#                                         v
# {foo: "0000000000", bar: "0000000000", baz: "0000000000"}
#
# In the AutocorrectableLineLength pass, a line is added before the second key:
#
# {foo: "0000000000",
# bar: "0000000000", baz: "0000000000"}
#
# In the MultilineHashKeyLineBreaks pass, lines are inserted before all keys:
#
# {foo: "0000000000",
# bar: "0000000000",
# baz: "0000000000"}
#
# Then in future passes FirstHashElementLineBreak, MultilineHashBraceLayout,
# and TrailingCommaInHashLiteral will manipulate as well until we get:
#
# {
#   foo: "0000000000",
#   bar: "0000000000",
#   baz: "0000000000",
# }
#
# (Note: Passes may not happen exactly in this sequence.)

module RuboCop
  module Cop
    module Layout
      # This cop programmatically shortens certain long lines by
      # inserting line breaks into expressions that can be safely
      # split across lines. These include arrays, hashs, and
      # method calls with argument lists.
      #
      # It works best with other layout cops such as
      # MultilineHashBraceLayout, which will insert line breaks
      # before each element in subsequent autocorrect passes.
      #
      # For example, let's say the max columns in 25:
      # @example
      #
      #   # bad
      #   {foo: "0000000000", bar: "0000000000", baz: "0000000000"}
      #
      #   # good
      #   {foo: "0000000000",
      #   bar: "0000000000", baz: "0000000000"}
      #
      #   # good (with complementary cops enabled)
      #   {
      #     foo: "0000000000",
      #     bar: "0000000000",
      #     baz: "0000000000",
      #   }
      class AutocorrectableLineLength < Cop
        include ConfigurableMax

        MSG = 'Autocorrectable long line.'.freeze

        def on_array(node)
          check_breakable(node, node.children)
        end

        def on_hash(node)
          check_breakable(node, node.children)
        end

        def on_send(node)
          args = process_args(node.arguments)
          check_breakable(node, args)
        end

        def autocorrect(node)
          EmptyLineCorrector.insert_before(node)
        end

        private

        def check_breakable(node, elements)
          return unless breakable_collection?(node, elements)
          return if safe_to_ignore?(node)

          line = processed_source.lines[node.first_line - 1]
          return if processed_source.commented?(node.loc.begin)
          return if line.length <= max

          add_offense(node, elements)
        end

        def safe_to_ignore?(node)
          return true unless max
          return true if already_on_multiple_lines?(node)

          # If there's a containing breakable collection on the same
          # line, we let that one get broken first. In a separate pass,
          # this one might get broken as well, but to avoid conflicting
          # or redundant edits, we only mark one offense at a time.
          return true if contained_by_breakable_collection_on_same_line?(node)

          if contained_by_multiline_collection_that_could_be_broken_up?(node)
            return true
          end

          false
        end

        def add_offense(node, elements)
          # Why add the offense on the second argument instead of first?
          # Let's look at the method call case as an example.
          #
          # If we insert a linebreak before the first argument, then the
          # remaining arguments might not be autoformatted on separate
          # lines because this is considered a valid layout:
          #
          # baz(
          #   foo: 1, bar: 2,
          # )
          #
          # To reliably trigger the cascading reformat by several cops
          # described above, we break before the second argument instead.
          second_element = elements[1]
          super(second_element, location: node.loc.expression)
        end

        def max
          cop_config['Max']
        end

        def breakable_collection?(node, elements)
          # For simplicity we only want to insert breaks in normal
          # hashes wrapped in a set of curly braces like {foo: 1}.
          # That is, not a kwargs hash. For method calls, this ensures
          # the method call is made with parens.
          starts_with_bracket = node.loc.begin

          # If the call has a second argument, we can insert a line
          # break before the second argument and the rest of the
          # argument will get auto-formatted onto separate lines
          # by other cops.
          has_second_element = elements.length >= 2

          starts_with_bracket && has_second_element
        end

        def contained_by_breakable_collection_on_same_line?(node)
          node.each_ancestor.find do |ancestor|
            # Ignore ancestors on different lines.
            break if ancestor.first_line != node.first_line

            if ancestor.hash_type? || ancestor.array_type?
              elements = ancestor.children
            elsif ancestor.send_type?
              elements = process_args(ancestor.arguments)
            else
              next
            end

            return true if breakable_collection?(ancestor, elements)
          end

          false
        end

        def contained_by_multiline_collection_that_could_be_broken_up?(node)
          node.each_ancestor.find do |ancestor|
            if ancestor.hash_type? || ancestor.array_type?
              if breakable_collection?(ancestor, ancestor.children)
                return children_could_be_broken_up?(ancestor.children)
              end
            end

            next unless ancestor.send_type?

            args = process_args(ancestor.arguments)
            if breakable_collection?(ancestor, args)
              return children_could_be_broken_up?(args)
            end
          end

          false
        end

        def children_could_be_broken_up?(children)
          return false if all_on_same_line?(children)

          last_seen_line = -1
          children.each do |child|
            return true if last_seen_line >= child.first_line

            last_seen_line = child.last_line
          end
          false
        end

        def all_on_same_line?(nodes)
          return true if nodes.empty?

          nodes.first.first_line == nodes.last.last_line
        end

        def process_args(args)
          # If there is a trailing hash arg without explicit braces, like this:
          #
          #    method(1, 'key1' => value1, 'key2' => value2)
          #
          # ...then each key/value pair is treated as a method 'argument'
          # when determining where line breaks should appear.
          if (last_arg = args.last)
            if last_arg.hash_type? && !last_arg.braces?
              args = args.concat(args.pop.children)
            end
          end
          args
        end

        def already_on_multiple_lines?(node)
          node.first_line != node.last_line
        end
      end
    end
  end
end
