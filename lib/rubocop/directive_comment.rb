# frozen_string_literal: true

module RuboCop
  # This class wraps the `Parser::Source::Comment` object that represents a
  # special `rubocop:disable` and `rubocop:enable` comment and exposes what
  # cops it contains.
  class DirectiveComment
    attr_reader :comment

    def initialize(comment)
      @comment = comment
    end

    # Return all the cops specified in the directive
    def cops
      match = comment.text.match(CommentConfig::COMMENT_DIRECTIVE_REGEXP)
      return unless match

      cops_string = match.captures[1]
      cops_string.split(/,\s*/).uniq.sort
    end

    # Checks if this directive contains all the given cop names
    def match?(cop_names)
      cops == cop_names.uniq.sort
    end

    def range
      comment.location.expression
    end
  end
end
