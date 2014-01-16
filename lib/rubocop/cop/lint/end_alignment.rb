# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks whether the end keywords are aligned properly.
      #
      # Two modes are supported through the AlignWith configuration
      # parameter. If it's set to `keyword` (which is the default), the `end`
      # shall be aligned with the start of the keyword (if, def, etc.). If it's
      # set to `variable` the `end` shall be aligned with the left-hand-side of
      # the variable assignment, if there is one.
      #
      # @example
      #
      #   variable = if true
      #              end
      class EndAlignment < Cop
        include CheckMethods
        include CheckAssignment
        include ConfigurableEnforcedStyle

        MSG = 'end at %d, %d is not aligned with %s at %d, %d'

        def on_class(node)
          check(node)
        end

        def on_module(node)
          check(node)
        end

        def on_if(node)
          check(node) if node.loc.respond_to?(:end)
        end

        def on_while(node)
          check(node)
        end

        def on_until(node)
          check(node)
        end

        def on_send(node)
          receiver, method_name, *args = *node
          if visibility_and_def_on_same_line?(receiver, method_name, args)
            expr = node.loc.expression
            method_def = args.first
            range = Parser::Source::Range.new(expr.source_buffer,
                                              expr.begin_pos,
                                              method_def.loc.keyword.end_pos)
            check_offset(method_def, range.source,
                         method_def.loc.keyword.begin_pos - expr.begin_pos)
            ignore_node(method_def) # Don't check the same `end` again.
          end
        end

        private

        # Returns true for constructs such as
        # private def my_method
        # which are allowed in Ruby 2.1 and later.
        def visibility_and_def_on_same_line?(receiver, method_name, args)
          !receiver &&
            [:public, :protected, :private,
             :module_function].include?(method_name) &&
            args.size == 1 && [:def, :defs].include?(args.first.type)
        end

        def check_assignment(node, rhs)
          # If there are method calls chained to the right hand side of the
          # assignment, we let rhs be the receiver of those method calls before
          # we check if it's an if/unless/while/until.
          rhs = first_part_of_call_chain(rhs)

          return unless rhs

          case rhs.type
          when :if, :while, :until
            return if rhs.loc.respond_to?(:question) # ternary

            offset = if style == :variable
                       rhs.loc.keyword.column - node.loc.expression.column
                     else
                       0
                     end
            expr = node.loc.expression
            range = Parser::Source::Range.new(expr.source_buffer,
                                              expr.begin_pos,
                                              rhs.loc.keyword.end_pos)
            check_offset(rhs, range.source, offset)
            ignore_node(rhs) # Don't check again.
          end
        end

        def check(node, *_)
          check_offset(node, node.loc.keyword.source, 0)
        end

        def check_offset(node, alignment_base, offset)
          return if ignored_node?(node)

          end_loc = node.loc.end
          return unless end_loc # Discard modifier forms of if/while/until.

          kw_loc = node.loc.keyword

          if kw_loc.line != end_loc.line &&
              kw_loc.column != end_loc.column + offset
            add_offence(nil, end_loc,
                        sprintf(MSG, end_loc.line, end_loc.column,
                                alignment_base, kw_loc.line, kw_loc.column)) do
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end

        def parameter_name
          'AlignWith'
        end
      end
    end
  end
end
