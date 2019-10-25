# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for braces around the last parameter in a method call
      # if the last parameter is a hash.
      # It supports `braces`, `no_braces` and `context_dependent` styles.
      #
      # @example EnforcedStyle: braces
      #   # The `braces` style enforces braces around all method
      #   # parameters that are hashes.
      #
      #   # bad
      #   some_method(x, y, a: 1, b: 2)
      #
      #   # good
      #   some_method(x, y, {a: 1, b: 2})
      #
      # @example EnforcedStyle: no_braces (default)
      #   # The `no_braces` style checks that the last parameter doesn't
      #   # have braces around it.
      #
      #   # bad
      #   some_method(x, y, {a: 1, b: 2})
      #
      #   # good
      #   some_method(x, y, a: 1, b: 2)
      #
      # @example EnforcedStyle: context_dependent
      #   # The `context_dependent` style checks that the last parameter
      #   # doesn't have braces around it, but requires braces if the
      #   # second to last parameter is also a hash literal.
      #
      #   # bad
      #   some_method(x, y, {a: 1, b: 2})
      #   some_method(x, y, {a: 1, b: 2}, a: 1, b: 2)
      #
      #   # good
      #   some_method(x, y, a: 1, b: 2)
      #   some_method(x, y, {a: 1, b: 2}, {a: 1, b: 2})
      class BracesAroundHashParameters < Cop
        include ConfigurableEnforcedStyle
        include RangeHelp

        MSG = '%<type>s curly braces around a hash parameter.'

        def on_send(node)
          return if node.assignment_method? || node.operator_method?

          return unless node.arguments? && node.last_argument.hash_type? &&
                        !node.last_argument.empty?

          check(node.last_argument, node.arguments)
        end
        alias on_csend on_send

        def autocorrect(send_node)
          hash_node = send_node.last_argument

          lambda do |corrector|
            if hash_node.braces?
              remove_braces_with_whitespace(corrector,
                                            hash_node,
                                            extra_space(hash_node))
            else
              add_braces(corrector, hash_node)
            end
          end
        end

        private

        def check(arg, args)
          case style
          when :braces
            check_braces(arg)
          when :no_braces
            check_no_braces(arg)
          when :context_dependent
            check_context_dependent(arg, args)
          end
        end

        def check_braces(arg)
          add_arg_offense(arg, :missing) unless arg.braces?
        end

        def check_no_braces(arg)
          return unless arg.braces? && !braces_needed_for_semantics?(arg)

          add_arg_offense(arg, :redundant)
        end

        def check_context_dependent(arg, args)
          braces_around_second_from_end = args.size > 1 && args[-2].hash_type?

          if arg.braces?
            unless braces_around_second_from_end ||
                   braces_needed_for_semantics?(arg)
              add_arg_offense(arg, :redundant)
            end
          elsif braces_around_second_from_end
            add_arg_offense(arg, :missing)
          end
        end

        # Returns true if there's block inside the braces of the given hash arg
        # and that block uses do..end. The reason for wanting to check this is
        # that the do..end could bind to a different method invocation if the
        # hash braces were removed.
        def braces_needed_for_semantics?(arg)
          arg.each_pair do |_key, value|
            return true if value.block_type? && !value.braces?
          end
          false
        end

        def add_arg_offense(arg, type)
          add_offense(arg.parent, location: arg.source_range,
                                  message: format(MSG,
                                                  type: type.to_s.capitalize))
        end

        def extra_space(hash_node)
          {
            newlines: extra_left_space?(hash_node) &&
              extra_right_space?(hash_node),
            left: extra_left_space?(hash_node),
            right: extra_right_space?(hash_node)
          }
        end

        def extra_left_space?(hash_node)
          @extra_left_space ||= begin
            top_line = hash_node.source_range.source_line
            top_line.delete(' ') == '{'
          end
        end

        def extra_right_space?(hash_node)
          @extra_right_space ||= begin
            bottom_line_number = hash_node.source_range.last_line
            bottom_line = processed_source.lines[bottom_line_number - 1]
            bottom_line.delete(' ') == '}'
          end
        end

        def remove_braces_with_whitespace(corrector, node, space)
          loc = node.loc

          if node.multiline?
            remove_braces_with_range(corrector,
                                     left_whole_line_range(loc.begin),
                                     right_whole_line_range(loc.end))
          else
            remove_braces_with_range(corrector,
                                     left_brace_and_space(loc.begin, space),
                                     right_brace_and_space(loc.end, space))
          end
        end

        def remove_braces_with_range(corrector, left_range, right_range)
          corrector.remove(left_range)
          corrector.remove(right_range)
        end

        def left_whole_line_range(loc_begin)
          if range_by_whole_lines(loc_begin).source.strip == '{'
            range_by_whole_lines(loc_begin, include_final_newline: true)
          else
            loc_begin
          end
        end

        def right_whole_line_range(loc_end)
          if range_by_whole_lines(loc_end).source.strip =~ /\A}\s*,?\z/
            range_by_whole_lines(loc_end, include_final_newline: true)
          else
            loc_end
          end
        end

        def left_brace_and_space(loc_begin, space)
          range_with_surrounding_space(range: loc_begin,
                                       side: :right,
                                       newlines: space[:newlines],
                                       whitespace: space[:left])
        end

        def right_brace_and_space(loc_end, space)
          brace_and_space =
            range_with_surrounding_space(
              range: loc_end,
              side: :left,
              newlines: space[:newlines],
              whitespace: space[:right]
            )
          range_with_surrounding_comma(brace_and_space, :left)
        end

        def add_braces(corrector, node)
          corrector.insert_before(node.source_range, '{')
          corrector.insert_after(node.source_range, '}')
        end
      end
    end
  end
end
