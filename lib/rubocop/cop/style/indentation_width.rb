# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks for indentation that doesn't use two spaces.
      #
      # @example
      #
      #   class A
      #    def test
      #     puts 'hello'
      #    end
      #   end
      class IndentationWidth < Cop
        include EndKeywordAlignment
        include AutocorrectAlignment
        include OnMethodDef
        include CheckAssignment
        include AccessModifierNode

        SPECIAL_MODIFIERS = %w(private protected).freeze

        def on_rescue(node)
          _begin_node, *_rescue_nodes, else_node = *node
          check_indentation(node.loc.else, else_node)
        end

        def on_ensure(node)
          ensure_body = node.children.last
          check_indentation(node.loc.keyword, ensure_body)
        end

        alias on_resbody on_ensure
        alias on_for     on_ensure

        def on_kwbegin(node)
          # Check indentation against end keyword but only if it's first on its
          # line.
          return unless begins_its_line?(node.loc.end)
          check_indentation(node.loc.end, node.children.first)
        end

        def on_block(node)
          _method, _args, body = *node
          # Check body against end/} indentation. Checking against variable
          # assignments, etc, would be more difficult. The end/} must be at the
          # beginning of its line.
          loc = node.loc
          return unless begins_its_line?(loc.end)

          check_indentation(loc.end, body)
          return unless indentation_consistency_style == 'rails'

          check_members(loc.end, [body])
        end

        def on_module(node)
          _module_name, *members = *node
          check_members(node.loc.keyword, members)
        end

        def on_class(node)
          _class_name, _base_class, *members = *node
          check_members(node.loc.keyword, members)
        end

        def on_send(node)
          super
          return unless modifier_and_def_on_same_line?(node)

          *_, body = *node.first_argument

          def_end_config = config.for_cop('Lint/DefEndAlignment')
          style = def_end_config['EnforcedStyleAlignWith'] || 'start_of_line'
          base = style == 'def' ? node.first_argument : node

          check_indentation(base.source_range, body)
          ignore_node(node.first_argument)
        end

        def on_method_def(node, _method_name, _args, body)
          check_indentation(node.loc.keyword, body) unless ignored_node?(node)
        end

        def on_while(node, base = node)
          return if ignored_node?(node)

          return unless node.single_line_condition?

          check_indentation(base.loc, node.body)
        end

        alias on_until on_while

        def on_case(case_node)
          case_node.each_when do |when_node|
            check_indentation(when_node.loc.keyword, when_node.body)
          end

          check_indentation(case_node.when_branches.last.loc.keyword,
                            case_node.else_branch)
        end

        def on_if(node, base = node)
          return if ignored_node?(node) || !node.body
          return if node.ternary? || node.modifier_form?

          check_if(node, node.body, node.else_branch, base.loc)
        end

        private

        def check_members(base, members)
          check_indentation(base, members.first)

          return unless members.any? && members.first.begin_type?
          return unless indentation_consistency_style == 'rails'

          each_member(members) do |member, previous_modifier|
            check_indentation(previous_modifier, member,
                              indentation_consistency_style)
          end
        end

        def each_member(members)
          previous_modifier = nil
          members.first.children.each do |member|
            if special_modifier?(member)
              previous_modifier = member
            elsif previous_modifier
              yield member, previous_modifier.source_range
              previous_modifier = nil
            end
          end
        end

        def special_modifier?(node)
          modifier_node?(node) && SPECIAL_MODIFIERS.include?(node.source)
        end

        def indentation_consistency_style
          config.for_cop('Style/IndentationConsistency')['EnforcedStyle']
        end

        def check_assignment(node, rhs)
          # If there are method calls chained to the right hand side of the
          # assignment, we let rhs be the receiver of those method calls before
          # we check its indentation.
          rhs = first_part_of_call_chain(rhs)
          return unless rhs

          end_config = config.for_cop('Lint/EndAlignment')
          style = end_config['EnforcedStyleAlignWith'] || 'keyword'
          base = variable_alignment?(node.loc, rhs, style.to_sym) ? node : rhs

          case rhs.type
          when :if            then on_if(rhs, base)
          when :while, :until then on_while(rhs, base)
          else                     return
          end

          ignore_node(rhs)
        end

        def check_if(node, body, else_clause, base_loc)
          return if node.ternary?

          check_indentation(base_loc, body)
          return unless else_clause

          # If the else clause is an elsif, it will get its own on_if call so
          # we don't need to process it here.
          return if else_clause.if_type? && else_clause.elsif?

          check_indentation(node.loc.else, else_clause)
        end

        def check_indentation(base_loc, body_node, style = 'normal')
          return unless indentation_to_check?(base_loc, body_node)

          indentation = body_node.loc.column - effective_column(base_loc)
          @column_delta = configured_indentation_width - indentation
          return if @column_delta.zero?

          offense(body_node, indentation, style)
        end

        def offense(body_node, indentation, style)
          # This cop only auto-corrects the first statement in a def body, for
          # example.
          if body_node.begin_type? && !parentheses?(body_node)
            body_node = body_node.children.first
          end

          # Since autocorrect changes a number of lines, and not only the line
          # where the reported offending range is, we avoid auto-correction if
          # this cop has already found other offenses is the same
          # range. Otherwise, two corrections can interfere with each other,
          # resulting in corrupted code.
          node = if autocorrect? && other_offense_in_same_range?(body_node)
                   nil
                 else
                   body_node
                 end

          indentation_name = style == 'normal' ? '' : "#{style} "
          add_offense(node, offending_range(body_node, indentation),
                      format("Use #{configured_indentation_width} (not %d) " \
                             "spaces for #{indentation_name}indentation.",
                             indentation))
        end

        # Returns true if the given node is within another node that has
        # already been marked for auto-correction by this cop.
        def other_offense_in_same_range?(node)
          expr = node.source_range
          @offense_ranges ||= []

          return true if @offense_ranges.any? { |r| within?(expr, r) }

          @offense_ranges << expr
          false
        end

        def indentation_to_check?(base_loc, body_node)
          return false unless body_node

          # Don't check if expression is on same line as "then" keyword, etc.
          return false if body_node.loc.line == base_loc.line

          return false if starts_with_access_modifier?(body_node)

          # Don't check indentation if the line doesn't start with the body.
          # For example, lines like "else do_something".
          first_char_pos_on_line = body_node.source_range.source_line =~ /\S/
          return false unless body_node.loc.column == first_char_pos_on_line

          if [:rescue, :ensure].include?(body_node.type)
            block_body, = *body_node
            return unless block_body
          end

          true
        end

        def offending_range(body_node, indentation)
          expr = body_node.source_range
          begin_pos = expr.begin_pos
          ind = expr.begin_pos - indentation
          pos = indentation >= 0 ? ind..begin_pos : begin_pos..ind
          range_between(pos.begin, pos.end)
        end

        def starts_with_access_modifier?(body_node)
          body_node.begin_type? && modifier_node?(body_node.children.first)
        end

        def configured_indentation_width
          cop_config['Width']
        end
      end
    end
  end
end
