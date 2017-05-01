# frozen_string_literal: true

describe RuboCop::Cop::Style::DoubleNegation do
  subject(:cop) { described_class.new }

  it 'registers an offense for !!' do
    inspect_source(cop, '!!test.something')
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for !' do
    expect_no_offenses('!test.something')
  end

  it 'does not register an offense for not not' do
    expect_no_offenses('not not test.something')
  end
end
