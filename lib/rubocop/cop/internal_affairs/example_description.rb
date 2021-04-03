# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks that RSpec examples that use `expects_offense`
      # or `expects_no_offenses` do not have conflicting
      # descriptions.
      #
      # @example
      #   # bad
      #   it 'does not register an offense' do
      #     expect_offense('...')
      #   end
      #
      #   it 'registers an offense' do
      #     expect_no_offenses('...')
      #   end
      #
      #   # good
      #   it 'registers an offense' do
      #     expect_offense('...')
      #   end
      #
      #   it 'does not register an offense' do
      #     expect_no_offenses('...')
      #   end
      class ExampleDescription < Base
        class << self
          attr_accessor :descriptions
        end

        MSG = 'Description does not match use of `%<method_name>s`.'

        RESTRICT_ON_SEND = %i[
          expect_offense
          expect_no_offenses
          expect_correction
          expect_no_corrections
        ].to_set.freeze

        EXPECT_NO_OFFENSES_INCORRECT_DESCRIPTIONS = [
          /^(adds|registers|reports|finds) (an? )?offense/,
          /^flags\b/
        ].freeze

        EXPECT_OFFENSE_INCORRECT_DESCRIPTIONS = [
          /^(does not|doesn't) (register|find|flag|report)/,
          /^(does not|doesn't) add (a|an|any )?offense/
        ].freeze

        EXPECT_NO_CORRECTIONS_INCORRECT_DESCRIPTIONS = [/^(auto[- ]?)?correct/].freeze

        EXPECT_CORRECTION_INCORRECT_DESCRIPTIONS = [
          /\b(does not|doesn't) (auto[- ]?)?correct/
        ].freeze

        # @!method offense_example?(node)
        def_node_matcher :offense_example?, <<~PATTERN
          (block
            (send _ {:it :specify} $_description)
            _args
            `(send nil? %RESTRICT_ON_SEND ...)
          )
        PATTERN

        def on_send(node)
          parent = node.each_ancestor(:block).first
          return unless parent && (description = offense_example?(parent))

          method_name = node.method_name
          message = format(MSG, method_name: method_name)

          regexp_group = self.class.const_get("#{method_name}_incorrect_descriptions".upcase)
          check_description(description, regexp_group, message)
        end

        private

        def check_description(description, regexps, message)
          return unless regexps.any? { |regexp| regexp.match?(string_contents(description)) }

          add_offense(description, message: message)
        end

        def string_contents(node)
          node.str_type? ? node.value : node.source
        end
      end
    end
  end
end
