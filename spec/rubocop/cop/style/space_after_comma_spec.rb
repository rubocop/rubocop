# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceAfterComma do
  subject(:cop) { described_class.new }

  it 'registers an offence for block argument commas without space' do
    inspect_source(cop, ['each { |s,t| }'])
    expect(cop.messages).to eq(
      ['Space missing after comma.'])
  end

  it 'registers an offence for array index commas without space' do
    inspect_source(cop, ['formats[0,1]'])
    expect(cop.messages).to eq(
      ['Space missing after comma.'])
  end

  it 'registers an offence for method call arg commas without space' do
    inspect_source(cop, ['a(1,2)'])
    expect(cop.messages).to eq(
      ['Space missing after comma.'])
  end
end
