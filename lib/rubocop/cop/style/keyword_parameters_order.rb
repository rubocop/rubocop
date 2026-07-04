# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Enforces that optional keyword parameters are placed at the
      # end of the parameters list.
      #
      # This improves readability, because when looking through the source,
      # it is expected to find required parameters at the beginning of parameters list
      # and optional parameters at the end.
      #
      # @example
      #   # bad
      #   def some_method(first: false, second:, third: 10)
      #     # body omitted
      #   end
      #
      #   # good
      #   def some_method(second:, first: false, third: 10)
      #     # body omitted
      #   end
      #
      #   # bad
      #   do_something do |first: false, second:, third: 10|
      #     # body omitted
      #   end
      #
      #   # good
      #   do_something do |second:, first: false, third: 10|
      #     # body omitted
      #   end
      #
      class KeywordParametersOrder < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Place optional keyword parameters at the end of the parameters list.'

        def on_kwoptarg(node)
          kwarg_nodes = node.right_siblings.select(&:kwarg_type?)
          return if kwarg_nodes.empty?

          add_offense(node) do |corrector|
            defining_node = node.each_ancestor(:any_def, :block).first
            next if processed_source.contains_comment?(arguments_range(defining_node))
            next unless node.parent.find(&:kwoptarg_type?) == node

            autocorrect(corrector, node, defining_node, kwarg_nodes)
          end
        end

        private

        def autocorrect(corrector, node, defining_node, kwarg_nodes)
          corrector.insert_before(node, "#{kwarg_nodes.map(&:source).join(', ')}, ")

          arguments = defining_node.arguments
          append_newline_to_last_kwoptarg(arguments, corrector) unless parentheses?(arguments)

          remove_kwargs(kwarg_nodes, corrector)
        end

        def append_newline_to_last_kwoptarg(arguments, corrector)
          # The newline only needs restoring when the moved keyword argument was
          # the last parameter, so removing it also consumes the line break before
          # the body. When a `kwoptarg` already trails the list, the body stays
          # separated and inserting a newline would leave a spurious blank line.
          return unless arguments.last.kwarg_type?
          return if arguments.parent.block_type?

          last_kwoptarg = arguments.reverse.find(&:kwoptarg_type?)
          corrector.insert_after(last_kwoptarg, "\n")
        end

        def remove_kwargs(kwarg_nodes, corrector)
          kwarg_nodes.each do |kwarg|
            with_space = range_with_surrounding_space(kwarg.source_range)
            corrector.remove(range_with_surrounding_comma(with_space, :left))
          end
        end
      end
    end
  end
end
