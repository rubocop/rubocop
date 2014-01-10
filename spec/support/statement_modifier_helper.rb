# encoding: utf-8

module StatementModifierHelper
  def check_empty(cop, keyword)
    inspect_source(cop, ["#{keyword} cond",
                         'end'])
    expect(cop.offences).to be_empty
  end

  def check_really_short(cop, keyword)
    inspect_source(cop, ["#{keyword} a",
                         '  b',
                         'end'])
    expect(cop.messages).to eq(
      ["Favor modifier #{keyword} usage when you have a single-line body."])
    expect(cop.offences.map { |o| o.location.source }).to eq([keyword])
  end

  def check_too_long(cop, keyword)
    # This statement is one character too long to fit.
    condition = 'a' * (40 - keyword.length)
    body = 'b' * 36
    expect("  #{body} #{keyword} #{condition}".length).to eq(80)

    inspect_source(cop,
                   ["  #{keyword} #{condition}",
                    "    #{body}",
                    '  end'])

    expect(cop.offences).to be_empty
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
