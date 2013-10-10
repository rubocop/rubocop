# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceAfterNot do
  subject(:cop) { described_class.new }

  it 'reports an offence for space after !' do
    inspect_source(cop, ['! something'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts no space after !' do
    inspect_source(cop, ['!something'])
    expect(cop.offences).to be_empty
  end

  it 'auto-corrects by removing redundant space' do
    new_source = autocorrect_source(cop, '!  something')
    expect(new_source).to eq('!something')
  end
end
