# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::RedundantException do
  subject(:cop) { described_class.new }

  it 'reports an offense for a raise with RuntimeError' do
    inspect_source(cop, ['raise RuntimeError, msg'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for a fail with RuntimeError' do
    inspect_source(cop, ['fail RuntimeError, msg'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a raise with RuntimeError if it does not have 2 args' do
    inspect_source(cop, ['raise RuntimeError, msg, caller'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts a fail with RuntimeError if it does not have 2 args' do
    inspect_source(cop, ['fail RuntimeError, msg, caller'])
    expect(cop.offenses).to be_empty
  end
end
