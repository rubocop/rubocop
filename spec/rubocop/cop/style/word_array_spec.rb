# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::WordArray do
  subject(:cop) { described_class.new }

  it 'registers an offence for arrays of single quoted strings' do
    inspect_source(cop,
                   ["['one', 'two', 'three']"])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for arrays of double quoted strings' do
    inspect_source(cop,
                   ['["one", "two", "three"]'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for arrays with character constants' do
    inspect_source(cop,
                   ['["one", ?\n]'])
    expect(cop.offences.size).to eq(1)
  end

  it 'does not register an offence for array of non-words' do
    inspect_source(cop,
                   ['["one space", "two", "three"]'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for array containing non-string' do
    inspect_source(cop,
                   ['["one", "two", 3]'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for array starting with %w' do
    inspect_source(cop,
                   ['%w(one two three)'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for array with one element' do
    inspect_source(cop,
                   ['["three"]'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for array with empty strings' do
    inspect_source(cop,
                   ['["", "two", "three"]'])
    expect(cop.offences).to be_empty
  end
end
