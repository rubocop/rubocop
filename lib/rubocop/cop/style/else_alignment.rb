# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks the alignment of else keywords. Normally they should
      # be aligned with an if/unless/while/until/begin/def keyword, but there
      # are special cases when they should follow the same rules as the
      # alignment of end.
      class ElseAlignment < Cop
        include AutocorrectAlignment
        include CheckAssignment

        MSG = 'Align `%s` with `%s`.'

        def on_if(node, base = nil)
          return if ignored_node?(node)
          return unless node.loc.respond_to?(:else)
          return if node.loc.else.nil?

          else_range = node.loc.else
          return unless begins_its_line?(else_range)

          base_range = if base
                         base.loc.expression
                       else
                         base = node
                         until %w(if unless).include?(base.loc.keyword.source)
                           base = base.parent
                         end
                         base.loc.keyword
                       end

          check_alignment(base_range, else_range)
        end

        def on_rescue(node)
          return unless node.loc.else

          parent = node.parent
          base = case parent.type
                 when :def, :defs then base_for_method_definition(parent)
                 when :kwbegin    then parent.loc.begin
                 when :ensure     then parent.parent.loc.begin
                 else node.loc.keyword
                 end
          check_alignment(base, node.loc.else)
        end

        def on_case(node)
          _cond, *whens, _else = *node
          return unless node.loc.else
          check_alignment(whens.last.loc.keyword, node.loc.else)
        end

        private

        def base_for_method_definition(node)
          parent = node.parent
          if parent && parent.type == :send
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
          style = end_config['Enabled'] ? end_config['AlignWith'] : 'keyword'
          base = style == 'variable' ? node : rhs

          return if rhs.type != :if

          on_if(rhs, base)
          ignore_node(rhs)
        end

        def check_alignment(base_loc, else_range)
          return unless begins_its_line?(else_range)

          @column_delta = base_loc.column - else_range.column
          return if @column_delta == 0

          add_offense(else_range, else_range,
                      format(MSG, else_range.source, base_loc.source[/^\S*/]))
        end
      end
    end
  end
end
