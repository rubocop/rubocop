# frozen_string_literal: true

module RuboCop
  # A basic wrapper around Parser's tokens.
  class Token
    attr_reader :pos, :type, :text

    def self.from_parser_token(parser_token)
      type, details = parser_token
      text, range = details
      new(range, type, text)
    end

    def initialize(pos, type, text)
      @pos = pos
      @type = type
      # Parser token "text" may be an Integer
      @text = text.to_s
    end

    def line
      pos.line
    end

    def column
      pos.column
    end

    def begin_pos
      pos.begin_pos
    end

    def end_pos
      pos.end_pos
    end

    def comment?
      type == :tCOMMENT
    end

    def semicolon?
      type == :tSEMI
    end

    def to_s
      "[[#{@pos.line}, #{@pos.column}], #{@type}, #{@text.inspect}]"
    end
  end
end
