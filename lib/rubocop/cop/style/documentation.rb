# encoding: utf-8

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

        def investigate(processed_source)
          ast = processed_source.ast
          return unless ast

          ast_with_comments = Parser::Source::Comment.associate(
            ast,
            processed_source.comments
          )

          check(ast, ast_with_comments)
        end

        private

        def check(ast, ast_with_comments)
          ast.each_node(:class, :module) do |node|
            case node.type
            when :class
              _name, _superclass, body = *node
            when :module
              _name, body = *node
            end

            next if node.type == :class && !body
            next if namespace?(body)
            next if associated_comment?(node, ast_with_comments)
            next if nodoc?(node, ast_with_comments)
            add_offense(node, :keyword, format(MSG, node.type.to_s))
          end
        end

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
          preceding_comments.any? { |comment| !annotation?(comment) }
        end

        def preceding_comments(node, ast_with_comments)
          return [] unless node && ast_with_comments

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
        def nodoc?(node, ast_with_comments, require_all = false)
          return false unless node
          nodoc_node = node.children.first
          return false unless nodoc_node
          comment = ast_with_comments[nodoc_node].first

          if comment && comment.loc.line == node.loc.line
            regex = /^#\s*:nodoc:#{"\s+all\s*$" if require_all}/
            return true if comment.text =~ regex
          end

          nodoc?(node.ancestors.first, ast_with_comments, true)
        end
      end
    end
  end
end
