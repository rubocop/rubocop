# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::NilComparison do
  subject(:cop) { described_class.new }

  it 'registers an offense for == nil' do
    inspect_source(cop, 'x == nil')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['=='])
  end

  it 'registers an offense for === nil' do
    inspect_source(cop, 'x === nil')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['==='])
  end

  it 'autocorrects by replacing == nil with .nil?' do
    corrected = autocorrect_source(cop, 'x == nil')
    expect(corrected).to eq 'x.nil?'
  end

  it 'autocorrects by replacing === nil with .nil?' do
    corrected = autocorrect_source(cop, 'x === nil')
    expect(corrected).to eq 'x.nil?'
  end
end
