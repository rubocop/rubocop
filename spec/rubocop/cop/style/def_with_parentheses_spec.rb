# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::DefWithParentheses do
  subject(:cop) { described_class.new }

  it 'reports an offence for def with empty parens' do
    src = ['def func()',
           'end']
    inspect_source(cop, src)
    expect(cop.offences.size).to eq(1)
  end

  it 'reports an offence for class def with empty parens' do
    src = ['def Test.func()',
           'end']
    inspect_source(cop, src)
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts def with arg and parens' do
    src = ['def func(a)',
           'end']
    inspect_source(cop, src)
    expect(cop.offences).to be_empty
  end

  it 'accepts empty parentheses in one liners' do
    src = ["def to_s() join '/' end"]
    inspect_source(cop, src)
    expect(cop.offences).to be_empty
  end

  it 'auto-removes unneeded parens' do
    new_source = autocorrect_source(cop, "def test();\nsomething\nend")
    expect(new_source).to eq("def test;\nsomething\nend")
  end
end
