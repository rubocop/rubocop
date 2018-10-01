# frozen_string_literal: true

module RuboCop
  module Cop
    # This module provides functionality for checking if numbering match the
    # configured EnforcedStyle.
    module ConfigurableNumbering
      include ConfigurableFormatting

      FORMATS = {
        snake_case: /(?:[a-z_]|_\d+)$/,
        normalcase: /(?:_\D*|[A-Za-z]\d*)$/,
        non_integer: /[A-Za-z_]$/
      }.freeze
    end
  end
end
