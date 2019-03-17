# frozen_string_literal: true

class String
  unless method_defined? :strip_margin
    # The method strips the characters preceding a special margin character.
    # Useful for HEREDOCs and other multi-line strings.
    #
    # @example
    #
    #   code = <<-END.strip_margin('|')
    #     |def test
    #     |  some_method
    #     |  other_method
    #     |end
    #   END
    #
    #   #=> "def\n  some_method\n  \nother_method\nend"
    def strip_margin(margin_characters)
      margin = Regexp.quote(margin_characters)
      gsub(/^\s+#{margin}/, '')
    end
  end
end
