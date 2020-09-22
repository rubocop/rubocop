# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Do not define constants within a block, since the block's scope does not
      # isolate or namespace the constant in any way.
      #
      # If you are trying to define that constant once, define it outside of
      # the block instead, or use a variable or method if defining the constant
      # in the outer scope would be problematic.
      #
      # For meta-programming, use `const_set`.
      #
      # @example
      #   # bad
      #   task :lint do
      #     FILES_TO_LINT = Dir['lib/*.rb']
      #   end
      #
      #   # bad
      #   describe 'making a request' do
      #     class TestRequest; end
      #   end
      #
      #   # bad
      #   module M
      #     extend ActiveSupport::Concern
      #     included do
      #       LIST = []
      #     end
      #   end
      #
      #   # good
      #   task :lint do
      #     files_to_lint = Dir['lib/*.rb']
      #   end
      #
      #   # good
      #   describe 'making a request' do
      #     let(:test_request) { Class.new }
      #     # see also `stub_const` for RSpec
      #   end
      #
      #   # good
      #   module M
      #     extend ActiveSupport::Concern
      #     included do
      #       const_set(:LIST, [])
      #     end
      #   end
      class ConstantDefinitionInBlock < Base
        MSG = 'Do not define constants this way within a block.'

        def_node_matcher :constant_assigned_in_block?, <<~PATTERN
          ({^block_type? [^begin_type? ^^block_type?]} nil? ...)
        PATTERN

        def_node_matcher :module_defined_in_block?, <<~PATTERN
          ({^block_type? [^begin_type? ^^block_type?]} ...)
        PATTERN

        def on_casgn(node)
          add_offense(node) if constant_assigned_in_block?(node)
        end

        def on_class(node)
          add_offense(node) if module_defined_in_block?(node)
        end
        alias on_module on_class
      end
    end
  end
end
