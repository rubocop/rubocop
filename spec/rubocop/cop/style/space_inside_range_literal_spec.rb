# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceInsideRangeLiteral do
  subject(:cop) { described_class.new }

  it 'registers an offense for space inside .. literal' do
    inspect_source(cop,
                   ['1 .. 2',
                    '1.. 2',
                    '1 ..2'])
    expect(cop.offenses.size).to eq(3)
    expect(cop.messages)
      .to eq(['Space inside range literal.'] * 3)
  end

  it 'accepts no space inside .. literal' do
    inspect_source(cop, '1..2')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for space inside ... literal' do
    inspect_source(cop,
                   ['1 ... 2',
                    '1... 2',
                    '1 ...2'])
    expect(cop.offenses.size).to eq(3)
    expect(cop.messages)
      .to eq(['Space inside range literal.'] * 3)
  end

  it 'accepts no space inside ... literal' do
    inspect_source(cop, '1...2')
    expect(cop.offenses).to be_empty
  end

  it 'accepts complex range literal with space in it' do
    inspect_source(cop, '0...(line - 1)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts multiline range literal with no space in it' do
    inspect_source(cop, ['x = 0..',
                         '    10'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense in multiline range literal with space in it' do
    inspect_source(cop, ['x = 0 ..',
                         '    10'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'autocorrects space around .. literal' do
    corrected = autocorrect_source(cop, ['1  .. 2'])
    expect(corrected).to eq '1..2'
  end

  it 'autocorrects space around ... literal' do
    corrected = autocorrect_source(cop, ['1  ... 2'])
    expect(corrected).to eq '1...2'
  end
end
