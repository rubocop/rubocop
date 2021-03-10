# frozen_string_literal: true

module RuboCop
  # This class wraps the `Parser::Source::Comment` object that represents a
  # special `rubocop:disable` and `rubocop:enable` comment and exposes what
  # cops it contains.
  class DirectiveComment
    # @api private
    COP_NAME_PATTERN = '([A-Z]\w+/)*(?:[A-Z]\w+)'
    # @api private
    COP_NAMES_PATTERN = "(?:#{COP_NAME_PATTERN} , )*#{COP_NAME_PATTERN}"
    # @api private
    COPS_PATTERN = "(all|#{COP_NAMES_PATTERN})"
    # @api private
    DIRECTIVE_COMMENT_REGEXP = Regexp.new(
      "# rubocop : ((?:disable|enable|todo))\\b #{COPS_PATTERN}"
        .gsub(' ', '\s*')
    )

    def self.before_comment(line)
      line.split(DIRECTIVE_COMMENT_REGEXP).first
    end

    attr_reader :comment, :mode, :cops

    def initialize(comment)
      @comment = comment
      @mode, @cops = match_captures
    end

    # Checks if this directive relates to single line
    def single_line?
      !self.class.before_comment(comment.text).empty?
    end

    # Checks if this directive contains all the given cop names
    def match?(cop_names)
      parsed_cop_names.uniq.sort == cop_names.uniq.sort
    end

    def range
      comment.location.expression
    end

    # Returns match captures to directive comment pattern
    def match_captures
      @match_captures ||= comment.text.match(DIRECTIVE_COMMENT_REGEXP)&.captures
    end

    private

    def parsed_cop_names
      (cops || '').split(/,\s*/)
    end
  end
end
