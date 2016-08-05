# encoding: utf-8
# frozen_string_literal: true
module RuboCop
  module Cop
    module Style
      # This cop checks for missing documentation comment for public methods.
      #
      # @example
      #
      #   # bad
      #
      #   class MyClass
      #     def method
      #       puts 'method'
      #     end
      #   end
      #
      #   module MyModule
      #     def method
      #       puts 'method'
      #     end
      #   end
      #
      #   def my_class.method
      #     puts 'method'
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
      #   module MyModule
      #     # Method Comment
      #     def method
      #       puts 'method'
      #     end
      #   end
      #
      #   # Method Comment
      #   def my_class.method
      #     puts 'method'
      #   end
      class DocumentationMethod < Cop
        include DocumentationComment
        include AnnotationComment
        include OnMethodDef

        MSG = 'Missing method documentation comment.'.freeze
        NON_PUBLIC_MODIFIERS = %w(private protected).freeze

        def on_def(node)
          check(node)
        end

        def on_method_def(node, *)
          check(node)
        end

        private

        def check(node)
          return if non_public_method?(node)
          return if associated_comment?(node)

          add_offense(node, :keyword, MSG)
        end

        def non_public_method?(node)
          non_public_modifier?(node.parent) ||
            preceding_non_public_modifier?(node)
        end

        def preceding_non_public_modifier?(node)
          stripped_source_upto(node.loc.line).any? do |line|
            NON_PUBLIC_MODIFIERS.include?(line)
          end
        end

        def stripped_source_upto(line)
          processed_source[0..line].map(&:strip)
        end

        def_node_matcher :non_public_modifier?, <<-PATTERN
          (send nil {:private :protected} ({def defs} ...))
        PATTERN
      end
    end
  end
end
