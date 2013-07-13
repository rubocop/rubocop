# encoding: utf-8

module Rubocop
  # SourceParser provides a way to parse Ruby source with Parser gem
  # and also parses comment directives which disable arbitrary cops.
  module SourceParser
    module_function

    def parse(string, name = '(string)')
      source_buffer = Parser::Source::Buffer.new(name, 1)
      source_buffer.source = string

      parser = create_parser
      source = string.split($RS)
      diagnostics = []
      parser.diagnostics.consumer = lambda do |diagnostic|
        diagnostics << diagnostic
      end

      begin
        ast, comments, tokens = parser.tokenize(source_buffer)
      rescue Parser::SyntaxError # rubocop:disable HandleExceptions
        # All errors are in diagnostics. No need to handle exception.
      end

      tokens = repack_tokens(tokens)

      [ast, comments, tokens, source_buffer, source, diagnostics]
    end

    def parse_file(path)
      parse(File.read(path), path)
    end

    def create_parser
      parser = Parser::CurrentRuby.new

      # On JRuby and Rubinius, there's a risk that we hang in
      # tokenize() if we don't set the all errors as fatal flag.
      parser.diagnostics.all_errors_are_fatal = RUBY_ENGINE != 'ruby'
      parser.diagnostics.ignore_warnings      = false

      parser
    end

    def repack_tokens(parser_tokens)
      return nil unless parser_tokens
      parser_tokens.map do |t|
        type, details = *t
        text, range = *details
        Cop::Token.new(range, type, text)
      end
    end

    def disabled_lines_in(source)
      disabled_lines = Hash.new([])
      disabled_section = {}
      regexp = '# rubocop : (%s)\b ((?:\w+,? )+)'.gsub(' ', '\s*')
      section_regexp = '^\s*' + sprintf(regexp, '(?:dis|en)able')
      single_line_regexp = '\S.*' + sprintf(regexp, 'disable')

      source.each_with_index do |line, ix|
        each_mentioned_cop(/#{section_regexp}/, line) do |cop_name, kind|
          disabled_section[cop_name] = (kind == 'disable')
        end
        disabled_section.keys.each do |cop_name|
          disabled_lines[cop_name] += [ix + 1] if disabled_section[cop_name]
        end

        each_mentioned_cop(/#{single_line_regexp}/, line) do |cop_name, kind|
          disabled_lines[cop_name] += [ix + 1] if kind == 'disable'
        end
      end
      disabled_lines
    end

    def each_mentioned_cop(regexp, line)
      match = line.match(regexp)
      if match
        kind, cops = match.captures
        cops = Cop::Cop.all.map(&:cop_name).join(',') if cops.include?('all')
        cops.split(/,\s*/).each { |cop_name| yield cop_name, kind }
      end
    end
  end
end
