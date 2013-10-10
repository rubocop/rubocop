# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceInsideParens do
  subject(:cop) { described_class.new }

  it 'registers an offence for spaces inside parens' do
    inspect_source(cop, ['f( 3)',
                         'g(3 )'])
    expect(cop.messages).to eq(
      ['Space inside parentheses detected.',
       'Space inside parentheses detected.'])
  end

  it 'accepts parentheses in block parameter list' do
    inspect_source(cop,
                   ['list.inject(Tms.new) { |sum, (label, item)|',
                    '}'])
    expect(cop.messages).to be_empty
  end

  it 'accepts parentheses with no spaces' do
    inspect_source(cop, ['split("\n")'])
    expect(cop.messages).to be_empty
  end

  it 'auto-corrects unwanted space' do
    new_source = autocorrect_source(cop, ['f( 3)',
                                          'g(3 )'])
    expect(new_source).to eq(['f(3)',
                              'g(3)'].join("\n"))
  end
end
