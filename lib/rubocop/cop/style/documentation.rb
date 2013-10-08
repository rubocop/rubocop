# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for missing top-level documentation of
      # classes and modules. Classes with no body are exempt from the
      # check and so are namespace modules - modules that have nothing in
      # their bodies except classes or other other modules.
      class Documentation < Cop
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
            next unless ast_with_comments[node].empty?
            convention(node, :keyword, format(MSG, node.type.to_s))
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
      end
    end
  end
end
