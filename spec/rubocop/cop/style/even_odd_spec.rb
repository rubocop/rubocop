# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::EvenOdd do
  subject(:cop) { described_class.new }

  it 'registers an offence for x % 2 == 0' do
    inspect_source(cop,
                   ['x % 2 == 0'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['Use Fixnum.even?'])
  end

  it 'registers an offence for x % 2 != 0' do
    inspect_source(cop,
                   ['x % 2 != 0'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['Use Fixnum.odd?'])
  end

  it 'registers an offence for (x % 2) == 0' do
    inspect_source(cop,
                   ['(x % 2) == 0'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['Use Fixnum.even?'])
  end

  it 'registers an offence for (x % 2) != 0' do
    inspect_source(cop,
                   ['(x % 2) != 0'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['Use Fixnum.odd?'])
  end

  it 'registers an offence for x % 2 == 1' do
    inspect_source(cop,
                   ['x % 2 == 1'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['Use Fixnum.odd?'])
  end

  it 'registers an offence for x % 2 != 1' do
    inspect_source(cop,
                   ['x % 2 != 1'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['Use Fixnum.even?'])
  end

  it 'registers an offence for (x % 2) == 1' do
    inspect_source(cop,
                   ['(x % 2) == 1'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['Use Fixnum.odd?'])
  end

  it 'registers an offence for (x % 2) != 1' do
    inspect_source(cop,
                   ['(x % 2) != 1'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['Use Fixnum.even?'])
  end

  it 'accepts x % 3 == 0' do
    inspect_source(cop,
                   ['x % 3 == 0'])
    expect(cop.offences).to be_empty
  end

  it 'accepts x % 3 != 0' do
    inspect_source(cop,
                   ['x % 3 != 0'])
    expect(cop.offences).to be_empty
  end
end
