# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MethodCallParentheses do
  subject(:cop) { described_class.new }

  it 'registers an offense for parens in method call without args' do
    inspect_source(cop, 'top.test()')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts parentheses for methods starting with an upcase letter' do
    inspect_source(cop, 'Test()')
    expect(cop.offenses).to be_empty
  end

  it 'accepts no parens in method call without args' do
    inspect_source(cop, 'top.test')
    expect(cop.offenses).to be_empty
  end

  it 'accepts parens in method call with args' do
    inspect_source(cop, 'top.test(a)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts special lambda call syntax' do
    # Style/LambdaCall checks for this syntax
    inspect_source(cop, 'thing.()')
    expect(cop.offenses).to be_empty
  end

  context 'assignment to a variable with the same name' do
    it 'accepts parens in local variable assignment ' do
      inspect_source(cop, 'test = test()')
      expect(cop.offenses).to be_empty
    end

    it 'accepts parens in shorthand assignment' do
      inspect_source(cop, 'test ||= test()')
      expect(cop.offenses).to be_empty
    end

    it 'accepts parens in parallel assignment' do
      inspect_source(cop, 'one, test = 1, test()')
      expect(cop.offenses).to be_empty
    end

    it 'accepts parens in complex assignment' do
      inspect_source(cop, ['test = begin',
                           '  case a',
                           '  when b',
                           '    c = test() if d',
                           '  end',
                           'end'])
      expect(cop.offenses).to be_empty
    end
  end

  it 'registers an offense for `obj.method ||= func()`' do
    inspect_source(cop, 'obj.method ||= func()')
    expect(cop.offenses.size).to eq 1
  end

  it 'registers an offense for `obj.method &&= func()`' do
    inspect_source(cop, 'obj.method &&= func()')
    expect(cop.offenses.size).to eq 1
  end

  it 'auto-corrects by removing unneeded braces' do
    new_source = autocorrect_source(cop, 'test()')
    expect(new_source).to eq('test')
  end

  # These will be offenses for the EmptyLiteral cop. The autocorrect loop will
  # handle that.
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
