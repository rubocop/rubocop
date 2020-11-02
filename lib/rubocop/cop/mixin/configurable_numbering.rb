# frozen_string_literal: true

module RuboCop
  module Cop
    # This module provides functionality for checking if numbering match the
    # configured EnforcedStyle.
    module ConfigurableNumbering
      include ConfigurableFormatting

      FORMATS = {
        snake_case:  /(?:\D|_\d+)$/,
        normalcase:  /(?:\D|[^_\d]\d+)$/,
        non_integer: /\D$/
      }.freeze
    end
  end
end
