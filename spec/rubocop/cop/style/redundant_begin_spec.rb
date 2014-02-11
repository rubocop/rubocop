# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::RedundantBegin do
  subject(:cop) { described_class.new }

  it 'reports an offense for def with redundant begin block' do
    src = ['def func',
           '  begin',
           '    ala',
           '  rescue => e',
           '    bala',
           '  end',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for defs with redundant begin block' do
    src = ['def Test.func',
           '  begin',
           '    ala',
           '  rescue => e',
           '    bala',
           '  end',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a def with required begin block' do
    src = ['def func',
           '  begin',
           '    ala',
           '  rescue => e',
           '    bala',
           '  end',
           '  something',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts a defs with required begin block' do
    src = ['def Test.func',
           '  begin',
           '    ala',
           '  rescue => e',
           '    bala',
           '  end',
           '  something',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end
end
