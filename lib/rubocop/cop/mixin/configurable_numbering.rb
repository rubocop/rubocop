# frozen_string_literal: true

module RuboCop
  module Cop
    # This module provides functionality for checking if numbering match the
    # configured EnforcedStyle.
    module ConfigurableNumbering
      include ConfigurableFormatting

      FORMATS = {
        snake_case:  /(?:\D|_\d+|\A\d+)\z/,
        normalcase:  /(?:\D|[^_\d]\d+|\A\d+)\z/,
        non_integer: /(\D|\A\d+)\z/
      }.freeze
    end
  end
end
