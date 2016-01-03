# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::EachWithObject do
  subject(:cop) { described_class.new }

  it 'finds inject and reduce with passed in and returned hash' do
    inspect_source(cop,
                   ['[].inject({}) { |a, e| a }',
                    '',
                    '[].reduce({}) do |a, e|',
                    '  a[e] = 1',
                    '  a[e] = 1',
                    '  a',
                    'end'])
    expect(cop.offenses.size).to eq(2)
    expect(cop.offenses.map(&:line).sort).to eq([1, 3])
    expect(cop.messages)
      .to eq(['Use `each_with_object` instead of `inject`.',
              'Use `each_with_object` instead of `reduce`.'])
    expect(cop.highlights).to eq(%w(inject reduce))
  end

  it 'ignores inject and reduce with passed in, but not returned hash' do
    inspect_source(cop,
                   ['[].inject({}) do |a, e|',
                    '  a + e',
                    'end',
                    '',
                    '[].reduce({}) do |a, e|',
                    '  my_method e, a',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores inject and reduce with empty body' do
    inspect_source(cop,
                   ['[].inject({}) do |a, e|',
                    'end',
                    '',
                    '[].reduce({}) { |a, e| }'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores inject and reduce with condition as body' do
    inspect_source(cop,
                   ['[].inject({}) do |a, e|',
                    '  a = e if e',
                    'end',
                    '',
                    '[].inject({}) do |a, e|',
                    '  if e',
                    '    a = e',
                    '  end',
                    'end',
                    '',
                    '[].reduce({}) do |a, e|',
                    '  a = e ? e : 2',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores inject and reduce passed in symbol' do
    inspect_source(cop, '[].inject(:+)', '[].reduce(:+)')
    expect(cop.offenses).to be_empty
  end

  it 'does not blow up for reduce with no arguments' do
    inspect_source(cop, '[1, 2, 3].inject { |a, e| a + e }')
    expect(cop.offenses).to be_empty
  end

  it 'ignores inject/reduce with assignment to accumulator param in block' do
    inspect_source(cop, ['r = [1, 2, 3].reduce(0) do |memo, item|',
                         '  memo += item > 2 ? item : 0',
                         '  memo',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  context 'when a simple literal is passed as initial value' do
    it 'ignores inject/reduce' do
      inspect_source(cop, 'array.reduce(0) { 1 }')
      expect(cop.offenses).to be_empty
    end
  end
end
