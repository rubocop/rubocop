# encoding: utf-8
# frozen_string_literal: true

module StatementModifierHelper
  def check_empty(cop, keyword)
    inspect_source(cop, ["#{keyword} cond",
                         'end'])
    expect(cop.offenses).to be_empty
  end

  def check_really_short(cop, keyword)
    inspect_source(cop, ["#{keyword} a",
                         '  b',
                         'end'])
    expect(cop.messages).to eq(
      ["Favor modifier `#{keyword}` usage when having a single-line body."]
    )
    expect(cop.offenses.map { |o| o.location.source }).to eq([keyword])
  end

  def autocorrect_really_short(cop, keyword)
    corrected = autocorrect_source(cop,
                                   ["#{keyword} a",
                                    '  b',
                                    'end'])
    expect(corrected).to eq "b #{keyword} a"
  end

  def check_too_long(cop, keyword)
    # This statement is one character too long to fit.
    condition = 'a' * (40 - keyword.length)
    body = 'b' * 37
    expect("  #{body} #{keyword} #{condition}".length).to eq(81)

    inspect_source(cop,
                   ["  #{keyword} #{condition}",
                    "    #{body}",
                    '  end'])

    expect(cop.offenses).to be_empty
  end

  def check_short_multiline(cop, keyword)
    inspect_source(cop,
                   ["#{keyword} ENV['COVERAGE']",
                    "  require 'simplecov'",
                    '  SimpleCov.start',
                    'end'])
    expect(cop.messages).to be_empty
  end
end
