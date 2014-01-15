# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::FavorUntilOverNegatedWhile do
  subject(:cop) { described_class.new }

  it 'registers an offence for while with exclamation point condition' do
    inspect_source(cop,
                   ['while !a_condition',
                    '  some_method',
                    'end',
                    'some_method while !a_condition'
                   ])
    expect(cop.messages).to eq(
      ['Favor until over while for negative conditions.'] * 2)
  end

  it 'registers an offence for while with "not" condition' do
    inspect_source(cop,
                   ['while (not a_condition)',
                    '  some_method',
                    'end',
                    'some_method while not a_condition'])
    expect(cop.messages).to eq(
      ['Favor until over while for negative conditions.'] * 2)
    expect(cop.offences.map(&:line)).to eq([1, 4])
  end

  it 'accepts an while where only part of the contition is negated' do
    inspect_source(cop,
                   ['while !a_condition && another_condition',
                    '  some_method',
                    'end',
                    'while not a_condition or another_condition',
                    '  some_method',
                    'end',
                    'some_method while not a_condition or other_cond'])
    expect(cop.messages).to be_empty
  end
end
