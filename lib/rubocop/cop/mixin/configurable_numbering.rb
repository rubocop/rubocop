# frozen_string_literal: true

module RuboCop
  module Cop
    # This module provides functionality for checking if numbering match the
    # configured EnforcedStyle.
    module ConfigurableNumbering
      include ConfigurableFormatting

      FORMATS = {
        snake_case:  /(?:[[[:lower:]]_]|_\d+)$/,
        normalcase:  /(?:_\D*|[[[:upper:]][[:lower:]]]\d*)$/,
        non_integer: /[[[:upper:]][[:lower:]]_]$/
      }.freeze
    end
  end
end
