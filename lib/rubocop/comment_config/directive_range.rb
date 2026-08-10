# frozen_string_literal: true

module RuboCop
  class CommentConfig
    # A disabled line range that remembers the directive comment that opened
    # it. Value-equal to a plain `Range`, so consumers comparing or hashing
    # ranges are unaffected.
    # @api private
    class DirectiveRange < Range
      attr_reader :directive

      def initialize(first_line, last_line, directive)
        super(first_line, last_line)
        @directive = directive
      end
    end

    # The per-cop state accumulated while analyzing directives: the disabled
    # ranges so far, plus the line and directive of the currently open
    # disable, if any.
    # @api private
    CopAnalysis = Struct.new(:line_ranges, :start_line_number, :start_directive) do
      # The open range (if any) closed at the given line, appended to the
      # accumulated ranges, each remembering the directive that opened it.
      def close(line)
        return line_ranges unless start_line_number

        line_ranges + [DirectiveRange.new(start_line_number, line, start_directive)]
      end
    end
  end
end
