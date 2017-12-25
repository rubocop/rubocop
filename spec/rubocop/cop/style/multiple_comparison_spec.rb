# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Style::MultipleComparison do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'does not register an offense for comparing an lvar' do
    inspect_source(['a = "a"',
                    'if a == "a"',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'registers an offense when `a` is compared twice' do
    inspect_source(['a = "a"',
                    'if a == "a" || a == "b"',
                    '  print a',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when `a` is compared three times' do
    inspect_source(['a = "a"',
                    'if a == "a" || a == "b" || a == "c"',
                    '  print a',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when `a` is compared three times on the right ' \
    'hand side' do
    inspect_source(['a = "a"',
                    'if "a" == a || "b" == a || "c" == a',
                    '  print a',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when `a` is compared three times, once on the ' \
    'righthand side' do
    inspect_source(['a = "a"',
                    'if a == "a" || "b" == a || a == "c"',
                    '  print a',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for comparing multiple literal strings' do
    inspect_source(['if "a" == "a" || "a" == "c"',
                    '  print "a"',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'does not register an offense for comparing multiple int literals' do
    inspect_source(['if 1 == 1 || 1 == 2',
                    '  print 1',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'does not register an offense for comparing lvars' do
    inspect_source(['a = "a"',
                    'b = "b"',
                    'if a == "a" || b == "b"',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'does not register an offense for comparing lvars when a string is ' \
    'on the lefthand side' do
    inspect_source(['a = "a"',
                    'b = "b"',
                    'if a == "a" || "b" == b',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'does not register an offense for a == b || b == a' do
    inspect_source(['a = "a"',
                    'b = "b"',
                    'if a == b || b == a',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'does not register an offense for a duplicated condition' do
    inspect_source(['a = "a"',
                    'b = "b"',
                    'if a == b || a == b',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end

  it 'does not register an offense for Array#include?' do
    inspect_source(['a = "a"',
                    'if ["a", "b", "c"].include? a',
                    '  print a',
                    'end'])
    expect(cop.offenses.empty?).to be(true)
  end
end
