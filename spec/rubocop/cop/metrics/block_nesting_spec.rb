# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Metrics::BlockNesting, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 2 } }

  it 'accepts `Max` levels of nesting' do
    source = ['if a',
              '  if b',
              '    puts b',
              '  end',
              'end']
    expect_nesting_offenses(source, [])
  end

  it 'registers an offense for `Max + 1` levels of `if` nesting' do
    source = ['if a',
              '  if b',
              '    if c',
              '      puts c',
              '    end',
              '  end',
              'end']
    expect_nesting_offenses(source, [3])
  end

  it 'registers one offense for `Max + 2` levels of `if` nesting' do
    source = ['if a',
              '  if b',
              '    if c',
              '      if d',
              '        puts d',
              '      end',
              '    end',
              '  end',
              'end']
    expect_nesting_offenses(source, [3], 4)
  end

  it 'registers 2 offenses' do
    source = ['if a',
              '  if b',
              '    if c',
              '      puts c',
              '    end',
              '  end',
              '  if d',
              '    if e',
              '      puts e',
              '    end',
              '  end',
              'end']
    expect_nesting_offenses(source, [3, 8])
  end

  it 'registers an offense for nested `case`' do
    source = ['if a',
              '  if b',
              '    case c',
              '      when C',
              '        puts C',
              '    end',
              '  end',
              'end']
    expect_nesting_offenses(source, [3])
  end

  it 'registers an offense for nested `while`' do
    source = ['if a',
              '  if b',
              '    while c',
              '      puts c',
              '    end',
              '  end',
              'end']
    expect_nesting_offenses(source, [3])
  end

  it 'registers an offense for nested modifier `while`' do
    source = ['if a',
              '  if b',
              '    begin',
              '      puts c',
              '    end while c',
              '  end',
              'end']
    expect_nesting_offenses(source, [3])
  end

  it 'registers an offense for nested `until`' do
    source = ['if a',
              '  if b',
              '    until c',
              '      puts c',
              '    end',
              '  end',
              'end']
    expect_nesting_offenses(source, [3])
  end

  it 'registers an offense for nested modifier `until`' do
    source = ['if a',
              '  if b',
              '    begin',
              '      puts c',
              '    end until c',
              '  end',
              'end']
    expect_nesting_offenses(source, [3])
  end

  it 'registers an offense for nested `for`' do
    source = ['if a',
              '  if b',
              '    for c in [1,2] do',
              '      puts c',
              '    end',
              '  end',
              'end']
    expect_nesting_offenses(source, [3])
  end

  it 'registers an offense for nested `rescue`' do
    source = ['if a',
              '  if b',
              '    begin',
              '      puts c',
              '    rescue',
              '      puts x',
              '    end',
              '  end',
              'end']
    expect_nesting_offenses(source, [5])
  end

  it 'accepts if/elsif' do
    source = ['if a',
              'elsif b',
              'elsif c',
              'elsif d',
              'end']
    expect_nesting_offenses(source, [])
  end

  def expect_nesting_offenses(source, lines, max_to_allow = 3)
    inspect_source(cop, source)
    expect(cop.offenses.map(&:line)).to eq(lines)
    expect(cop.messages).to eq(
      ['Avoid more than 2 levels of block nesting.'] * lines.length)
    return if cop.offenses.empty?

    expect(cop.config_to_allow_offenses['Max']).to eq(max_to_allow)
  end
end
