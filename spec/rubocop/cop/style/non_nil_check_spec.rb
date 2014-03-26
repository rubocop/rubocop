# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::NonNilCheck do
  subject(:cop) { described_class.new }

  it 'registers an offense for != nil' do
    inspect_source(cop, 'x != nil')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['!='])
  end

  it 'registers an offense for !x.nil?' do
    inspect_source(cop, '!x.nil?')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['!x.nil?'])
  end

  it 'registers an offense for not x.nil?' do
    inspect_source(cop, 'not x.nil?')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['not x.nil?'])
  end

  it 'autocorrects by removing != nil' do
    corrected = autocorrect_source(cop, 'x != nil')
    expect(corrected).to eq 'x'
  end

  it 'autocorrects by removing non-nil (!x.nil?) check' do
    corrected = autocorrect_source(cop, '!x.nil?')
    expect(corrected).to eq 'x'
  end
end
