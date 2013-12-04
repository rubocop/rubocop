# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::Alias do
  subject(:cop) { described_class.new }

  it 'registers an offence for alias with symbol args' do
    inspect_source(cop,
                   ['alias :ala :bala'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use alias_method instead of alias.'])
  end

  it 'autocorrects alias with symbol args' do
    corrected = autocorrect_source(cop, ['alias :ala :bala'])
    expect(corrected).to eq 'alias_method :ala, :bala'
  end

  it 'registers an offence for alias with bareword args' do
    inspect_source(cop,
                   ['alias ala bala'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use alias_method instead of alias.'])
  end

  it 'autocorrects alias with bareword args' do
    corrected = autocorrect_source(cop, ['alias ala bala'])
    expect(corrected).to eq 'alias_method :ala, :bala'
  end

  it 'does not register an offence for alias_method' do
    inspect_source(cop,
                   ['alias_method :ala, :bala'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for :alias' do
    inspect_source(cop,
                   ['[:alias, :ala, :bala]'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for alias with gvars' do
    inspect_source(cop,
                   ['alias $ala $bala'])
    expect(cop.offences).to be_empty
  end

  it 'accepts alias in an instance_exec block' do
    inspect_source(cop,
                   ['cli.instance_exec do',
                    '  alias :old_trap_interrupt :trap_interrupt',
                    'end'])
    expect(cop.offences).to be_empty
  end
end
