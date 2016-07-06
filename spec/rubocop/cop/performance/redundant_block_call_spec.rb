# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::RedundantBlockCall do
  subject(:cop) { described_class.new }

  it 'autocorrects block.call without arguments' do
    new_source = autocorrect_source(cop, ['def method(&block)',
                                          '  block.call',
                                          'end'])
    expect(new_source).to eq(['def method(&block)',
                              '  yield',
                              'end'].join("\n"))
  end

  it 'autocorrects block.call with empty parentheses' do
    new_source = autocorrect_source(cop, ['def method(&block)',
                                          '  block.call()',
                                          'end'])
    expect(new_source).to eq(['def method(&block)',
                              '  yield',
                              'end'].join("\n"))
  end

  it 'autocorrects block.call with arguments' do
    new_source = autocorrect_source(cop, ['def method(&block)',
                                          '  block.call 1, 2',
                                          'end'])
    expect(new_source).to eq(['def method(&block)',
                              '  yield 1, 2',
                              'end'].join("\n"))
  end

  it 'autocorrects multiple occurances of block.call with arguments' do
    new_source = autocorrect_source(cop, ['def method(&block)',
                                          '  block.call 1',
                                          '  block.call 2',
                                          'end'])
    expect(new_source).to eq(['def method(&block)',
                              '  yield 1',
                              '  yield 2',
                              'end'].join("\n"))
  end

  it 'autocorrects even when block arg has a different name' do
    new_source = autocorrect_source(cop, ['def method(&func)',
                                          '  func.call',
                                          'end'])
    expect(new_source).to eq(['def method(&func)',
                              '  yield',
                              'end'].join("\n"))
  end

  it 'accepts a block that is not `call`ed' do
    inspect_source(cop, ['def method(&block)',
                         ' something.call',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'accepts an empty method body' do
    inspect_source(cop, ['def method(&block)',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'accepts another block being passed as the only arg' do
    inspect_source(cop, ['def method(&block)',
                         '  block.call(&some_proc)',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'accepts another block being passed along with other args' do
    inspect_source(cop, ['def method(&block)',
                         '  block.call(1, &some_proc)',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'accepts another block arg in at least one occurance of block.call' do
    inspect_source(cop, ['def method(&block)',
                         '  block.call(1, &some_proc)',
                         '  block.call(2)',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'accepts an optional block that is defaulted' do
    inspect_source(cop, ['def method(&block)',
                         '  block ||= ->(i) { puts i }',
                         '  block.call(1)',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'accepts an optional block that is overridden' do
    inspect_source(cop, ['def method(&block)',
                         '  block = ->(i) { puts i }',
                         '  block.call(1)',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'formats the error message for func.call(1) correctly' do
    inspect_source(cop, ['def method(&func)',
                         '  func.call(1)',
                         'end'])
    expect(cop.messages).to eq(['Use `yield` instead of `func.call`.'])
  end

  it 'autocorrects using parentheses when block.call uses parentheses' do
    new_source = autocorrect_source(cop, ['def method(&block)',
                                          '  block.call(a, b)',
                                          'end'])

    expect(new_source).to eq(['def method(&block)',
                              '  yield(a, b)',
                              'end'].join("\n"))
  end

  it 'autocorrects when the result of the call is used in a scope that ' \
     'requires parentheses' do
    source = ['def method(&block)',
              '  each_with_object({}) do |(key, value), acc|',
              '    acc.merge!(block.call(key) => rhs[value])',
              '  end',
              'end']

    new_source = autocorrect_source(cop, source)

    expect(new_source).to eq(['def method(&block)',
                              '  each_with_object({}) do |(key, value), acc|',
                              '    acc.merge!(yield(key) => rhs[value])',
                              '  end',
                              'end'].join("\n"))
  end
end
