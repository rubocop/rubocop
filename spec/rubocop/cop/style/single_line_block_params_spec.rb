# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SingleLineBlockParams, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) do
    { 'Methods' =>
      [{ 'reduce' => %w(a e) },
       { 'test' => %w(x y) }] }
  end

  it 'finds wrong argument names in calls with different syntax' do
    inspect_source(cop,
                   ['def m',
                    '  [0, 1].reduce { |c, d| c + d }',
                    '  [0, 1].reduce{ |c, d| c + d }',
                    '  [0, 1].reduce(5) { |c, d| c + d }',
                    '  [0, 1].reduce(5){ |c, d| c + d }',
                    '  [0, 1].reduce (5) { |c, d| c + d }',
                    '  [0, 1].reduce(5) { |c, d| c + d }',
                    '  ala.test { |x, z| bala }',
                    'end'])
    expect(cop.offenses.size).to eq(7)
    expect(cop.offenses.map(&:line).sort).to eq((2..8).to_a)
    expect(cop.messages.first)
      .to eq('Name `reduce` block params `|a, e|`.')
  end

  it 'allows calls with proper argument names' do
    inspect_source(cop,
                   ['def m',
                    '  [0, 1].reduce { |a, e| a + e }',
                    '  [0, 1].reduce{ |a, e| a + e }',
                    '  [0, 1].reduce(5) { |a, e| a + e }',
                    '  [0, 1].reduce(5){ |a, e| a + e }',
                    '  [0, 1].reduce (5) { |a, e| a + e }',
                    '  [0, 1].reduce(5) { |a, e| a + e }',
                    '  ala.test { |x, y| bala }',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'allows an unused parameter to have a leading underscore' do
    inspect_source(cop,
                   'File.foreach(filename).reduce(0) { |a, _e| a + 1 }')
    expect(cop.offenses).to be_empty
  end

  it 'finds incorrectly named parameters with leading underscores' do
    inspect_source(cop,
                   'File.foreach(filename).reduce(0) { |_x, _y| }')
    expect(cop.messages).to eq(['Name `reduce` block params `|a, e|`.'])
  end

  it 'ignores do..end blocks' do
    inspect_source(cop,
                   ['def m',
                    '  [0, 1].reduce do |c, d|',
                    '    c + d',
                    '  end',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores :reduce symbols' do
    inspect_source(cop,
                   ['def m',
                    '  call_method(:reduce) { |a, b| a + b}',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not report when destructuring is used' do
    inspect_source(cop,
                   ['def m',
                    '  test.reduce { |a, (id, _)| a + id}',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not report if no block arguments are present' do
    inspect_source(cop,
                   ['def m',
                    '  test.reduce { true }',
                    'end'])
    expect(cop.offenses).to be_empty
  end
end
