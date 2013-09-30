# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::OpMethod do
  subject(:cop) { described_class.new }

  it 'registers an offence for arg not named other' do
    inspect_source(cop,
                   ['def +(another)',
                    '  another',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['When defining the + operator, name its argument *other*.'])
  end

  it 'works properly even if the argument not surrounded with braces' do
    inspect_source(cop,
                   ['def + another',
                    '  another',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['When defining the + operator, name its argument *other*.'])
  end

  it 'does not register an offence for arg named other' do
    inspect_source(cop,
                   ['def +(other)',
                    '  other',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for []' do
    inspect_source(cop,
                   ['def [](index)',
                    '  other',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for []=' do
    inspect_source(cop,
                   ['def []=(index, value)',
                    '  other',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for <<' do
    inspect_source(cop,
                   ['def <<(cop)',
                    '  other',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for non binary operators' do
    inspect_source(cop,
                   ['def -@', # Unary minus
                    'end',
                    '',
                    # This + is not a unary operator. It can only be
                    # called with dot notation.
                    'def +',
                    'end',
                    '',
                    'def *(a, b)', # Quite strange, but legal ruby.
                    'end'])
    expect(cop.offences).to be_empty
  end
end
