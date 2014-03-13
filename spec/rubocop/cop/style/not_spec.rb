# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::Not do
  subject(:cop) { described_class.new }

  it 'registers an offense for not' do
    inspect_source(cop, 'not test')
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for !' do
    inspect_source(cop, '!test')
    expect(cop.offenses).to be_empty
  end
end
