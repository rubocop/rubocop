# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::EvenOdd do
  subject(:cop) { described_class.new }

  it 'registers an offense for x % 2 == 0' do
    inspect_source(cop,
                   ['x % 2 == 0'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Fixnum#even?`.'])
  end

  it 'registers an offense for x % 2 != 0' do
    inspect_source(cop,
                   ['x % 2 != 0'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Fixnum#odd?`.'])
  end

  it 'registers an offense for (x % 2) == 0' do
    inspect_source(cop,
                   ['(x % 2) == 0'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Fixnum#even?`.'])
  end

  it 'registers an offense for (x % 2) != 0' do
    inspect_source(cop,
                   ['(x % 2) != 0'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Fixnum#odd?`.'])
  end

  it 'registers an offense for x % 2 == 1' do
    inspect_source(cop,
                   ['x % 2 == 1'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Fixnum#odd?`.'])
  end

  it 'registers an offense for x % 2 != 1' do
    inspect_source(cop,
                   ['x % 2 != 1'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Fixnum#even?`.'])
  end

  it 'registers an offense for (x % 2) == 1' do
    inspect_source(cop,
                   ['(x % 2) == 1'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Fixnum#odd?`.'])
  end

  it 'registers an offense for (x % 2) != 1' do
    inspect_source(cop,
                   ['(x % 2) != 1'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Fixnum#even?`.'])
  end

  it 'accepts x % 3 == 0' do
    inspect_source(cop,
                   ['x % 3 == 0'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts x % 3 != 0' do
    inspect_source(cop,
                   ['x % 3 != 0'])
    expect(cop.offenses).to be_empty
  end
end
