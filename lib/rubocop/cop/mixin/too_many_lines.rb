# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking for too many lines.
    module TooManyLines
      include ConfigurableMax
      include CodeLength

      MSG = '%<label>s has too many lines. [%<length>d/%<max>d]'.freeze

      private

      def message(length, max_length)
        format(MSG, label: cop_label, length: length, max: max_length)
      end

      def code_length(node)
        body = extract_body(node)
        lines = body && body.source.lines || []

        lines.count { |line| !irrelevant_line(line) }
      end

      def extract_body(node)
        case node.type
        when :block, :def
          _receiver_or_method, _args, body = *node
        when :defs
          _self, _method, _args, body = *node
        else
          body = node
        end

        body
      end
    end
  end
end
