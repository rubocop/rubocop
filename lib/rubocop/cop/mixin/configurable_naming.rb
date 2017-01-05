# frozen_string_literal: true

module RuboCop
  module Cop
    # This module provides functionality for checking if names match the
    # configured EnforcedStyle.
    module ConfigurableNaming
      include ConfigurableFormatting

      FORMATS = {
        snake_case: /^@{0,2}[\da-z_]+[!?=]?$/,
        camelCase:  /^@{0,2}_?[a-z][\da-zA-Z]+[!?=]?$/
      }.freeze
    end
  end
end
