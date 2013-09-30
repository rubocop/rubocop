# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::For do
  subject(:cop) { described_class.new }

  it 'registers an offence for for' do
    inspect_source(cop,
                   ['def func',
                    '  for n in [1, 2, 3] do',
                    '    puts n',
                    '  end',
                    'end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'does not register an offence for :for' do
    inspect_source(cop, ['[:for, :ala, :bala]'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for def for' do
    inspect_source(cop, ['def for; end'])
    expect(cop.offences).to be_empty
  end
end
