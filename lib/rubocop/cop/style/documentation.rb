# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for missing top-level documentation of
      # classes and modules. Classes with no body are exempt from the
      # check and so are namespace modules - modules that have nothing in
      # their bodies except classes, other modules, or constant definitions.
      #
      # The documentation requirement is annulled if the class or module has
      # a "#:nodoc:" comment next to it. Likewise, "#:nodoc: all" does the
      # same for all its children.
      class Documentation < Cop
        include AnnotationComment

        MSG = 'Missing top-level %s documentation comment.'.freeze

        def_node_matcher :constant_definition?, '{class module casgn}'

        def on_class(node)
          _name, _superclass, body = *node
          return unless body
          return if namespace?(body)

          ast_with_comments = processed_source.ast_with_comments
          return if associated_comment?(node, ast_with_comments)
          return if nodoc_comment?(node, ast_with_comments)
          add_offense(node, :keyword, format(MSG, :class))
        end

        def on_module(node)
          _name, body = *node
          return if namespace?(body)

          ast_with_comments = processed_source.ast_with_comments
          return if associated_comment?(node, ast_with_comments)
          return if nodoc_comment?(node, ast_with_comments)
          add_offense(node, :keyword, format(MSG, :module))
        end

        private

        def namespace?(body_node)
          return false unless body_node

          case body_node.type
          when :begin
            body_node.children.all? { |node| constant_definition?(node) }
          else
            constant_definition?(body_node)
          end
        end

        # Returns true if the node has a comment on the line above it that
        # isn't an annotation.
        def associated_comment?(node, ast_with_comments)
          preceding_comments = preceding_comments(node, ast_with_comments)
          return false if preceding_comments.empty?

          distance = node.loc.keyword.line - preceding_comments.last.loc.line
          return false if distance > 1
          return false unless comment_line_only?(preceding_comments.last)

          # As long as there's at least one comment line that isn't an
          # annotation, it's OK.
          preceding_comments.any? do |comment|
            !annotation?(comment) && !interpreter_directive_comment?(comment)
          end
        end

        def preceding_comments(node, ast_with_comments)
          ast_with_comments[node].select { |c| c.loc.line < node.loc.line }
        end

        def comment_line_only?(comment)
          source_buffer = comment.loc.expression.source_buffer
          comment_line = source_buffer.source_line(comment.loc.line)
          comment_line =~ /^\s*#/
        end

        # First checks if the :nodoc: comment is associated with the
        # class/module. Unless the element is tagged with :nodoc:, the search
        # proceeds to check its ancestors for :nodoc: all.
        # Note: How end-of-line comments are associated with code changed in
        # parser-2.2.0.4.
        def nodoc_comment?(node, ast_with_comments, require_all = false)
          return false unless node
          nodoc_node = node.children.first
          return false unless nodoc_node
          comment = ast_with_comments[nodoc_node].first

          if comment && comment.loc.line == node.loc.line
            regex = /^#\s*:nodoc:#{"\s+all\s*$" if require_all}/
            return true if comment.text =~ regex
          end

          nodoc_comment?(node.ancestors.first, ast_with_comments, true)
        end

        def interpreter_directive_comment?(comment)
          comment.text =~ /^#\s*(frozen_string_literal|encoding):/
        end
      end
    end
  end
end
