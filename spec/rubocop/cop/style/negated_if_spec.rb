# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::NegatedIf do
  subject(:cop) { described_class.new }

  it 'registers an offense for if with exclamation point condition' do
    inspect_source(cop,
                   ['if !a_condition',
                    '  some_method',
                    'end',
                    'some_method if !a_condition'])
    expect(cop.messages).to eq(
      ['Favor `unless` over `if` for negative ' \
       'conditions.'] * 2
    )
  end

  it 'registers an offense for unless with exclamation point condition' do
    inspect_source(cop,
                   ['unless !a_condition',
                    '  some_method',
                    'end',
                    'some_method unless !a_condition'])
    expect(cop.messages).to eq(['Favor `if` over `unless` for negative ' \
                                'conditions.'] * 2)
  end

  it 'registers an offense for if with "not" condition' do
    inspect_source(cop,
                   ['if not a_condition',
                    '  some_method',
                    'end',
                    'some_method if not a_condition'])
    expect(cop.messages).to eq(
      ['Favor `unless` over `if` for negative ' \
       'conditions.'] * 2
    )
    expect(cop.offenses.map(&:line)).to eq([1, 4])
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
    expect(cop.offenses).to be_empty
  end

  it 'accepts an if where only part of the condition is negated' do
    inspect_source(cop,
                   ['if !condition && another_condition',
                    '  some_method',
                    'end',
                    'if not condition or another_condition',
                    '  some_method',
                    'end',
                    'some_method if not condition or another_condition'])
    expect(cop.offenses).to be_empty
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

    expect(cop.offenses).to be_empty
  end

  it 'does not blow up for ternary ops' do
    inspect_source(cop, 'a ? b : c')
    expect(cop.offenses).to be_empty
  end

  it 'autocorrects by replacing if not with unless' do
    corrected = autocorrect_source(cop, 'something if !x.even?')
    expect(corrected).to eq 'something unless x.even?'
  end

  it 'autocorrects by replacing parenthesized if not with unless' do
    corrected = autocorrect_source(cop, 'something if (!x.even?)')
    expect(corrected).to eq 'something unless (x.even?)'
  end

  it 'autocorrects by replacing unless not with if' do
    corrected = autocorrect_source(cop, 'something unless !x.even?')
    expect(corrected).to eq 'something if x.even?'
  end
end
