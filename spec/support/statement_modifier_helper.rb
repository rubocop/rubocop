# frozen_string_literal: true

module StatementModifierHelper
  def check_empty(cop, keyword)
    inspect_source(cop, <<-END.strip_indent)
      #{keyword} cond
      end
    END
    expect(cop.offenses).to be_empty
  end

  def check_really_short(cop, keyword)
    inspect_source(cop, <<-END.strip_indent)
      #{keyword} a
        b
      end
    END
    expect(cop.messages).to eq(
      ["Favor modifier `#{keyword}` usage when having a single-line body."]
    )
    expect(cop.offenses.map { |o| o.location.source }).to eq([keyword])
  end

  def autocorrect_really_short(cop, keyword)
    corrected = autocorrect_source(cop, <<-END.strip_indent)
      #{keyword} a
        b
      end
    END
    expect(corrected).to eq "b #{keyword} a\n"
  end

  def check_too_long(cop, keyword)
    # This statement is one character too long to fit.
    condition = 'a' * (40 - keyword.length)
    body = 'b' * 37
    expect("  #{body} #{keyword} #{condition}".length).to eq(81)

    inspect_source(cop, <<-END.strip_margin('|'))
      |  #{keyword} #{condition}
      |    #{body}
      |  end
    END

    expect(cop.offenses).to be_empty
  end

  def check_short_multiline(cop, keyword)
    inspect_source(cop, <<-END.strip_indent)
      #{keyword} ENV['COVERAGE']
        require 'simplecov'
        SimpleCov.start
      end
    END
    expect(cop.messages).to be_empty
  end
end
