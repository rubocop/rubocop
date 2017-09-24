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
      #   when *[1, 2, 3]
      #     bar
      #   else
      #     baz
      #   end
      class UnneededSplatExpansion < Cop
        MSG = 'Unnecessary splat expansion.'.freeze
        ARRAY_PARAM_MSG = 'Pass array contents as separate arguments.'.freeze
        PERCENT_W = '%w'.freeze
        PERCENT_CAPITAL_W = '%W'.freeze
        PERCENT_I = '%i'.freeze
        PERCENT_CAPITAL_I = '%I'.freeze
        ARRAY_NEW_PATTERN = '$(send (const nil? :Array) :new ...)'.freeze
        ASSIGNMENT_TYPES = %i[lvasgn ivasgn cvasgn gvasgn].freeze

        def_node_matcher :literal_expansion?, <<-PATTERN
          (splat {$({str dstr int float array} ...) (block #{ARRAY_NEW_PATTERN} ...) #{ARRAY_NEW_PATTERN}} ...)
        PATTERN

        def on_splat(node)
          literal_expansion?(node) do |object|
            if object.send_type?
              return unless ASSIGNMENT_TYPES.include?(node.parent.parent.type)
            end

            if array_splat?(node) &&
               (method_argument?(node) || part_of_an_array?(node))
              add_offense(node, message: ARRAY_PARAM_MSG)
            else
              add_offense(node)
            end
          end
        end

        private

        def autocorrect(node)
          variable, = *node
          loc = node.loc

          lambda do |corrector|
            if !variable.array_type?
              corrector.replace(loc.expression, "[#{variable.source}]")
            elsif unneeded_brackets?(node)
              corrector.replace(loc.expression, remove_brackets(variable))
            else
              corrector.remove(loc.operator)
            end
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

        def unneeded_brackets?(node)
          parent = node.parent
          grandparent = node.parent.parent

          parent.when_type? || parent.send_type? || part_of_an_array?(node) ||
            (grandparent && grandparent.resbody_type?)
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
