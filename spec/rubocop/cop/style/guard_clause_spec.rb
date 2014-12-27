# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::GuardClause, :config do
  let(:cop) { described_class.new(config) }
  let(:cop_config) { {} }

  it 'reports an offense if method body is if / unless without else' do
    inspect_source(cop,
                   ['def func',
                    '  if something',
                    '    work',
                    '  end',
                    'end',
                    '',
                    'def func',
                    '  unless something',
                    '    work',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(2)
    expect(cop.offenses.map(&:line).sort).to eq([2, 8])
    expect(cop.messages)
      .to eq(['Use a guard clause instead of wrapping ' \
              'the code inside a conditional expression.'] * 2)
    expect(cop.highlights).to eq(%w(if unless))
  end

  it 'reports an offense if method body ends with if / unless without else' do
    inspect_source(cop,
                   ['def func',
                    '  test',
                    '  if something',
                    '    work',
                    '  end',
                    'end',
                    '',
                    'def func',
                    '  test',
                    '  unless something',
                    '    work',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(2)
    expect(cop.offenses.map(&:line).sort).to eq([3, 10])
    expect(cop.messages)
      .to eq(['Use a guard clause instead of wrapping ' \
              'the code inside a conditional expression.'] * 2)
    expect(cop.highlights).to eq(%w(if unless))
  end

  it 'accepts a method which body is if / unless with else' do
    inspect_source(cop,
                   ['def func',
                    '  if something',
                    '    work',
                    '  else',
                    '    test',
                    '  end',
                    'end',
                    '',
                    'def func',
                    '  unless something',
                    '    work',
                    '  else',
                    '    test',
                    '  end',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts a method which body does not end with if / unless' do
    inspect_source(cop,
                   ['def func',
                    '  if something',
                    '    work',
                    '  end',
                    '  test',
                    'end',
                    '',
                    'def func',
                    '  unless something',
                    '    work',
                    '  end',
                    '  test',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts a method whose body is a modifier if / unless' do
    inspect_source(cop,
                   ['def func',
                    '  work if something',
                    'end',
                    '',
                    'def func',
                    '  work if something',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  context 'MinBodyLength: 1' do
    let(:cop_config) do
      { 'MinBodyLength' => 1 }
    end

    it 'reports an offense for if whose body has 1 line' do
      inspect_source(cop,
                     ['def func',
                      '  if something',
                      '    work',
                      '  end',
                      'end',
                      '',
                      'def func',
                      '  unless something',
                      '    work',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(2)
      expect(cop.offenses.map(&:line).sort).to eq([2, 8])
      expect(cop.messages)
        .to eq(['Use a guard clause instead of wrapping ' \
                'the code inside a conditional expression.'] * 2)
      expect(cop.highlights).to eq(%w(if unless))
    end
  end

  context 'MinBodyLength: 4' do
    let(:cop_config) do
      { 'MinBodyLength' => 4 }
    end

    it 'accepts a method whose body has 3 line' do
      inspect_source(cop,
                     ['def func',
                      '  if something',
                      '    work',
                      '    work',
                      '    work',
                      '  end',
                      'end',
                      '',
                      'def func',
                      '  unless something',
                      '    work',
                      '    work',
                      '    work',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'Invalid MinBodyLength' do
    let(:cop_config) do
      { 'MinBodyLength' => -2 }
    end

    it 'fails with an error' do
      source = ['def func',
                '  if something',
                '    work',
                '  end',
                'end']

      expect { inspect_source(cop, source) }
        .to raise_error('MinBodyLength needs to be a positive integer!')
    end
  end
end
