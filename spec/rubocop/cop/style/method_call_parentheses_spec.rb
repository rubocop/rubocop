# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::MethodCallParentheses, :config do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    Rubocop::Config.new('EmptyLiteral' => { 'Enabled' => true })
  end

  it 'registers an offence for parens in method call without args' do
    inspect_source(cop, ['top.test()'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts parentheses for methods starting with an upcase letter' do
    inspect_source(cop, ['Test()'])
    expect(cop.offences).to be_empty
  end

  it 'accepts no parens in method call without args' do
    inspect_source(cop, ['top.test'])
    expect(cop.offences).to be_empty
  end

  it 'accepts parens in method call with args' do
    inspect_source(cop, ['top.test(a)'])
    expect(cop.offences).to be_empty
  end

  it 'auto-corrects by removing unneeded braces' do
    new_source = autocorrect_source(cop, 'test()')
    expect(new_source).to eq('test')
  end

  it 'does not auto-correct calls that will be changed to empty literals' do
    original = ['Hash.new()',
                'Array.new()',
                'String.new()']
    new_source = autocorrect_source(cop, original)
    expect(new_source).to eq(original.join("\n"))
  end

  context 'when EmptyLiteral is disabled' do
    let(:config) do
      Rubocop::Config.new('EmptyLiteral' => { 'Enabled' => false })
    end

    it 'auto-corrects calls that could be empty literals' do
      original = ['Hash.new()',
                  'Array.new()',
                  'String.new()']
      new_source = autocorrect_source(cop, original)
      expect(new_source).to eq(['Hash.new',
                                'Array.new',
                                'String.new'].join("\n"))
    end
  end
end
