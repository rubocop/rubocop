# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceAfterNot do
  subject(:cop) { described_class.new }

  it 'reports an offense for space after !' do
    inspect_source(cop, '! something')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts no space after !' do
    inspect_source(cop, '!something')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects by removing redundant space' do
    new_source = autocorrect_source(cop, '!  something')
    expect(new_source).to eq('!something')
  end
end
