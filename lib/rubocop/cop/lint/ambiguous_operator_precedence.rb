# frozen_string_literal: true

require_relative '../style/explicit_operator_precedence'

module RuboCop
  module Cop
    module Lint
      #
      # IMPORTANT: This cop is deprecated and will be removed in RuboCop 2.0.
      #            Please use `Style/ExplicitOperatorPrecedence` instead.
      #
      class AmbiguousOperatorPrecedence < RuboCop::Cop::Style::ExplicitOperatorPrecedence
      end
    end
  end
end
