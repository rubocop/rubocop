# encoding: utf-8
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
      class IndentationWidth < Cop # rubocop:disable Metrics/ClassLength
        include EndKeywordAlignment
        include AutocorrectAlignment
        include OnMethodDef
        include CheckAssignment
        include IfNode
        include AccessModifierNode

        def on_rescue(node)
          _begin_node, *rescue_nodes, else_node = *node
          rescue_nodes.each do |rescue_node|
            _, _, body = *rescue_node
            check_indentation(rescue_node.loc.keyword, body)
          end
          check_indentation(node.loc.else, else_node)
        end

        def on_ensure(node)
          _body, ensure_body = *node
          check_indentation(node.loc.keyword, ensure_body)
        end

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
          check_indentation(loc.end, body) if begins_its_line?(loc.end)
        end

        def on_module(node)
          _module_name, *members = *node
          check_members(node, members)
        end

        def on_class(node)
          _class_name, _base_class, *members = *node
          check_members(node, members)
        end

        def check_members(node, members)
          check_indentation(node.loc.keyword, members.first)

          return unless members.any? && members.first.begin_type?
          style =
            config.for_cop('Style/IndentationConsistency')['EnforcedStyle']
          return unless style == 'rails'

          special = %w(protected private) # Extra indentation step after these.
          previous_modifier = nil
          members.first.children.each do |m|
            if modifier_node?(m) && special.include?(m.source)
              previous_modifier = m
            elsif previous_modifier
              check_indentation(previous_modifier.source_range, m, style)
              previous_modifier = nil
            end
          end
        end

        def on_send(node)
          super
          return unless modifier_and_def_on_same_line?(node)
          _, _, *args = *node

          *_, body = *args.first

          def_end_config = config.for_cop('Lint/DefEndAlignment')
          style = def_end_config['AlignWith'] || 'start_of_line'
          base = style == 'def' ? args.first : node

          check_indentation(base.source_range, body)
          ignore_node(args.first)
        end

        def on_method_def(node, _method_name, _args, body)
          check_indentation(node.loc.keyword, body) unless ignored_node?(node)
        end

        def on_for(node)
          _variable, _collection, body = *node
          check_indentation(node.loc.keyword, body)
        end

        def on_while(node, base = node)
          return if ignored_node?(node)

          _condition, body = *node
          return unless node.loc.keyword.begin_pos ==
                        node.source_range.begin_pos

          check_indentation(base.loc, body)
        end

        alias on_until on_while

        def on_case(node)
          _condition, *branches = *node
          latest_when = nil
          branches.compact.each do |b|
            if b.when_type?
              # TODO: Revert to the original expression once the fix in Rubinius
              #   is released.
              #
              # Originally this expression was:
              #
              #   *_conditions, body = *b
              #
              # However it fails on Rubinius 2.2.9 due to its bug:
              #
              #   RuntimeError:
              #     can't modify frozen instance of Array
              #   # kernel/common/array.rb:988:in `pop'
              #   # ./lib/rubocop/cop/style/indentation_width.rb:99:in `on_case'
              #
              # It seems to be fixed on the current master (0a92c3c).
              body = b.children.last

              # Check "when" body against "when" keyword indentation.
              check_indentation(b.loc.keyword, body)
              latest_when = b
            else
              # Since it's not easy to get the position of the "else" keyword,
              # we check "else" body against latest "when" keyword indentation.
              check_indentation(latest_when.loc.keyword, b)
            end
          end
        end

        def on_if(node, base = node)
          return if ignored_node?(node)
          return if ternary?(node)
          return if modifier_if?(node)

          _condition, body, else_clause = if_node_parts(node)

          check_if(node, body, else_clause, base.loc) if body
        end

        private

        def check_assignment(node, rhs)
          # If there are method calls chained to the right hand side of the
          # assignment, we let rhs be the receiver of those method calls before
          # we check its indentation.
          rhs = first_part_of_call_chain(rhs)
          return unless rhs

          end_config = config.for_cop('Lint/EndAlignment')
          style = end_config['AlignWith'] || 'keyword'
          base = variable_alignment?(node.loc, rhs, style.to_sym) ? node : rhs

          case rhs.type
          when :if            then on_if(rhs, base)
          when :while, :until then on_while(rhs, base)
          else                     return
          end

          ignore_node(rhs)
        end

        def check_if(node, body, else_clause, base_loc)
          return if ternary?(node)

          check_indentation(base_loc, body)
          return unless else_clause

          # If the else clause is an elsif, it will get its own on_if call so
          # we don't need to process it here.
          return if elsif?(else_clause)

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
          Parser::Source::Range.new(expr.source_buffer, pos.begin, pos.end)
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
