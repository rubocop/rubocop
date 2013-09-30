# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::FavorJoin do
  subject(:cop) { described_class.new }

  it 'registers an offence for an array followed by string' do
    inspect_source(cop,
                   ['%w(one two three) * ", "'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Favor Array#join over Array#*.'])
  end

  it 'does not register an offence for numbers' do
    inspect_source(cop,
                   ['%w(one two three) * 4'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for ambiguous cases' do
    inspect_source(cop,
                   ['test * ", "'])
    expect(cop.offences).to be_empty

    inspect_source(cop,
                   ['%w(one two three) * test'])
    expect(cop.offences).to be_empty
  end
end
