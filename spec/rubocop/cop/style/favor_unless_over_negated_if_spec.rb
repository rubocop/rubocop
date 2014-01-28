# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::FavorUnlessOverNegatedIf do
  subject(:cop) { described_class.new }

  it 'registers an offence for if with exclamation point condition' do
    inspect_source(cop,
                   ['if !a_condition',
                    '  some_method',
                    'end',
                    'some_method if !a_condition'
                   ])
    expect(cop.messages).to eq(
      ['Favor unless (or control flow or) over if for negative ' \
       'conditions.'] * 2)
  end

  it 'registers an offence for if with "not" condition' do
    inspect_source(cop,
                   ['if not a_condition',
                    '  some_method',
                    'end',
                    'some_method if not a_condition'])
    expect(cop.messages).to eq(
      ['Favor unless (or control flow or) over if for negative ' \
       'conditions.'] * 2)
    expect(cop.offences.map(&:line)).to eq([1, 4])
  end

  it 'accepts an if/else with negative condition' do
    inspect_source(cop,
                   ['if !a_condition',
                    '  some_method',
                    'else',
                    '  something_else',
                    'end',
                    'if not a_condition',
                    '  some_method',
                    'elsif other_condition',
                    '  something_else',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'accepts an if where only part of the contition is negated' do
    inspect_source(cop,
                   ['if !condition && another_condition',
                    '  some_method',
                    'end',
                    'if not condition or another_condition',
                    '  some_method',
                    'end',
                    'some_method if not condition or another_condition'])
    expect(cop.offences).to be_empty
  end

  it 'is not confused by negated elsif' do
    inspect_source(cop,
                   ['if test.is_a?(String)',
                    '  3',
                    'elsif test.is_a?(Array)',
                    '  2',
                    'elsif !test.nil?',
                    '  1',
                    'end'])

    expect(cop.offences).to be_empty
  end

  it 'does not blow up for ternary ops' do
    inspect_source(cop, 'a ? b : c')
    expect(cop.offences).to be_empty
  end
end
