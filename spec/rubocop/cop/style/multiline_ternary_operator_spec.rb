# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::MultilineTernaryOperator do
  subject(:cop) { described_class.new }

  it 'registers offence for a multiline ternary operator expression' do
    inspect_source(cop, ['a = cond ?',
                         '  b : c'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts a single line ternary operator expression' do
    inspect_source(cop, ['a = cond ? b : c'])
    expect(cop.offences).to be_empty
  end
end
