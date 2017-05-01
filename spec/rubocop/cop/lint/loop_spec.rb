# frozen_string_literal: true

describe RuboCop::Cop::Lint::Loop do
  subject(:cop) { described_class.new }

  it 'registers an offense for begin/end/while' do
    inspect_source(cop, 'begin something; top; end while test')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for begin/end/until' do
    inspect_source(cop, 'begin something; top; end until test')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts normal while' do
    expect_no_offenses('while test; one; two; end')
  end

  it 'accepts normal until' do
    expect_no_offenses('until test; one; two; end')
  end
end
