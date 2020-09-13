# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for single-line method definitions that contain a body.
      # It will accept single-line methods with no body.
      #
      # @example
      #   # bad
      #   def some_method; body end
      #   def link_to(url); {:name => url}; end
      #   def @table.columns; super; end
      #
      #   # good
      #   def self.resource_class=(klass); end
      #   def @table.columns; end
      #
      # @example AllowIfMethodIsEmpty: true (default)
      #   # good
      #   def no_op; end
      #
      # @example AllowIfMethodIsEmpty: false
      #   # bad
      #   def no_op; end
      #
      class SingleLineMethods < Base
        include Alignment
        extend AutoCorrector

        MSG = 'Avoid single-line method definitions.'

        def on_def(node)
          return unless node.single_line?
          return if allow_empty? && !node.body

          add_offense(node) do |corrector|
            autocorrect(corrector, node)
          end
        end
        alias on_defs on_def

        private

        def autocorrect(corrector, node)
          each_part(node.body) do |part|
            LineBreakCorrector.break_line_before(
              range: part, node: node, corrector: corrector,
              configured_width: configured_indentation_width
            )
          end

          LineBreakCorrector.break_line_before(
            range: node.loc.end, node: node, corrector: corrector,
            indent_steps: 0, configured_width: configured_indentation_width
          )

          move_comment(node, corrector)
        end

        def allow_empty?
          cop_config['AllowIfMethodIsEmpty']
        end

        def each_part(body)
          return unless body

          if body.begin_type?
            body.each_child_node { |part| yield part.source_range }
          else
            yield body.source_range
          end
        end

        def move_comment(node, corrector)
          LineBreakCorrector.move_comment(
            eol_comment: processed_source.comment_at_line(node.source_range.line),
            node: node, corrector: corrector
          )
        end
      end
    end
  end
end
