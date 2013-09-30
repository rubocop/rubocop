# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SymbolName, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowCamelCase' => true } }

  context 'when AllowCamelCase is true' do
    let(:cop_config) { { 'AllowCamelCase' => true } }

    it 'does not register an offence for camel case in names' do
      inspect_source(cop,
                     ['test = :BadIdea'])
      expect(cop.offences).to be_empty
    end
  end

  context 'when AllowCamelCase is false' do
    let(:cop_config) { { 'AllowCamelCase' => false } }

    it 'registers an offence for camel case in names' do
      inspect_source(cop,
                     ['test = :BadIdea'])
      expect(cop.messages).to eq(
        ['Use snake_case for symbols.'])
    end
  end

  context 'when AllowDots is true' do
    let(:cop_config) { { 'AllowDots' => true } }

    it 'does not register an offence for dots in names' do
      inspect_source(cop,
                     ['test = :"bad.idea"'])
      expect(cop.offences).to be_empty
    end
  end

  context 'when AllowDots is false' do
    let(:cop_config) { { 'AllowDots' => false } }

    it 'registers an offence for dots in names' do
      inspect_source(cop,
                     ['test = :"bad.idea"'])
      expect(cop.offences.map(&:message)).to eq(
        ['Use snake_case for symbols.'])
    end
  end

  it 'registers an offence for symbol used as hash label' do
    inspect_source(cop,
                   ['{ KEY_ONE: 1, KEY_TWO: 2 }'])
    expect(cop.messages).to eq(
      ['Use snake_case for symbols.'] * 2)
  end

  it 'accepts snake case in names' do
    inspect_source(cop,
                   ['test = :good_idea'])
    expect(cop.offences).to be_empty
  end

  it 'accepts snake case in hash label names' do
    inspect_source(cop,
                   ['{ one: 1, one_more_3: 2 }'])
    expect(cop.offences).to be_empty
  end

  it 'accepts snake case with a prefix @ in names' do
    inspect_source(cop,
                   ['test = :@good_idea'])
    expect(cop.offences).to be_empty
  end

  it 'accepts snake case with ? suffix' do
    inspect_source(cop,
                   ['test = :good_idea?'])
    expect(cop.offences).to be_empty
  end

  it 'accepts snake case with ! suffix' do
    inspect_source(cop,
                   ['test = :good_idea!'])
    expect(cop.offences).to be_empty
  end

  it 'accepts snake case with = suffix' do
    inspect_source(cop,
                   ['test = :good_idea='])
    expect(cop.offences).to be_empty
  end

  it 'accepts special cases - !, [] and **' do
    inspect_source(cop,
                   ['test = :**',
                    'test = :!',
                    'test = :[]',
                    'test = :[]='])
    expect(cop.offences).to be_empty
  end

  it 'accepts special cases - ==, <=>, >, <, >=, <=' do
    inspect_source(cop,
                   ['test = :==',
                    'test = :<=>',
                    'test = :>',
                    'test = :<',
                    'test = :>=',
                    'test = :<='])
    expect(cop.offences).to be_empty
  end

  it 'accepts non snake case arguments to private_constant' do
    inspect_source(cop,
                   ['private_constant :NORMAL_MODE, :ADMIN_MODE'])
    expect(cop.offences).to be_empty
  end

  it 'registers an offence for non snake case symbol near ' +
      'private_constant' do
    inspect_source(cop,
                   ['private_constant f(:ADMIN_MODE)'])
    expect(cop.offences.size).to eq(1)
  end

  it 'can handle an alias of and operator without crashing' do
    inspect_source(cop,
                   ['alias + add'])
    expect(cop.offences).to be_empty
  end

  it 'registers an offence for SCREAMING_symbol_name' do
    inspect_source(cop,
                   ['test = :BAD_IDEA'])
    expect(cop.offences.size).to eq(1)
  end
end
