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

          check_classes(ast, ast_with_comments)
          check_modules(ast, ast_with_comments)
        end

        private

        def check_classes(ast, ast_with_comments)
          on_node(:class, ast) do |node|
            _name, _superclass, body = *node

            if body && ast_with_comments[node].empty?
              add_offence(:convention, node.loc.keyword, format(MSG, 'class'))
            end
          end
        end

        def check_modules(ast, ast_with_comments)
          on_node(:module, ast) do |node|
            _name, body = *node

            if body.nil?
              namespace = false
            elsif body.type == :begin
              namespace = body.children.all? do |n|
                [:class, :module].include?(n.type)
              end
            elsif body.type == :class || body.type == :module
              namespace = true
            else
              namespace = false
            end

            if !namespace && ast_with_comments[node].empty?
              add_offence(:convention, node.loc.keyword, format(MSG, 'module'))
            end
          end
        end
      end
    end
  end
end
