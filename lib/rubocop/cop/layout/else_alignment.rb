# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cops checks the alignment of else keywords. Normally they should
      # be aligned with an if/unless/while/until/begin/def keyword, but there
      # are special cases when they should follow the same rules as the
      # alignment of end.
      #
      # @example
      #   # bad
      #   if something
      #     code
      #  else
      #     code
      #   end
      #
      #   # bad
      #   if something
      #     code
      #  elsif something
      #     code
      #   end
      #
      #   # good
      #   if something
      #     code
      #   else
      #     code
      #   end
      class ElseAlignment < Cop
        include EndKeywordAlignment
        include AutocorrectAlignment
        include CheckAssignment

        MSG = 'Align `%s` with `%s`.'.freeze

        def on_if(node, base = nil)
          return if ignored_node?(node)
          return unless node.else? && begins_its_line?(node.loc.else)

          check_alignment(base_range(node, base), node.loc.else)

          return unless node.elsif_conditional?

          check_nested(node.else_branch, base)
        end

        def on_rescue(node)
          return unless node.loc.respond_to?(:else) && node.loc.else

          parent = node.parent
          parent = parent.parent if parent.ensure_type?
          base = case parent.type
                 when :def, :defs then base_for_method_definition(parent)
                 when :kwbegin then parent.loc.begin
                 else node.loc.keyword
                 end
          check_alignment(base, node.loc.else)
        end

        def on_case(node)
          return unless node.else?

          check_alignment(node.when_branches.last.loc.keyword, node.loc.else)
        end

        private

        def check_nested(node, base)
          on_if(node, base)
          ignore_node(node)
        end

        def base_range(node, base)
          if base
            base.source_range
          else
            lineage = [node, *node.each_ancestor(:if)]
            lineage.find { |parent| parent.if? || parent.unless? }.loc.keyword
          end
        end

        def base_for_method_definition(node)
          parent = node.parent
          if parent && parent.send_type?
            parent.loc.selector # For example "private def ..."
          else
            node.loc.keyword
          end
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

          return unless rhs.if_type?

          check_nested(rhs, base)
        end

        def check_alignment(base_range, else_range)
          return unless begins_its_line?(else_range)

          @column_delta = effective_column(base_range) - else_range.column
          return if @column_delta.zero?

          add_offense(else_range, else_range,
                      format(MSG, else_range.source, base_range.source[/^\S*/]))
        end
      end
    end
  end
end
