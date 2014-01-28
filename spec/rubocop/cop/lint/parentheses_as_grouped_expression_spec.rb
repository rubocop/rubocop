# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::ParenthesesAsGroupedExpression do
  subject(:cop) { described_class.new }

  it 'registers an offence for method call with space before the ' \
    'parenthesis' do
    inspect_source(cop, ['a.func (x)'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for predicate method call with space ' \
    'before the parenthesis' do
    inspect_source(cop, ['is? (x)'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for math expression' do
    inspect_source(cop, ['puts (2 + 3) * 4'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts a method call without arguments' do
    inspect_source(cop, ['func'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a method call with arguments but no parentheses' do
    inspect_source(cop, ['puts x'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a chain of method calls' do
    inspect_source(cop, ['a.b',
                         'a.b 1',
                         'a.b(1)'])
    expect(cop.offences).to be_empty
  end

  it 'accepts method with parens as arg to method without' do
    inspect_source(cop, ['a b(c)'])
    expect(cop.offences).to be_empty
  end

  it 'accepts an operator call with argument in parentheses' do
    inspect_source(cop, ['a % (b + c)',
                         'a.b = (c == d)'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a space inside opening paren followed by left paren' do
    inspect_source(cop, ['a( (b) )'])
    expect(cop.offences).to be_empty
  end
end
