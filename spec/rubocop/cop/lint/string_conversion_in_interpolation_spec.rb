# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::StringConversionInInterpolation do
  subject(:cop) { described_class.new }

  it 'registers an offense for #to_s in interpolation' do
    inspect_source(cop, '"this is the #{result.to_s}"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Redundant use of `Object#to_s` in interpolation.'])
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

  it 'does not explode on implicit receiver' do
    inspect_source(cop, '"#{to_s}"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use `self` instead of `Object#to_s` in interpolation.'])
  end

  it 'does not explode on empty interpolation' do
    inspect_source(cop, '"this is #{} silly"')
    expect(cop.offenses).to be_empty
  end

  it 'autocorrects by removing the redundant to_s' do
    corrected = autocorrect_source(cop, ['"some #{something.to_s}"'])
    expect(corrected).to eq '"some #{something}"'
  end

  it 'autocorrects implicit receiver by replacing to_s with self' do
    corrected = autocorrect_source(cop, ['"some #{to_s}"'])
    expect(corrected).to eq '"some #{self}"'
  end
end
