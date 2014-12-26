# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for braces around the last parameter in a method call
      # if the last parameter is a hash.
      class BracesAroundHashParameters < Cop
        include ConfigurableEnforcedStyle

        MSG = '%s curly braces around a hash parameter.'

        def on_send(node)
          _receiver, method_name, *args = *node

          # Discard attr writer methods.
          return if method_name.to_s.end_with?('=')
          # Discard operator methods.
          return if operator?(method_name)

          # We care only for the last argument.
          arg = args.last

          check(arg, args) if non_empty_hash?(arg)
        end

        private

        def check(arg, args)
          if style == :braces && !braces?(arg)
            add_offense(arg, :expression, format(MSG, 'Missing'))
          elsif style == :no_braces && braces?(arg)
            add_offense(arg, :expression, format(MSG, 'Redundant'))
          elsif style == :context_dependent
            check_context_dependent(arg, args)
          end
        end

        def check_context_dependent(arg, args)
          braces_around_2nd_from_end = args.length > 1 && args[-2].type == :hash
          if braces?(arg)
            unless braces_around_2nd_from_end
              add_offense(arg, :expression, format(MSG, 'Redundant'))
            end
          elsif braces_around_2nd_from_end
            add_offense(arg, :expression, format(MSG, 'Missing'))
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            if braces?(node)
              right_range = range_with_surrounding_space(node.loc.begin, :right)
              corrector.remove(right_range)
              left_range = range_with_surrounding_space(node.loc.end, :left)
              corrector.remove(left_range)
            else
              corrector.insert_before(node.loc.expression, '{')
              corrector.insert_after(node.loc.expression, '}')
            end
          end
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
