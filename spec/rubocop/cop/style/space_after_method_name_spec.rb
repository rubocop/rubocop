# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceAfterMethodName do
  subject(:cop) { described_class.new }

  it 'registers an offence for def with space before the parenthesis' do
    inspect_source(cop,
                   ['def func (x)',
                    '  a',
                    'end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for defs with space before the parenthesis' do
    inspect_source(cop,
                   ['def self.func (x)',
                    '  a',
                    'end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts a def without arguments' do
    inspect_source(cop,
                   ['def func',
                    '  a',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a defs without arguments' do
    inspect_source(cop,
                   ['def self.func',
                    '  a',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a def with arguments but no parentheses' do
    inspect_source(cop,
                   ['def func x',
                    '  a',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'accepts a defs with arguments but no parentheses' do
    inspect_source(cop,
                   ['def self.func x',
                    '  a',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'auto-corrects unwanted space' do
    new_source = autocorrect_source(cop, ['def func (x)',
                                          '  a',
                                          'end',
                                          'def self.func (x)',
                                          '  a',
                                          'end'])
    expect(new_source).to eq(['def func(x)',
                              '  a',
                              'end',
                              'def self.func(x)',
                              '  a',
                              'end'].join("\n"))
  end
end
