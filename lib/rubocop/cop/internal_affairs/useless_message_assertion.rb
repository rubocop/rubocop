# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks that cops are not tested using `described_class::MSG`.
      #
      # @example
      #
      #     # bad
      #     expect(cop.messages).to eq([described_class::MSG])
      #
      #     # good
      #     expect(cop.messages).to eq(['Do not write bad code like that.'])
      #
      class UselessMessageAssertion < Cop
        MSG = 'Do not specify cop behavior using `described_class::MSG`.'.freeze

        def_node_search :described_class_msg, <<-PATTERN
          (const (send nil? :described_class) :MSG)
        PATTERN

        def_node_matcher :rspec_expectation_on_msg?, <<-PATTERN
          (send (send nil? :expect #contains_described_class_msg?) :to ...)
        PATTERN

        def investigate(_processed_source)
          assertions_using_described_class_msg.each do |node|
            add_offense(node)
          end
        end

        private

        def contains_described_class_msg?(node)
          described_class_msg(node).any?
        end

        def assertions_using_described_class_msg
          described_class_msg(processed_source.ast).reject do |node|
            node.ancestors.any?(&method(:rspec_expectation_on_msg?))
          end
        end

        # Only process spec files
        def relevant_file?(file)
          file.end_with?('_spec.rb')
        end
      end
    end
  end
end
