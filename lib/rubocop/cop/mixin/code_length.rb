# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for checking length of code segments.
    module CodeLength
      include DSLMethod
      include ConfigurableMax

      def max_length
        cop_config['Max']
      end

      def count_comments?
        cop_config['CountComments']
      end

      def check_code_length(node, *_)
        return if node.type == :block && !dsl_method?(node)

        length = code_length(node)
        return unless length > max_length

        sym = loc_selector(node.type)

        add_offense(node, sym, message(length, max_length)) do
          self.max = length
        end
      end

      # Returns true for lines that shall not be included in the count.
      def irrelevant_line?(source_line)
        source_line.blank? || !count_comments? && comment_line?(source_line)
      end

      private

      def loc_selector(type)
        return :begin if type == :block
        :keyword
      end
    end
  end
end
