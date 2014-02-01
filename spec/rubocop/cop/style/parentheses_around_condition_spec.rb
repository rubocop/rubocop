# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::ParenthesesAroundCondition, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowSafeAssignment' => true } }

  it 'registers an offence for parentheses around condition' do
    inspect_source(cop, ['if (x > 10)',
                         'elsif (x < 3)',
                         'end',
                         'unless (x > 10)',
                         'end',
                         'while (x > 10)',
                         'end',
                         'until (x > 10)',
                         'end',
                         'x += 1 if (x < 10)',
                         'x += 1 unless (x < 10)',
                         'x += 1 until (x < 10)',
                         'x += 1 while (x < 10)'
                        ])
    expect(cop.offences.size).to eq(9)
    expect(cop.messages.first)
      .to eq("Don't use parentheses around the condition of an if.")
    expect(cop.messages.last)
      .to eq("Don't use parentheses around the condition of a while.")
  end

  it 'accepts parentheses if there is no space between the keyword and (.' do
    inspect_source(cop, ['if(x > 5) then something end'])
    expect(cop.offences).to be_empty
  end

  it 'auto-corrects parentheses around condition' do
    corrected = autocorrect_source(cop, ['if (x > 10)',
                                         'elsif (x < 3)',
                                         'end',
                                         'unless (x > 10)',
                                         'end',
                                         'while (x > 10)',
                                         'end',
                                         'until (x > 10)',
                                         'end',
                                         'x += 1 if (x < 10)',
                                         'x += 1 unless (x < 10)',
                                         'x += 1 while (x < 10)',
                                         'x += 1 until (x < 10)'
                                        ])
    expect(corrected).to eq ['if x > 10',
                             'elsif x < 3',
                             'end',
                             'unless x > 10',
                             'end',
                             'while x > 10',
                             'end',
                             'until x > 10',
                             'end',
                             'x += 1 if x < 10',
                             'x += 1 unless x < 10',
                             'x += 1 while x < 10',
                             'x += 1 until x < 10'
                            ].join("\n")
  end

  it 'accepts condition without parentheses' do
    inspect_source(cop, ['if x > 10',
                         'end',
                         'unless x > 10',
                         'end',
                         'while x > 10',
                         'end',
                         'until x > 10',
                         'end',
                         'x += 1 if x < 10',
                         'x += 1 unless x < 10',
                         'x += 1 while x < 10',
                         'x += 1 until x < 10'
                        ])
    expect(cop.offences).to be_empty
  end

  it 'accepts parentheses around condition in a ternary' do
    inspect_source(cop, '(a == 0) ? b : a')
    expect(cop.offences).to be_empty
  end

  it 'is not confused by leading parenthesis in subexpression' do
    inspect_source(cop, ['(a > b) && other ? one : two'])
    expect(cop.offences).to be_empty
  end

  it 'is not confused by unbalanced parentheses' do
    inspect_source(cop, ['if (a + b).c()',
                         'end'])
    expect(cop.offences).to be_empty
  end

  context 'safe assignment is allowed' do
    it 'accepts = in condition surrounded with parentheses' do
      inspect_source(cop,
                     ['if (test = 10)',
                      'end'
                     ])
      expect(cop.offences).to be_empty
    end

  end

  context 'safe assignment is not allowed' do
    let(:cop_config) { { 'AllowSafeAssignment' => false } }

    it 'does not accept = in condition surrounded with parentheses' do
      inspect_source(cop,
                     ['if (test = 10)',
                      'end'
                     ])
      expect(cop.offences.size).to eq(1)
    end
  end
end
