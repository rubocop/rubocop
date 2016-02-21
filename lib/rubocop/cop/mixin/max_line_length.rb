# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops that need to check for long lines.
    module MaxLineLength
      LINE_LENGTH = 'Metrics/LineLength'.freeze
      MAX = 'Max'.freeze
      MAX_LINE_LENGTH = 'MaxLineLength'.freeze

      def max_line_length
        cop_config[MAX_LINE_LENGTH] || config.for_cop(LINE_LENGTH)[MAX]
      end
    end
  end
end
