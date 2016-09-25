# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::EmptyInterpolation do
  subject(:cop) { described_class.new }

  it 'registers an offense for #{} in interpolation' do
    inspect_source(cop, '"this is the #{}"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['#{}'])
  end

  it 'accepts non-empty interpolation' do
    inspect_source(cop, '"this is #{top} silly"')
    expect(cop.offenses).to be_empty
  end
end
