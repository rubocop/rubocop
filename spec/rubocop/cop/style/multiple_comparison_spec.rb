# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultipleComparison do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  MSG = 'Avoid comparing a variable with multiple items' \
    'in a conditional, use Array#include? instead.'.freeze

  it 'accepts' do
    inspect_source(cop, ['a = "a"',
                         'if a == "a"',
                         '  print a',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for offending code' do
    inspect_source(cop, ['a = "a"',
                         'if a == "a" || a == "b"',
                         '  print a',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq([MSG])
  end

  it 'registers an offense for offending code' do
    inspect_source(cop, ['a = "a"',
                         'if a == "a" || a == "b" || a == "c"',
                         '  print a',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq([MSG])
  end

  it 'registers an offense for offending code' do
    inspect_source(cop, ['a = "a"',
                         'if "a" == a || "b" == a || "c" == a',
                         '  print a',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq([MSG])
  end

  it 'registers an offense for offending code' do
    inspect_source(cop, ['a = "a"',
                         'if a == "a" || "b" == a || a == "c"',
                         '  print a',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq([MSG])
  end

  it 'accepts' do
    inspect_source(cop, ['if "a" == "a" || "a" == "c"',
                         '  print "a"',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts' do
    inspect_source(cop, ['if 1 == 1 || 1 == 2',
                         '  print 1',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts' do
    inspect_source(cop, ['a = "a"',
                         'b = "b"',
                         'if a == "a" || b == "b"',
                         '  print a',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts' do
    inspect_source(cop, ['a = "a"',
                         'b = "b"',
                         'if a == "a" || "b" == b',
                         '  print a',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts' do
    inspect_source(cop, ['a = "a"',
                         'b = "b"',
                         'if a == b || b == a',
                         '  print a',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts' do
    inspect_source(cop, ['a = "a"',
                         'b = "b"',
                         'if a == b || a == b',
                         '  print a',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts' do
    inspect_source(cop, ['a = "a"',
                         'if ["a", "b", "c"].include? a',
                         '  print a',
                         'end'])
    expect(cop.offenses).to be_empty
  end
end
