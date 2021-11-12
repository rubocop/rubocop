# frozen_string_literal: true

module RuboCop
  module Cop
    module Gemspec
      # This cop checks that `date =` is not used in gemspec file.
      # It is set automatically when the gem is packaged.
      #
      # @example
      #
      #   # bad
      #   Gem::Specification.new do |spec|
      #     s.name = 'your_cool_gem_name'
      #     spec.date = Time.now.strftime('%Y-%m-%d')
      #   end
      #
      #   # good
      #   Gem::Specification.new do |spec|
      #     s.name = 'your_cool_gem_name'
      #   end
      #
      class DateAssignment < Base
        include RangeHelp
        include GemspecHelp
        extend AutoCorrector

        MSG = 'Do not use `date =` in gemspec, it is set automatically when the gem is packaged.'

        def on_block(block_node)
          return unless gem_specification?(block_node)

          block_parameter = block_node.arguments.first.source

          date_assignment = block_node.descendants.detect do |node|
            node.send_type? && node.receiver&.source == block_parameter && node.method?(:date=)
          end

          return unless date_assignment

          add_offense(date_assignment) do |corrector|
            range = range_by_whole_lines(date_assignment.source_range, include_final_newline: true)

            corrector.remove(range)
          end
        end
      end
    end
  end
end
