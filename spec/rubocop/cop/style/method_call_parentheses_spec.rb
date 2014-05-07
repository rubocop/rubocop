# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::MethodCallParentheses, :config do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    Rubocop::Config.new(
      'EmptyLiteral' => { 'Enabled' => empty_literal_enabled },
      'MethodCallParentheses' => { 'RequireNoParentheses' => ['include'] }
    )
  end
  let(:empty_literal_enabled) { true }

  it 'registers an offense for parens in method call without args' do
    inspect_source(cop, ['top.test()'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts parentheses for methods starting with an upcase letter' do
    inspect_source(cop, ['Test()'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts no parens in method call without args' do
    inspect_source(cop, ['top.test'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts parens in method call with args' do
    inspect_source(cop, ['top.test(a)'])
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects by removing unneeded braces' do
    new_source = autocorrect_source(cop, 'test()')
    expect(new_source).to eq('test')
  end

  it 'detects DSL methods with parentheses' do
    inspect_source(cop, ['  include("bar")']) # spaces are on purpose
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages) .to eq(['Omit parentheses for DSL method calls.'])
    expect(cop.highlights).to eq(['include("bar")'])
  end

  it 'ignores DSL methods without parentheses' do
    inspect_source(cop, ['include "bar"'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores custom methods with names like DSL methods' do
    inspect_source(cop, ['include = foo.include("bar")',
                         'should include("bar")'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores method calls with operators' do
    inspect_source(cop, ['foo = "bar"', 'foo * 100', 'foo << bar'])
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects by removing braces from DSL methods' do
    new_source = autocorrect_source(cop, 'include("foo")')
    expect(new_source).to eq('include "foo"')
  end

  it 'does not auto-correct calls that will be changed to empty literals' do
    original = ['Hash.new()',
                'Array.new()',
                'String.new()']
    new_source = autocorrect_source(cop, original)
    expect(new_source).to eq(original.join("\n"))
  end

  context 'when EmptyLiteral is disabled' do
    let(:empty_literal_enabled) { false }

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
