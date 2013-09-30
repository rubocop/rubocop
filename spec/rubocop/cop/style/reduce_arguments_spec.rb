# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::ReduceArguments do
  subject(:cop) { described_class.new }

  it 'find wrong argument names in calls with different syntax' do
    inspect_source(cop,
                   ['def m',
                    '  [0, 1].reduce { |c, d| c + d }',
                    '  [0, 1].reduce{ |c, d| c + d }',
                    '  [0, 1].reduce(5) { |c, d| c + d }',
                    '  [0, 1].reduce(5){ |c, d| c + d }',
                    '  [0, 1].reduce (5) { |c, d| c + d }',
                    '  [0, 1].reduce(5) { |c, d| c + d }',
                    'end'])
    expect(cop.offences.size).to eq(6)
    expect(cop.offences.map(&:line).sort).to eq((2..7).to_a)
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
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'ignores do..end blocks' do
    inspect_source(cop,
                   ['def m',
                    '  [0, 1].reduce do |c, d|',
                    '    c + d',
                    '  end',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'ignores :reduce symbols' do
    inspect_source(cop,
                   ['def m',
                    '  call_method(:reduce) { |a, b| a + b}',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'does not report when destructuring is used' do
    inspect_source(cop,
                   ['def m',
                    '  test.reduce { |a, (id, _)| a + id}',
                    'end'])
    expect(cop.offences).to be_empty
  end
end
