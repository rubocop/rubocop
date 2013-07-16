# encoding: utf-8

module Rubocop
  # A basic wrapper around Parser's tokens.
  class Token
    attr_reader :pos, :type, :text

    def self.from_parser_token(parser_token)
      type, details = *parser_token
      text, range = *details
      new(range, type, text)
    end

    def initialize(pos, type, text)
      @pos, @type, @text = pos, type, text
    end

    def to_s
      "[[#{@pos.line}, #{@pos.column}], #{@type}, #{@text.inspect}]"
    end
  end
end
