# frozen_string_literal: true

module StatementModifierHelper
  def check_empty(keyword)
    expect_no_offenses(<<-RUBY.strip_indent)
      #{keyword} cond
      end
    RUBY
  end

  def check_really_short(keyword)
    inspect_source(<<-RUBY.strip_indent)
      #{keyword} a
        b
      end
    RUBY
    expect(cop.messages).to eq(
      ["Favor modifier `#{keyword}` usage when having a single-line body."]
    )
    expect(cop.offenses.map { |o| o.location.source }).to eq([keyword])
  end

  def autocorrect_really_short(keyword)
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      #{keyword} a
        b
      end
    RUBY
    expect(corrected).to eq "b #{keyword} a\n"
  end

  def check_too_long(keyword)
    # This statement is one character too long to fit.
    condition = 'a' * (40 - keyword.length)
    body = 'b' * 37
    expect("  #{body} #{keyword} #{condition}".length).to eq(81)

    expect_no_offenses(<<-RUBY.strip_margin('|'))
      |  #{keyword} #{condition}
      |    #{body}
      |  end
    RUBY
  end

  def check_short_multiline(keyword)
    expect_no_offenses(<<-RUBY.strip_indent)
      #{keyword} ENV['COVERAGE']
        require 'simplecov'
        SimpleCov.start
      end
    RUBY
  end
end
