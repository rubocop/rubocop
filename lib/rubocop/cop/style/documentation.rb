# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for missing top-level documentation of
      # classes and modules. Classes with no body are exempt from the
      # check and so are namespace modules - modules that have nothing in
      # their bodies except classes or other other modules.
      class Documentation < Cop
        include AnnotationComment

        MSG = 'Missing top-level %s documentation comment.'

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
          on_node([:class, :module], ast) do |node|
            case node.type
            when :class
              _name, _superclass, body = *node
            when :module
              _name, body = *node
            end

            next if node.type == :class && !body
            next if namespace?(body)
            next if associated_comment?(node, ast_with_comments)
            add_offence(node, :keyword, format(MSG, node.type.to_s))
          end
        end

        def namespace?(body_node)
          return false unless body_node

          case body_node.type
          when :begin
            body_node.children.all? do |node|
              [:class, :module].include?(node.type)
            end
          when :class, :module
            true
          else
            false
          end
        end

        # Returns true if the node has a comment on the line above it that
        # isn't an annotation.
        def associated_comment?(node, ast_with_comments)
          return false if ast_with_comments[node].empty?

          preceding_comment = ast_with_comments[node].last
          distance = node.loc.keyword.line - preceding_comment.loc.line
          return false if distance > 1

          !annotation?(preceding_comment)
        end
      end
    end
  end
end
