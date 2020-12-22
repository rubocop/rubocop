# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks whether class/module/method definitions are
      # separated by one or more empty lines.
      #
      # `NumberOfEmptyLines` can be an integer (default is 1) or
      # an array (e.g. [1, 2]) to specify a minimum and maximum
      # number of empty lines permitted.
      #
      # `AllowAdjacentOneLineDefs` configures whether adjacent
      # one-line definitions are considered an offense.
      #
      # @example EmptyLineBetweenMethodDefs: true (default)
      #   # checks for empty lines between method definitions.
      #
      #   # bad
      #   def a
      #   end
      #   def b
      #   end
      #
      # @example
      #
      #   # good
      #   def a
      #   end
      #
      #   def b
      #   end
      #
      # @example EmptyLineBetweenClassDefs: true (default)
      #   # checks for empty lines between class definitions.
      #
      #   # bad
      #   class A
      #   end
      #   class B
      #   end
      #   def b
      #   end
      #
      # @example
      #
      #   # good
      #   class A
      #   end
      #
      #   class B
      #   end
      #
      #   def b
      #   end
      #
      # @example EmptyLineBetweenModuleDefs: true (default)
      #   # checks for empty lines between module definitions.
      #
      #   # bad
      #   module A
      #   end
      #   module B
      #   end
      #   def b
      #   end
      #
      # @example
      #
      #   # good
      #   module A
      #   end
      #
      #   module B
      #   end
      #
      #   def b
      #   end
      #
      # @example AllowAdjacentOneLineDefs: true
      #
      #   # good
      #   class ErrorA < BaseError; end
      #   class ErrorB < BaseError; end
      #   class ErrorC < BaseError; end
      #
      class EmptyLineBetweenDefs < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use empty lines between %<type>s definitions.'

        def self.autocorrect_incompatible_with
          [Layout::EmptyLines]
        end

        # We operate on `begin` nodes, instead of using `OnMethodDef`,
        # so that we can walk over pairs of consecutive nodes and
        # efficiently access a node's predecessor; #prev_node ends up
        # doing a linear scan over siblings, so we don't want to call
        # it on each def.
        def on_begin(node)
          node.children.each_cons(2) do |prev, n|
            nodes = [prev, n]
            check_defs(nodes) if nodes.all? { |def_candidate| candidate?(def_candidate) }
          end
        end

        def check_defs(nodes)
          return if blank_lines_between?(*nodes)
          return if multiple_blank_lines_groups?(*nodes)
          return if nodes.all?(&:single_line?) &&
                    cop_config['AllowAdjacentOneLineDefs']

          correction_node = nodes.last
          location = correction_node.loc.keyword.join(correction_node.loc.name)
          add_offense(location, message: message(correction_node)) do |corrector|
            autocorrect(corrector, *nodes)
          end
        end

        def autocorrect(corrector, prev_def, node)
          # finds position of first newline
          end_pos = end_loc(prev_def).end_pos
          source_buffer = end_loc(prev_def).source_buffer
          newline_pos = source_buffer.source.index("\n", end_pos)

          # Handle the case when multiple one-liners are on the same line.
          newline_pos = end_pos + 1 if newline_pos > node.source_range.begin_pos

          count = blank_lines_count_between(prev_def, node)

          if count > maximum_empty_lines
            autocorrect_remove_lines(corrector, newline_pos, count)
          else
            autocorrect_insert_lines(corrector, newline_pos, count)
          end
        end

        private

        def candidate?(node)
          return unless node

          method_candidate?(node) || class_candidate?(node) || module_candidate?(node)
        end

        def method_candidate?(node)
          cop_config['EmptyLineBetweenMethodDefs'] && (node.def_type? || node.defs_type?)
        end

        def class_candidate?(node)
          cop_config['EmptyLineBetweenClassDefs'] && node.class_type?
        end

        def module_candidate?(node)
          cop_config['EmptyLineBetweenModuleDefs'] && node.module_type?
        end

        def message(node)
          type = case node.type
                 when :def, :defs
                   :method
                 else
                   node.type
                 end
          format(MSG, type: type)
        end

        def multiple_blank_lines_groups?(first_def_node, second_def_node)
          lines = lines_between_defs(first_def_node, second_def_node)
          blank_start = lines.each_index.select { |i| lines[i].blank? }.max
          non_blank_end = lines.each_index.reject { |i| lines[i].blank? }.min
          return false if blank_start.nil? || non_blank_end.nil?

          blank_start > non_blank_end
        end

        def blank_lines_between?(first_def_node, second_def_node)
          count = blank_lines_count_between(first_def_node, second_def_node)
          (minimum_empty_lines..maximum_empty_lines).cover?(count)
        end

        def blank_lines_count_between(first_def_node, second_def_node)
          lines_between_defs(first_def_node, second_def_node).count(&:blank?)
        end

        def minimum_empty_lines
          Array(cop_config['NumberOfEmptyLines']).first
        end

        def maximum_empty_lines
          Array(cop_config['NumberOfEmptyLines']).last
        end

        def lines_between_defs(first_def_node, second_def_node)
          begin_line_num = def_end(first_def_node)
          end_line_num = def_start(second_def_node) - 2
          return [] if end_line_num.negative?

          processed_source.lines[begin_line_num..end_line_num]
        end

        def def_start(node)
          node.loc.keyword.line
        end

        def def_end(node)
          end_loc(node).line
        end

        def end_loc(node)
          if node.def_type? && node.endless?
            node.loc.expression.end
          else
            node.loc.end
          end
        end

        def autocorrect_remove_lines(corrector, newline_pos, count)
          difference = count - maximum_empty_lines
          range_to_remove = range_between(newline_pos, newline_pos + difference)

          corrector.remove(range_to_remove)
        end

        def autocorrect_insert_lines(corrector, newline_pos, count)
          difference = minimum_empty_lines - count
          where_to_insert = range_between(newline_pos, newline_pos + 1)

          corrector.insert_after(where_to_insert, "\n" * difference)
        end
      end
    end
  end
end
