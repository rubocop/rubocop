# frozen_string_literal: true

module RuboCop
  # Take a string with embedded escapes, and convert the escapes as the Ruby
  # interpreter would when reading a double-quoted string literal.
  # For example, "\\n" will be converted to "\n".
  class StringInterpreter
    STRING_ESCAPES = {
      '\a' => "\a", '\b' => "\b", '\e' => "\e", '\f' => "\f", '\n' => "\n",
      '\r' => "\r", '\s' => ' ',  '\t' => "\t", '\v' => "\v", "\\\n" => ''
    }.freeze
    STRING_ESCAPE_REGEX = /\\(?:
                            [abefnrstv\n]     |   # simple escapes (above)
                            \d{1,3}           |   # octal byte escape
                            x[0-9a-fA-F]{1,2} |   # hex byte escape
                            u[0-9a-fA-F]{4}   |   # unicode char escape
                            u\{[^}]*\}        |   # extended unicode escape
                            .                     # any other escaped char
                          )/x
    class << self
      def interpret(string)
        # We currently don't handle \cx, \C-x, and \M-x
        string.gsub(STRING_ESCAPE_REGEX) do |escape|
          STRING_ESCAPES[escape] || interpret_string_escape(escape)
        end
      end

      private

      def interpret_string_escape(escape)
        case escape[1]
        when 'u'.freeze then interpret_unicode(escape)
        when 'x'.freeze then interpret_hex(escape)
        when /\d/       then interpret_octal(escape)
        else
          escape[1] # literal escaped char, like \\
        end
      end

      def interpret_unicode(escape)
        if escape[2] == '{'.freeze
          escape[3..-1].split(/\s+/).map(&:hex).pack('U*'.freeze)
        else
          [escape[2..-1].hex].pack('U'.freeze)
        end
      end

      def interpret_hex(escape)
        [escape[2..-1].hex].pack('C'.freeze)
      end

      def interpret_octal(escape)
        [escape[1..-1].to_i(8)].pack('C'.freeze)
      end
    end
  end
end
