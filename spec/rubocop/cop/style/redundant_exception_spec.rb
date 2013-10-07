# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::RedundantException do
  subject(:cop) { described_class.new }

  it 'reports an offence for a raise with RuntimeError' do
    inspect_source(cop, ['raise RuntimeError, msg'])
    expect(cop.offences.size).to eq(1)
  end

  it 'reports an offence for a fail with RuntimeError' do
    inspect_source(cop, ['fail RuntimeError, msg'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts a raise with RuntimeError if it does not have 2 args' do
    inspect_source(cop, ['raise RuntimeError, msg, caller'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a fail with RuntimeError if it does not have 2 args' do
    inspect_source(cop, ['fail RuntimeError, msg, caller'])
    expect(cop.offences).to be_empty
  end
end
