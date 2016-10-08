# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length of a method exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class MethodLength < Cop
        include OnMethodDef
        include TooManyLines

        LABEL = 'Method'.freeze

        private

        def on_method_def(node, _method_name, _args, _body)
          check_code_length(node)
        end

        def cop_label
          LABEL
        end
      end
    end
  end
end
