# encoding: utf-8
# frozen_string_literal: true
module RuboCop
  module Cop
    module Style
      # This cop checks for missing documentation comment for public method.
      #
      # @example
      #   # declaring methods outside of a class
      #
      #   # bad
      #
      #   def method
      #     puts "method"
      #   end
      #
      #   class MyClass
      #   end
      #
      #   # good
      #
      #   # Method Comment
      #   def method
      #     puts "method"
      #   end
      #
      #   class MyClass
      #   end
      #
      # @example
      #   # declaring methods inside a class
      #
      #   # bad
      #
      #   class MyClass
      #     def method
      #       puts 'method'
      #     end
      #   end
      #
      #   # good
      #
      #   class MyClass
      #     # Method Comment
      #     def method
      #       puts 'method'
      #     end
      #   end
      #
      # @example
      #   # declaring methods inside a module
      #
      #   # bad
      #
      #   module MyModule
      #     def method
      #       puts 'method'
      #     end
      #   end
      #
      #   #good
      #
      #   module MyModule
      #     # Method Comment
      #     def method
      #       puts 'method'
      #     end
      #   end
      #
      #   # singleton methods
      #
      #   # bad
      #
      #   class MyClass
      #   end
      #
      #   my_class = MyClass.new
      #
      #   def my_class.method
      #     puts 'method'
      #   end
      #
      #   # good
      #
      #   class MyClass
      #   end
      #
      #   my_class = MyClass.new
      #
      #   # Method Comment
      #   def my_class.method
      #     puts 'method'
      #   end
      #
      class DocumentationMethod < Cop
        include AnnotationComment
        include OnMethodDef
        MSG = 'Missing top-level %s documentation method comment.'.freeze
        METHOD_TYPE = %w(private protected).freeze

        def_node_matcher :constant_definition?, '{def casgn}'

        def on_def(node)
          check_offenses(node)
        end

        def on_method_def(node, _method_name, _args, _body)
          check_offenses(node)
        end

        private

        def check_offenses(node)
          _name, _body = *node

          line = node.loc.line
          return if node.ancestors.first.to_a.include? method_type
          return if (processed_source[0..line].map(&:strip) &
            METHOD_TYPE).any?
          ast_with_comments = processed_source.ast_with_comments
          return if associated_comment?(node, ast_with_comments)
          add_offense(node, :keyword, format(MSG, :module))
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

        def interpreter_directive_comment?(comment)
          comment.text =~ /^#\s*(frozen_string_literal|encoding):/
        end

        def method_type
          :private || :protected
        end
      end
    end
  end
end
