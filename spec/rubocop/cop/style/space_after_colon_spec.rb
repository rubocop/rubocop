# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceAfterColon do
  subject(:cop) { described_class.new }

  it 'registers an offence for colon without space after it' do
    # TODO: There is double reporting of the last colon (also from
    # SpaceAroundOperators).
    inspect_source(cop, ['x = w ? {a:3}:4'])
    expect(cop.messages).to eq(
      ['Space missing after colon.'] * 2)
  end

  it 'allows the colons in symbols' do
    inspect_source(cop, ['x = :a'])
    expect(cop.messages).to be_empty
  end

  it 'allows colons in strings' do
    inspect_source(cop, ["str << ':'"])
    expect(cop.messages).to be_empty
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, 'x = w ? {a:3}:4')
    expect(new_source).to eq('x = w ? {a: 3}: 4')
  end
end
