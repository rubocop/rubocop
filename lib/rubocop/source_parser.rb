# encoding: utf-8

module Rubocop
  # SourceParser provides a way to parse Ruby source with Parser gem
  # and also parses comment directives which disable arbitrary cops.
  module SourceParser
    module_function

    def parse_file(path)
      parse(File.read(path), path)
    end

    def parse(string, name = '(string)')
      source_buffer = Parser::Source::Buffer.new(name, 1)
      source_buffer.source = string

      parser = create_parser
      diagnostics = []
      parser.diagnostics.consumer = lambda do |diagnostic|
        diagnostics << diagnostic
      end

      begin
        ast, comments, tokens = parser.tokenize(source_buffer)
      rescue Parser::SyntaxError # rubocop:disable HandleExceptions
        # All errors are in diagnostics. No need to handle exception.
      end

      tokens = tokens.map { |t| Token.from_parser_token(t) } if tokens

      ProcessedSource.new(source_buffer, ast, comments, tokens, diagnostics)
    end

    def create_parser
      parser = Parser::CurrentRuby.new

      # On JRuby and Rubinius, there's a risk that we hang in tokenize() if we
      # don't set the all errors as fatal flag. The problem is caused by a bug
      # in Racc that is discussed in issue #93 of the whitequark/parser project
      # on GitHub.
      parser.diagnostics.all_errors_are_fatal = RUBY_ENGINE != 'ruby'
      parser.diagnostics.ignore_warnings      = false

      parser
    end
  end
end
