# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for braces around the last parameter in a method call
      # if the last parameter is a hash.
      # It supports 3 styles:
      #
      # * The `braces` style enforces braces around all method
      # parameters that are hashes.
      #
      # @example
      #   # bad
      #   some_method(x, y, a: 1, b: 2)
      #
      #   # good
      #   some_method(x, y, {a: 1, b: 2})
      #
      # * The `no_braces` style checks that the last parameter doesn't
      # have braces around it.
      #
      # @example
      #   # bad
      #   some_method(x, y, {a: 1, b: 2})
      #
      #   # good
      #   some_method(x, y, a: 1, b: 2)
      #
      # * The `context_dependent` style checks that the last parameter
      # doesn't have braces around it, but requires braces if the
      # second to last parameter is also a hash literal.
      #
      # @example
      #   # bad
      #   some_method(x, y, {a: 1, b: 2})
      #   some_method(x, y, {a: 1, b: 2}, a: 1, b: 2)
      #
      #   # good
      #   some_method(x, y, a: 1, b: 2)
      #   some_method(x, y, {a: 1, b: 2}, {a: 1, b: 2})
      class BracesAroundHashParameters < Cop
        include ConfigurableEnforcedStyle

        MSG = '%s curly braces around a hash parameter.'.freeze

        def on_send(node)
          return if node.assignment_method? || node.operator_method?

          return unless node.arguments? && node.last_argument.hash_type? &&
                        !node.last_argument.empty?

          check(node.last_argument, node.arguments)
        end

        private

        def check(arg, args)
          if style == :braces && !arg.braces?
            add_arg_offense(arg, :missing)
          elsif style == :no_braces && arg.braces?
            add_arg_offense(arg, :redundant)
          elsif style == :context_dependent
            check_context_dependent(arg, args)
          end
        end

        def check_context_dependent(arg, args)
          braces_around_second_from_end = args.size > 1 && args[-2].hash_type?

          if arg.braces?
            unless braces_around_second_from_end
              add_arg_offense(arg, :redundant)
            end
          elsif braces_around_second_from_end
            add_arg_offense(arg, :missing)
          end
        end

        def add_arg_offense(arg, type)
          add_offense(arg.parent, arg.source_range,
                      format(MSG, type.to_s.capitalize))
        end

        # We let AutocorrectUnlessChangingAST#autocorrect work with the send
        # node, because that context is needed. When parsing the code to see if
        # the AST has changed, a braceless hash would not be parsed as a hash
        # otherwise.
        def autocorrect(send_node)
          hash_node = send_node.last_argument

          lambda do |corrector|
            if hash_node.braces?
              remove_braces_with_whitespace(corrector, hash_node)
            else
              add_braces(corrector, hash_node)
            end
          end
        end

        def remove_braces_with_whitespace(corrector, node)
          right_brace_and_space = right_brace_and_space(node.loc.end)

          if comment_on_line?(right_brace_and_space.line)
            # Removing a line break between a comment and the closing
            # parenthesis would cause a syntax error, so we only remove the
            # braces in that case.
            remove_braces(corrector, node)
          else
            left_brace_and_space = range_with_surrounding_space(node.loc.begin,
                                                                :right)
            corrector.remove(left_brace_and_space)
            corrector.remove(right_brace_and_space)
          end
        end

        def right_brace_and_space(loc_end)
          brace_and_space = range_with_surrounding_space(loc_end, :left)
          range_with_surrounding_comma(brace_and_space, :left)
        end

        def comment_on_line?(line)
          processed_source.comments.any? { |c| c.loc.line == line }
        end

        def remove_braces(corrector, node)
          corrector.remove(node.loc.begin)
          corrector.remove(node.loc.end)
        end

        def add_braces(corrector, node)
          corrector.insert_before(node.source_range, '{')
          corrector.insert_after(node.source_range, '}')
        end
      end
    end
  end
end
