# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::Next, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'MinBodyLength' => 1 } }

  it 'finds all kind of loops with condition at the end of the iteration' do
    # TODO: Split this long example into multiple examples.
    inspect_source(cop,
                   ['3.downto(1) do',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    '[].each do |o|',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    '[].each_with_object({}) do |o, a|',
                    '  if o == 1',
                    '    a[o] = {}',
                    '  end',
                    'end',
                    '',
                    'for o in 1..3 do',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    'loop do',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    '{}.map do |k, v|',
                    '  if v == 1',
                    '    puts k',
                    '  end',
                    'end',
                    '',
                    '3.times do |o|',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    'until false',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    'while true',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(9)
    expect(cop.offenses.map(&:line).sort).to eq([1, 7, 13, 19, 25, 31, 37, 43,
                                                 49])
    expect(cop.messages) .to eq(['Use `next` to skip iteration.'] * 9)
    expect(cop.highlights).to eq(%w(downto each each_with_object for loop map
                                    times until while))
  end

  it 'finds loop with condition at the end in different styles' do
    inspect_source(cop,
                   ['[].each do |o|',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    '[].each do |o|',
                    '  puts o',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    '[].each do |o|',
                    '  unless o == 1',
                    '    puts o',
                    '  end',
                    'end'])

    expect(cop.offenses.size).to eq(3)
    expect(cop.offenses.map(&:line).sort).to eq([1, 7, 14])
    expect(cop.messages)
      .to eq(['Use `next` to skip iteration.'] * 3)
    expect(cop.highlights).to eq(['each'] * 3)
  end

  it 'ignores empty blocks' do
    inspect_source(cop,
                   ['[].each do', 'end',
                    '[].each { }'])
    expect(cop.offenses.size).to eq(0)
  end

  it 'ignores loops with conditional break' do
    inspect_source(cop,
                   ['loop do',
                    "  puts ''",
                    '  break if o == 1',
                    'end',
                    '',
                    'loop do',
                    '  break if o == 1',
                    'end',
                    '',
                    'loop do',
                    "  puts ''",
                    '  break unless o == 1',
                    'end',
                    '',
                    'loop do',
                    '  break unless o == 1',
                    'end',
                    '',
                    'loop do',
                    '  if o == 1',
                    '    break',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(0)
  end

  it 'ignores loops with conditional return' do
    inspect_source(cop,
                   ['loop do',
                    "  puts ''",
                    '  return if o == 1',
                    'end',
                    '',
                    'loop do',
                    "  puts ''",
                    '  if o == 1',
                    '    return',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(0)
  end

  context 'EnforcedStyle: skip_modifier_ifs' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'skip_modifier_ifs' }
    end

    it 'ignores modifier ifs' do
      inspect_source(cop,
                     ['[].each do |o|',
                      '  puts o if o == 1',
                      'end',
                      '',
                      '[].each do |o|',
                      '  puts o unless o == 1',
                      'end'])

      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'EnforcedStyle: always' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'always' }
    end

    it 'does not ignore modifier ifs' do
      inspect_source(cop,
                     ['[].each do |o|',
                      '  puts o if o == 1',
                      'end',
                      '',
                      '[].each do |o|',
                      '  puts o unless o == 1',
                      'end'])

      expect(cop.offenses.size).to eq(2)
      expect(cop.offenses.map(&:line).sort).to eq([1, 5])
      expect(cop.messages)
        .to eq(['Use `next` to skip iteration.'] * 2)
      expect(cop.highlights).to eq(['each'] * 2)
    end
  end

  it 'ignores loops with conditions at the end with else' do
    inspect_source(cop,
                   ['[].each do |o|',
                    '  if o == 1',
                    '    puts o',
                    '  else',
                    "    puts 'no'",
                    '  end',
                    'end',
                    '',
                    '[].each do |o|',
                    '  puts o',
                    '  if o == 1',
                    '    puts o',
                    '  else',
                    "    puts 'no'",
                    '  end',
                    'end',
                    '',
                    '[].each do |o|',
                    '  unless o == 1',
                    '    puts o',
                    '  else',
                    "    puts 'no'",
                    '  end',
                    'end'])

    expect(cop.offenses.size).to eq(0)
  end

  it 'ignores loops with conditions at the end with ternary op' do
    inspect_source(cop,
                   ['[].each do |o|',
                    '  o == x ? y : z',
                    'end'
                   ])

    expect(cop.offenses.size).to eq(0)
  end

  # https://github.com/bbatsov/rubocop/issues/1115
  it 'ignores super nodes' do
    inspect_source(cop,
                   ['def foo',
                    '  super(a, a) { a }',
                    'end'])
    expect(cop.offenses.size).to eq(0)
  end

  it 'does not blow up on empty body until block' do
    inspect_source(cop, 'until sup; end')
    expect(cop.offenses.size).to eq(0)
  end

  it 'does not crash with an empty body branch' do
    inspect_source(cop,
                   ['loop do',
                    '  if true',
                    '  end',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  context 'MinBodyLength: 3' do
    let(:cop_config) do
      { 'MinBodyLength' => 3 }
    end

    it 'accepts if whose body has 1 line' do
      inspect_source(cop,
                     ['arr.each do |e|',
                      '  if something',
                      '    work',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'reports an offense for if whose body has 3 lines' do
      inspect_source(cop,
                     ['arr.each do |e|',
                      '  if something',
                      '    work',
                      '    work',
                      '    work',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['each'])
    end
  end

  context 'Invalid MinBodyLength' do
    let(:cop_config) do
      { 'MinBodyLength' => -2 }
    end

    it 'fails with an error' do
      source = ['loop do',
                '  if o == 1',
                '    puts o',
                '  end',
                'end']
      expect { inspect_source(cop, source) }
        .to raise_error('MinBodyLength needs to be a positive integer!')
    end
  end
end
