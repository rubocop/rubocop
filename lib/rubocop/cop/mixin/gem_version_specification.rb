# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops that require or forbid a version
    # specification on gem declarations.
    #
    # Including cops must also include `ConfigurableEnforcedStyle` with
    # `required` and `forbidden` styles, define `REQUIRED_MSG` and
    # `FORBIDDEN_MSG`, and define `allowed_gem?(node)`,
    # `includes_version_specification?(node)` and
    # `includes_commit_reference?(node)`.
    module GemVersionSpecification
      VERSION_SPECIFICATION_REGEX = /^\s*[~<>=]*\s*[0-9.]+/.freeze

      private

      def check_version_specification(node)
        return if allowed_gem?(node)

        if offense?(node)
          add_offense(node)
          opposite_style_detected
        else
          correct_style_detected
        end
      end

      def allowed_gems
        Array(cop_config['AllowedGems'])
      end

      def message(_range)
        if required_style?
          self.class::REQUIRED_MSG
        elsif forbidden_style?
          self.class::FORBIDDEN_MSG
        end
      end

      def offense?(node)
        required_offense?(node) || forbidden_offense?(node)
      end

      def required_offense?(node)
        return false unless required_style?

        !includes_version_specification?(node) && !includes_commit_reference?(node)
      end

      def forbidden_offense?(node)
        return false unless forbidden_style?

        includes_version_specification?(node) || includes_commit_reference?(node)
      end

      def forbidden_style?
        style == :forbidden
      end

      def required_style?
        style == :required
      end

      def version_specification?(expression)
        expression.match?(VERSION_SPECIFICATION_REGEX)
      end
    end
  end
end
