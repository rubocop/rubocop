# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Advises against defining methods inside Rake tasks.
      #
      # Defining methods inside a Rake task block makes them global because Rake
      # loads all `.rake` files before running any task.
      #
      # As a result:
      # * All such methods are loaded even if only one task is invoked.
      # * If another task defines the same method name, the last definition wins!
      #
      # Prefer lambdas, local variables, or modules to encapsulate helper methods
      #
      # @example
      #   # bad
      #   namespace :foo do
      #     task :foo do
      #       puts helper_method, "hello world!"
      #     end
      #
      #     def helper_method(foo)
      #       puts foo
      #     end
      #   end
      #
      #   # good
      #   namespace :foo do
      #     helper_method = ->(foo) { puts foo }
      #
      #     task :foo do
      #       helper_method.call("hello world!")
      #     end
      #   end
      #
      #   # good
      #   module RakeHelper
      #     module_function
      #
      #     def helper_method(foo)
      #       puts foo
      #     end
      #   end
      #
      #   namespace :foo do
      #     task :foo do
      #       RakeHelper.helper_method("hello world!")
      #     end
      #   end
      #
      class RakeMethodDefinition < Base
        MSG = 'Methods defined in Rake tasks are global and loaded for all tasks. ' \
          'If multiple methods share the same name, later method definitions will overwrite earlier ones, even across different tasks.'.freeze

        def on_def(node)
          return unless rake_file?
          return if inside_module_or_class?(node)

          add_offense(node, message: MSG)
        end

        private

        def inside_module_or_class?(node)
          node.each_ancestor(:module, :class).any?
        end

        def rake_file?
          processed_source.file_path.end_with?('.rake')
        end
      end
    end
  end
end
