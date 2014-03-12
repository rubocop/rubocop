# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::StringConversionInInterpolation do
  subject(:cop) { described_class.new }

  it 'registers an offense for #to_s in interpolation' do
    inspect_source(cop, '"this is the #{result.to_s}"')
    expect(cop.offenses.size).to eq(1)
  end

  it 'detects #to_s in an interpolation with several expressions' do
    inspect_source(cop, '"this is the #{top; result.to_s}"')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts #to_s with arguments in an interpolation' do
    inspect_source(cop, '"this is a #{result.to_s(8)}"')
    expect(cop.offenses).to be_empty
  end

  it 'accepts interpolation without #to_s' do
    inspect_source(cop, '"this is the #{result}"')
    expect(cop.offenses).to be_empty
  end
end
