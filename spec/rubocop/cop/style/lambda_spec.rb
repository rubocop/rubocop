# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::Lambda do
  subject(:cop) { described_class.new }

  it 'registers an offence for an old single-line lambda call' do
    inspect_source(cop, ['f = lambda { |x| x }'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use the new lambda literal syntax ->(params) {...}.'])
  end

  it 'accepts the new lambda literal with single-line body' do
    inspect_source(cop, ['lambda = ->(x) { x }',
                         'lambda.(1)'])
    expect(cop.offences).to be_empty
  end

  it 'registers an offence for a new multi-line lambda call' do
    inspect_source(cop, ['f = ->(x) do',
                         '  x',
                         'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use the lambda method for multi-line lambdas.'])
  end

  it 'accepts the old lambda syntax with multi-line body' do
    inspect_source(cop, ['l = lambda do |x|',
                         '  x',
                         'end'])
    expect(cop.offences).to be_empty
  end

  it 'accepts the lambda call outside of block' do
    inspect_source(cop, ['l = lambda.test'])
    expect(cop.offences).to be_empty
  end
end
