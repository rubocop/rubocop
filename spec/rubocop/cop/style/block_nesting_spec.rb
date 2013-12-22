# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::BlockNesting, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 2 } }

  it 'accepts `Max` levels of nesting' do
    source = ['if a',
              '  if b',
              '    puts b',
              '  end',
              'end']
    expect_nesting_offences(source, [])
  end

  it 'registers an offence for `Max + 1` levels of `if` nesting' do
    source = ['if a',
              '  if b',
              '    if c',
              '      puts c',
              '    end',
              '  end',
              'end']
    expect_nesting_offences(source, [3])
  end

  it 'registers a single offence for `Max + 2` levels of `if` nesting' do
    source = ['if a',
              '  if b',
              '    if c',
              '      if d',
              '        puts d',
              '      end',
              '    end',
              '  end',
              'end']
    expect_nesting_offences(source, [3])
  end

  it 'registers 2 offences' do
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
    expect_nesting_offences(source, [3, 8])
  end

  it 'registers an offence for nested `case`' do
    source = ['if a',
              '  if b',
              '    case c',
              '      when C',
              '        puts C',
              '    end',
              '  end',
              'end']
    expect_nesting_offences(source, [3])
  end

  it 'registers an offence for nested `while`' do
    source = ['if a',
              '  if b',
              '    while c',
              '      puts c',
              '    end',
              '  end',
              'end']
    expect_nesting_offences(source, [3])
  end

  it 'registers an offence for nested modifier `while`' do
    source = ['if a',
              '  if b',
              '    begin',
              '      puts c',
              '    end while c',
              '  end',
              'end']
    expect_nesting_offences(source, [3])
  end

  it 'registers an offence for nested `until`' do
    source = ['if a',
              '  if b',
              '    until c',
              '      puts c',
              '    end',
              '  end',
              'end']
    expect_nesting_offences(source, [3])
  end

  it 'registers an offence for nested modifier `until`' do
    source = ['if a',
              '  if b',
              '    begin',
              '      puts c',
              '    end until c',
              '  end',
              'end']
    expect_nesting_offences(source, [3])
  end

  it 'registers an offence for nested `for`' do
    source = ['if a',
              '  if b',
              '    for c in [1,2] do',
              '      puts c',
              '    end',
              '  end',
              'end']
    expect_nesting_offences(source, [3])
  end

  it 'registers an offence for nested `rescue`' do
    source = ['if a',
              '  if b',
              '    begin',
              '      puts c',
              '    rescue',
              '      puts x',
              '    end',
              '  end',
              'end']
    expect_nesting_offences(source, [5])
  end

  it 'accepts if/elsif' do
    source = ['if a',
              'elsif b',
              'elsif c',
              'elsif d',
              'end']
    expect_nesting_offences(source, [])
  end

  def expect_nesting_offences(source, lines, used_nesting_level = 3)
    inspect_source(cop, source)
    expect(cop.offences.map(&:line)).to eq(lines)
    expect(cop.messages).to eq(
      ['Avoid more than 2 levels of block nesting.'] * lines.length)
    if cop.offences.size > 0
      expect(cop.config_to_allow_offences['Max']).to eq(used_nesting_level)
    end
  end
end
