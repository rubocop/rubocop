# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultipleComparison do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'accepts' do
    inspect_source(['a = "a"',
                    'if a == "a"',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'registers an offense for offending code' do
    inspect_source(['a = "a"',
                    'if a == "a" || a == "b"',
                    '  print a',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for offending code' do
    inspect_source(['a = "a"',
                    'if a == "a" || a == "b" || a == "c"',
                    '  print a',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for offending code' do
    inspect_source(['a = "a"',
                    'if "a" == a || "b" == a || "c" == a',
                    '  print a',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for offending code' do
    inspect_source(['a = "a"',
                    'if a == "a" || "b" == a || a == "c"',
                    '  print a',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts' do
    inspect_source(['if "a" == "a" || "a" == "c"',
                    '  print "a"',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'accepts' do
    inspect_source(['if 1 == 1 || 1 == 2',
                    '  print 1',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'accepts' do
    inspect_source(['a = "a"',
                    'b = "b"',
                    'if a == "a" || b == "b"',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'accepts' do
    inspect_source(['a = "a"',
                    'b = "b"',
                    'if a == "a" || "b" == b',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'accepts' do
    inspect_source(['a = "a"',
                    'b = "b"',
                    'if a == b || b == a',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'accepts' do
    inspect_source(['a = "a"',
                    'b = "b"',
                    'if a == b || a == b',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'accepts' do
    inspect_source(['a = "a"',
                    'if ["a", "b", "c"].include? a',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end
end
