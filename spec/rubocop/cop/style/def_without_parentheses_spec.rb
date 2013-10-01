# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::DefWithoutParentheses do
  subject(:cop) { described_class.new }

  it 'reports an offence for def with parameters but no parens' do
    src = ['def func a, b',
           'end']
    inspect_source(cop, src)
    expect(cop.offences.size).to eq(1)
  end

  it 'reports an offence for class def with parameters but no parens' do
    src = ['def Test.func a, b',
           'end']
    inspect_source(cop, src)
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts def with no args and no parens' do
    src = ['def func',
           'end']
    inspect_source(cop, src)
    expect(cop.offences).to be_empty
  end

  it 'auto-adds required parens' do
    new_source = autocorrect_source(cop, 'def test param; end')
    expect(new_source).to eq('def test (param); end')
  end
end
