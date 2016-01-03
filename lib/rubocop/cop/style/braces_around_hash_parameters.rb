# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for braces around the last parameter in a method call
      # if the last parameter is a hash.
      class BracesAroundHashParameters < Cop
        include ConfigurableEnforcedStyle
        include AutocorrectUnlessChangingAST

        MSG = '%s curly braces around a hash parameter.'.freeze

        def on_send(node)
          _receiver, method_name, *args = *node

          # Discard attr writer methods.
          return if node.asgn_method_call?
          # Discard operator methods.
          return if operator?(method_name)

          # We care only for the last argument.
          arg = args.last

          check(arg, args) if non_empty_hash?(arg)
        end

        private

        def check(arg, args)
          if style == :braces && !braces?(arg)
            add_offense(arg.parent, arg.source_range, format(MSG, 'Missing'))
          elsif style == :no_braces && braces?(arg)
            add_offense(arg.parent, arg.source_range,
                        format(MSG, 'Redundant'))
          elsif style == :context_dependent
            check_context_dependent(arg, args)
          end
        end

        def check_context_dependent(arg, args)
          braces_around_2nd_from_end = args.length > 1 && args[-2].type == :hash
          if braces?(arg)
            unless braces_around_2nd_from_end
              add_offense(arg.parent, arg.source_range,
                          format(MSG, 'Redundant'))
            end
          elsif braces_around_2nd_from_end
            add_offense(arg.parent, arg.source_range, format(MSG, 'Missing'))
          end
        end

        # We let AutocorrectUnlessChangingAST#autocorrect work with the send
        # node, because that context is needed. When parsing the code to see if
        # the AST has changed, a braceless hash would not be parsed as a hash
        # otherwise.
        def correction(send_node)
          _receiver, _method_name, *args = *send_node
          node = args.last
          lambda do |corrector|
            if braces?(node)
              remove_braces(corrector, node)
            else
              add_braces(corrector, node)
            end
          end
        end

        def remove_braces(corrector, node)
          comments = processed_source.comments
          right_brace_and_space = range_with_surrounding_space(node.loc.end,
                                                               :left)
          if comments.any? { |c| c.loc.line == right_brace_and_space.line }
            # Removing a line break between a comment and the closing
            # parenthesis would cause a syntax error, so we only remove the
            # braces in that case.
            corrector.remove(node.loc.begin)
            corrector.remove(node.loc.end)
          else
            left_brace_and_space = range_with_surrounding_space(node.loc.begin,
                                                                :right)
            corrector.remove(left_brace_and_space)
            corrector.remove(right_brace_and_space)
          end
        end

        def add_braces(corrector, node)
          corrector.insert_before(node.source_range, '{')
          corrector.insert_after(node.source_range, '}')
        end

        def non_empty_hash?(arg)
          arg && arg.type == :hash && arg.children.any?
        end

        def braces?(arg)
          arg.loc.begin
        end
      end
    end
  end
end
