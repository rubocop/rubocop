# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for unneeded usages of splat expansion
      #
      # @example
      #
      #   # bad
      #
      #   a = *[1, 2, 3]
      #   a = *'a'
      #   a = *1
      #
      #   begin
      #     foo
      #   rescue *[StandardError, ApplicationError]
      #     bar
      #   end
      #
      #   case foo
      #   when *[1, 2, 3]
      #     bar
      #   else
      #     baz
      #   end
      #
      # @example
      #
      #   # good
      #
      #   c = [1, 2, 3]
      #   a = *c
      #   a, b = *c
      #   a, *b = *c
      #   a = *1..10
      #   a = ['a']
      #
      #   begin
      #     foo
      #   rescue StandardError, ApplicationError
      #     bar
      #   end
      #
      #   case foo
      #   when 1, 2, 3
      #     bar
      #   else
      #     baz
      #   end
      class RedundantSplatExpansion < Cop
        MSG = 'Replace splat expansion with comma separated values.'
        ARRAY_PARAM_MSG = 'Pass array contents as separate arguments.'
        PERCENT_W = '%w'
        PERCENT_CAPITAL_W = '%W'
        PERCENT_I = '%i'
        PERCENT_CAPITAL_I = '%I'
        ASSIGNMENT_TYPES = %i[lvasgn ivasgn cvasgn gvasgn].freeze

        def_node_matcher :array_new?, <<~PATTERN
          {
            $(send (const nil? :Array) :new ...)
            $(block (send (const nil? :Array) :new ...) ...)
          }
        PATTERN

        def_node_matcher :literal_expansion, <<~PATTERN
          (splat {$({str dstr int float array} ...) (block $#array_new? ...) $#array_new?} ...)
        PATTERN

        def on_splat(node)
          redundant_splat_expansion(node) do
            if array_splat?(node) &&
               (method_argument?(node) || part_of_an_array?(node))
              add_offense(node, message: ARRAY_PARAM_MSG)
            else
              add_offense(node)
            end
          end
        end

        def autocorrect(node)
          range, content = replacement_range_and_content(node)

          lambda do |corrector|
            corrector.replace(range, content)
          end
        end

        private

        def redundant_splat_expansion(node)
          literal_expansion(node) do |expanded_item|
            if expanded_item.send_type?
              return if array_new_inside_array_literal?(expanded_item)

              grandparent = node.parent.parent
              return if grandparent &&
                        !ASSIGNMENT_TYPES.include?(grandparent.type)
            end

            yield
          end
        end

        def array_new_inside_array_literal?(array_new_node)
          return false unless array_new?(array_new_node)

          grandparent = array_new_node.parent.parent
          grandparent.array_type? && grandparent.children.size > 1
        end

        def replacement_range_and_content(node)
          variable, = *node
          loc = node.loc

          if array_new?(variable)
            [node.parent.loc.expression, variable.source]
          elsif !variable.array_type?
            [loc.expression, "[#{variable.source}]"]
          elsif redundant_brackets?(node)
            [loc.expression, remove_brackets(variable)]
          else
            [loc.operator, '']
          end
        end

        def array_splat?(node)
          node.children.first.array_type?
        end

        def method_argument?(node)
          node.parent.send_type?
        end

        def part_of_an_array?(node)
          # The parent of a splat expansion is an array that does not have
          # `begin` or `end`
          parent = node.parent
          parent.array_type? && parent.loc.begin && parent.loc.end
        end

        def redundant_brackets?(node)
          parent = node.parent
          grandparent = node.parent.parent

          parent.when_type? || parent.send_type? || part_of_an_array?(node) ||
            (grandparent&.resbody_type?)
        end

        def remove_brackets(array)
          array_start = array.loc.begin.source
          elements = *array
          elements = elements.map(&:source)

          if array_start.start_with?(PERCENT_W)
            "'#{elements.join("', '")}'"
          elsif array_start.start_with?(PERCENT_CAPITAL_W)
            %("#{elements.join('", "')}")
          elsif array_start.start_with?(PERCENT_I)
            ":#{elements.join(', :')}"
          elsif array_start.start_with?(PERCENT_CAPITAL_I)
            %(:"#{elements.join('", :"')}")
          else
            elements.join(', ')
          end
        end
      end
    end
  end
end
