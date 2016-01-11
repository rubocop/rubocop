# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::DoubleNegation do
  subject(:cop) { described_class.new }

  it 'registers an offense for !!' do
    inspect_source(cop, '!!test.something')
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for !' do
    inspect_source(cop, '!test.something')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for not not' do
    inspect_source(cop, 'not not test.something')
    expect(cop.offenses).to be_empty
  end
end
