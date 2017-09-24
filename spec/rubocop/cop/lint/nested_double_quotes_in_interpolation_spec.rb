# frozen_string_literal: true

describe RuboCop::Cop::Lint::NestedDoubleQuotesInInterpolation do
  subject(:cop) { described_class.new }

  it 'offends if a string has interpolation with double quotes inside of it' do
    src = '"#{"foobar"}"'
    inspect_source(src)

    error_message =
      'Nesting double-quotes makes strings hard to read; switch ' \
      'to single-quotes.'
    expect(cop.messages).to eq([error_message])
  end

  it 'does not offend if a string is not inside of interpolation' do
    src = '"\"foobar\""'

    expect_no_offenses(src)
  end

  it 'does not offend if a string is interpolated inside of a heredoc' do
    src = [
      '<<-EOS',
      '#{"foobar"}',
      'EOS'
    ]

    expect_no_offenses(src)
  end

  it 'does not offend if a string is interpolated inside of a % literal' do
    src = [
      '%{',
      '#{"foobar"}',
      '}'
    ]

    expect_no_offenses(src)
  end

  it 'does not offend if a string is interpolated inside of a %Q literal' do
    src = [
      '%Q{',
      '#{"foobar"}',
      '}'
    ]

    expect_no_offenses(src)
  end
end
