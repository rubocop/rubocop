# frozen_string_literal: true

module RuboCop
  module Cop
    module Gemspec
      # Checks that deprecated attributes are not set in a gemspec file.
      # Removing deprecated attributes allows the user to receive smaller packed gems.
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

        MSG = 'Do not set `%<attribute>s` in gemspec.'

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

          block_parameter = block_node.first_argument.source

          block_node.each_descendant do |assignment|
            next unless use_deprecated_attributes?(assignment, block_parameter)

            register_assignment(assignment, block_node.body)
          end
        end

        private

        def register_assignment(assignment, body)
          add_offense(assignment, message: format_message_from) do |corrector|
            range = removal_range(assignment, body)
            corrector.remove(range) if range
          end
        end

        def removal_range(assignment, body)
          return if trailing_heredoc?(assignment)

          source = assignment.source_range
          range = range_for_statement_removal(source)
          return range if assignment.equal?(body)
          return range if body&.begin_type? && assignment.parent.equal?(body)
          return range if range == range_by_whole_lines(source, include_final_newline: true)

          nil
        end

        def trailing_heredoc?(assignment)
          end_pos = assignment.source_range.end_pos
          assignment.each_descendant.any? do |child|
            child.loc?(:heredoc_end) && child.loc.heredoc_end.end_pos > end_pos
          end
        end

        def node_and_method_name(node, attribute)
          if node.op_asgn_type?
            [node.lhs, attribute]
          else
            [node, :"#{attribute}="]
          end
        end

        def use_deprecated_attributes?(node, block_parameter)
          %i[test_files date specification_version rubygems_version].each do |attribute|
            node, method_name = node_and_method_name(node, attribute)
            unless node.send_type? && node.receiver&.source == block_parameter &&
                   node.method?(method_name)
              next
            end

            @attribute = attribute.to_s
            return true
          end
          false
        end

        def format_message_from
          format(MSG, attribute: @attribute)
        end
      end
    end
  end
end
