# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks for `expect_correction` or `expect_no_corrections` after `expect_offense`
      # for cops that support autocorrect.
      #
      # A cop is considered to support autocorrect when `extend AutoCorrector` is present.
      #
      # NOTE: No offense is registered when `expect_offense` is followed by any other
      # `expect` method. This is to reduce false positives when the correction is not 
      # the intention of the test.
      #
      # @example
      #
      #   # bad
      #   it 'registers an offense' do
      #     expect_offense('foo')
      #   end
      #
      #   # good - expect_correction is used
      #   it 'registers an offense' do
      #     expect_offense('foo')
      #
      #     expect_correction('bar')
      #   end
      #
      #   # good - expect_no_corrections is used
      #   it 'registers an offense' do
      #     expect_offense('foo')
      #
      #     expect_no_corrections
      #   end
      #
      #   # good - when the cop doesn't support autocorrect
      #   it 'registers an offense' do
      #     expect_offense('foo')
      #   end
      #
      #   # good - something else is tested
      #   it 'registers an offense' do
      #     expect_offense('foo')
      #
      #     expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      #   end
      #
      class MissingExpectCorrection < Base
        MSG = 'When the cop supports autocorrect, `expect_offense` should ' \
              'be followed by `expect_no_corrections` or `expect_correction`.'

        RESTRICT_ON_SEND = %i[expect_offense].freeze

        def on_new_investigation
          super
          return unless processed_source.ast
          return unless (cop_class_name = extract_cop_name(processed_source.ast))

          # It's a bit hacky but the config doesn't contain this information.
          # Autocorrect support is primarily declared by `extend AutoCorrector`.
          begin
            cop_class = Object.const_get(cop_class_name)
            @supports_autocorrect = cop_class.support_autocorrect?
          rescue NameError
            @supports_autocorrect = false
          end
        end

        def on_send(node)
          return unless @supports_autocorrect
          return if expectations_met?(node) || node.arguments.none?

          add_offense(node)
        end

        private

        def extract_cop_name(ast)
          describe_node = ast.each_child_node(:send).find do |send_node|
            send_node.method?(:describe)
          end
          describe_node&.first_argument&.source
        end

        def expectations_met?(node)
          node.parent.each_descendant(:send).any? do |send_node|
            next if send_node.method?(:expect_offense)

            send_node.method_name.start_with?('expect_') || send_node.method?(:expect)
          end
        end
      end
    end
  end
end
