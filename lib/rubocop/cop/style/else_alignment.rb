# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks the alignment of else keywords. Normally they should
      # be aligned with an if/unless/while/until/begin/def keyword, but there
      # are special cases when they should follow the same rules as the
      # alignment of end.
      class ElseAlignment < Cop
        include EndKeywordAlignment
        include AutocorrectAlignment
        include CheckAssignment

        MSG = 'Align `%s` with `%s`.'.freeze

        def on_if(node, base = nil)
          return if ignored_node?(node)
          return unless node.loc.respond_to?(:else)
          return if node.loc.else.nil?

          else_range = node.loc.else
          return unless begins_its_line?(else_range)

          check_alignment(base_range(node, base), else_range)

          return if else_range.source != 'elsif'

          # If the `else` part is actually an `elsif`, we check the `elsif`
          # node in case it contains an `else` within, because that `else`
          # should have the same alignment (base).
          _condition, _if_body, else_body = *node
          on_if(else_body, base)
          # The `elsif` node will get an `on_if` call from the framework later,
          # but we're done here, so we set it to ignored.
          ignore_node(else_body)
        end

        def on_rescue(node)
          return unless node.loc.else

          parent = node.parent
          parent = parent.parent if parent.type == :ensure
          base = case parent.type
                 when :def, :defs then base_for_method_definition(parent)
                 when :kwbegin then parent.loc.begin
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

        def base_range(node, base)
          if base
            base.source_range
          else
            base = node
            until %w(if unless).include?(base.loc.keyword.source)
              base = base.parent
            end
            base.loc.keyword
          end
        end

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
          base = variable_alignment?(node.loc, rhs, style.to_sym) ? node : rhs

          return if rhs.type != :if

          on_if(rhs, base)
          ignore_node(rhs)
        end

        def check_alignment(base_range, else_range)
          return unless begins_its_line?(else_range)

          @column_delta = effective_column(base_range) - else_range.column
          return if @column_delta == 0

          add_offense(else_range, else_range,
                      format(MSG, else_range.source, base_range.source[/^\S*/]))
        end
      end
    end
  end
end
