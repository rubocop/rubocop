# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length a module exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class ModuleLength < Cop
        include ClassishLength

        def on_module(node)
          check_code_length(node)
        end

        private

        def message(length, max_length)
          format('Module has too many lines. [%<length>d/%<max>d]',
                 length: length,
                 max: max_length)
        end
      end
    end
  end
end
