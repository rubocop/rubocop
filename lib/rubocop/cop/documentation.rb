# encoding: utf-8

module Rubocop
  module Cop
    # This cop checks for missing top-level documentation of
    # classes and modules. Classes with no body are exempt from the
    # check and so are namespace modules - modules that have nothing in
    # their bodies except classes or other other modules.
    class Documentation < Cop
      MSG = 'Missing top level class/module documentation comment.'

      # TODO: This cop is disabled for now due to a Parser bug.
      # https://github.com/bbatsov/rubocop/commit/b5461be
      # rubocop:disable UnreachableCode
      def inspect(source_buffer, source, tokens, ast, comments)
        return

        ast_with_comments = Parser::Source::Comment.associate(ast, comments)

        check_classes(ast, ast_with_comments)
        check_modules(ast, ast_with_comments)
      end
      # rubocop:enable UnreachableCode

      private

      def check_classes(ast, ast_with_comments)
        on_node(:class, ast) do |node|
          _name, _superclass, body = *node

          if body.type != nil && ast_with_comments[node].empty?
            add_offence(:convention, node.loc.keyword, MSG)
          end
        end
      end

      def check_modules(ast, ast_with_comments)
        on_node(:module, ast) do |node|
          _name, *body = *node

          non_namespace = body.any? { |n| ![:class, :module].include?(n.type) }

          if non_namespace && ast_with_comments[node].empty?
            add_offence(:convention, node.loc.keyword, MSG)
          end
        end
      end
    end
  end
end
