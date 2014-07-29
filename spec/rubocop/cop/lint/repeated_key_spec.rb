# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::RepeatedKey do
  subject(:cop) { described_class.new }

  it 'registers an offense for repeated keys' do
    source = '{ 1 => 2, 1 => 3 }'
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense when not repeated' do
    source = '{ 1 => 2 }'
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end
end
