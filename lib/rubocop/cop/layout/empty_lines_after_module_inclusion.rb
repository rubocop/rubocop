# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for an empty line after a module inclusion method (`extend`,
      # `include` and `prepend`), or a group of them.
      #
      # @example
      #   # bad
      #   class Foo
      #     include Bar
      #     attr_reader :baz
      #   end
      #
      #   # good
      #   class Foo
      #     include Bar
      #
      #     attr_reader :baz
      #   end
      #
      #   # also good - multiple module inclusions grouped together
      #   class Foo
      #     extend Bar
      #     include Baz
      #     prepend Qux
      #   end
      #
      class EmptyLinesAfterModuleInclusion < Base
        extend AutoCorrector

        MSG = 'Add an empty line after module inclusion.'

        MODULE_INCLUSION_METHODS = %i[include extend prepend].freeze

        RESTRICT_ON_SEND = MODULE_INCLUSION_METHODS

        def on_send(node)
          return if node.receiver || node.arguments.empty?
          return if node.parent&.type?(:send, :any_block, :array)

          last_line = last_line_with_heredocs(node)
          return if next_line_empty_or_enable_directive_comment?(last_line)

          next_line_node = next_line_node(node)
          return unless require_empty_line?(next_line_node)

          add_offense(node) { |corrector| autocorrect(corrector, last_line) }
        end

        private

        def last_line_with_heredocs(node)
          heredoc_end_lines = processed_source.ast.each_node(:any_str).filter_map do |str|
            str.loc.heredoc_end.line if str.heredoc? && str.first_line == node.last_line
          end

          [node.last_line, *heredoc_end_lines].max
        end

        def autocorrect(corrector, last_line)
          node_range = processed_source.buffer.line_range(last_line)

          next_line = last_line + 1
          if enable_directive_comment?(next_line)
            node_range = processed_source.comment_at_line(next_line)
          end

          corrector.insert_after(node_range, "\n")
        end

        def next_line_empty_or_enable_directive_comment?(line)
          line_empty?(line) || (enable_directive_comment?(line + 1) && line_empty?(line + 1))
        end

        def enable_directive_comment?(line)
          return false unless (comment = processed_source.comment_at_line(line))

          DirectiveComment.new(comment).enabled?
        end

        def line_empty?(line)
          processed_source[line].nil? || processed_source[line].blank?
        end

        def require_empty_line?(node)
          return false unless node

          !allowed_method?(node)
        end

        def allowed_method?(node)
          node = node.body if node.respond_to?(:modifier_form?) && node.modifier_form?

          return false unless node.send_type?

          MODULE_INCLUSION_METHODS.include?(node.method_name)
        end

        def next_line_node(node)
          return if node.parent.type?(:if, :rescue, :ensure, :and, :or)

          node.right_sibling
        end
      end
    end
  end
end
