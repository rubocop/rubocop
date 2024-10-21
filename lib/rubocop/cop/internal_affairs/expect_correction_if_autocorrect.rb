# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks for `expect_correction` or `expect_no_corrections` after `expect_offense`
      # for cops that support autocorrect.
      #
      # @example EnforcedStyle: bar (default)
      #   # Description of the `bar` style.
      #
      # @example EnforcedStyle: foo
      #   # Description of the `foo` style.
      #
      class ExpectCorrectionIfAutocorrect < Base
        MSG = '`expect_offense` must be followed by `expect_no_corrections` or `expect_correction`.'

        RESTRICT_ON_SEND = %i[expect_offense].freeze
        EXPECTED_METHODS = %i[expect_no_corrections expect_correction].freeze

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
          return if expectations_met?(node)

          add_offense(node)
        end

        private

        def extract_cop_name(ast)
          ast.each_child_node(:send).each do |send_node|
            return send_node.first_argument.source if send_node.method?(:describe)
          end
          nil
        end

        def expectations_met?(node)
          node.parent.each_child_node(:send).any? do |send_node|
            EXPECTED_METHODS.include?(send_node.method_name)
          end
        end
      end
    end
  end
end
