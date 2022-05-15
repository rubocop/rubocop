# frozen_string_literal: true

module RuboCop
  module Cop
    module Gemspec
      # Checks that deprecated attribute attributes are not set in a gemspec file.
      # Removing `test_files` allows the user to receive smaller packed gems.
      #
      # @example
      #
      #   # bad
      #   Gem::Specification.new do |spec|
      #     spec.name = 'your_cool_gem_name'
      #     spec.test_files = Dir.glob('test/**/*')
      #   end
      #
      #   # bad
      #   Gem::Specification.new do |spec|
      #     spec.name = 'your_cool_gem_name'
      #     spec.test_files += Dir.glob('test/**/*')
      #   end
      #
      #   # good
      #   Gem::Specification.new do |spec|
      #     spec.name = 'your_cool_gem_name'
      #   end
      #
      class DeprecatedAttributeAssignment < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Do not set `test_files` in gemspec.'

        # @!method gem_specification(node)
        def_node_matcher :gem_specification, <<~PATTERN
          (block
            (send
              (const
                (const {cbase nil?} :Gem) :Specification) :new)
            ...)
        PATTERN

        def on_block(block_node)
          return unless gem_specification(block_node)

          block_parameter = block_node.arguments.first.source

          date_assignment = block_node.descendants.detect do |node|
            use_test_files?(node, block_parameter)
          end

          return unless date_assignment

          add_offense(date_assignment) do |corrector|
            range = range_by_whole_lines(date_assignment.source_range, include_final_newline: true)

            corrector.remove(range)
          end
        end

        private

        def use_test_files?(node, block_parameter)
          node, method_name = if node.op_asgn_type?
                                lhs, _op, _rhs = *node

                                [lhs, :test_files]
                              else
                                [node, :test_files=]
                              end

          node.send_type? && node.receiver&.source == block_parameter && node.method?(method_name)
        end
      end
    end
  end
end
