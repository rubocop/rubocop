# frozen_string_literal: true

# Extensions to the core String class
class String
  unless method_defined? :blank?
    # Checks whether a string is blank. A string is considered blank if it
    # is either empty or contains only whitespace characters.
    #
    # @return [Boolean] true is the string is blank, false otherwise
    #
    # @example
    #   ''.blank? #=> true
    #
    # @example
    #   '    '.blank? #=> true
    #
    # @example
    #   '  test'.blank? #=> false
    def blank?
      empty? || strip.empty?
    end
  end

  unless method_defined? :strip_indent
    # The method strips the whitespace preceding the base indentation.
    # Useful for HEREDOCs and other multi-line strings.
    #
    # @example
    #
    #   code = <<-END.strip_indent
    #     def test
    #       some_method
    #       other_method
    #     end
    #   END
    #
    #   #=> "def\n  some_method\n  \nother_method\nend"
    #
    # @todo Replace call sites with squiggly heredocs when required Ruby
    #   version is >= 2.3.0
    def strip_indent
      leading_space = scan(/^[ \t]*(?=\S)/).min
      indent = leading_space ? leading_space.size : 0
      gsub(/^[ \t]{#{indent}}/, '')
    end
  end
end
