# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::GuardClause do
  let(:cop) { described_class.new }

  it 'reports an offense if method body is if without else' do
    src = ['def func',
           '  if something',
           '    work',
           '    work_more',
           '  end',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense if method body ends with if without else' do
    src = ['def func',
           '  test',
           '  if something',
           '    work',
           '    work_more',
           '  end',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a method which body is if with else' do
    src = ['def func',
           '  if something',
           '    work',
           '    work_more',
           '  else',
           '    test',
           '  end',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a method which body does not end with if' do
    src = ['def func',
           '  if something',
           '    work',
           '    work_more',
           '  end',
           '  test',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a method which body does not end with if' do
    src = ['def func',
           '  if something',
           '    work',
           '    work_more',
           '  end',
           '  test',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a method whose body is an if with a one-line body' do
    src = ['def func',
           '  if something',
           '    work',
           '  end',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end
end
