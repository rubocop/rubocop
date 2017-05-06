# frozen_string_literal: true

module RuboCop
  # This class represents a range of source lines configured by `rubocop:*`
  # directives.
  class CommentConfigRange < Range
    attr_reader :begin_directive
    attr_reader :end_directive

    def initialize(begin_directive, end_directive)
      @begin_directive = begin_directive
      @end_directive = end_directive

      begin_line = begin_directive.line
      end_line = end_directive ? end_directive.line : Float::INFINITY
      super(begin_line, end_line)
    end

    def single_line?
      begin_directive == end_directive
    end
  end
end
