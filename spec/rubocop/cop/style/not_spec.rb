# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::Not, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for not' do
    inspect_source(cop, 'not test')
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for !' do
    inspect_source(cop, '!test')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects "not" with !' do
    new_source = autocorrect_source(cop, 'x = 10 if not y')
    expect(new_source).to eq('x = 10 if !y')
  end

  it 'leaves "not" as is if auto-correction changes the meaning' do
    src = 'not x < y'
    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq(src)
  end
end
