# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::EachForSimpleLoop do
  subject(:cop) { described_class.new }

  it 'registers an offense for (0..10).each {}' do
    inspect_source(cop, '(0..10).each {}')
    expect(cop.offenses.size).to eq 1
    expect(cop.messages).to eq(['Use `Integer#times` for a simple loop which ' \
                                'iterates a fixed number of times.'])
    expect(cop.highlights).to eq(['(0..10).each'])
  end

  it 'registers an offense for (0...10).each {}' do
    inspect_source(cop, '(0...10).each {}')
    expect(cop.offenses.size).to eq 1
    expect(cop.messages).to eq(['Use `Integer#times` for a simple loop which ' \
                                'iterates a fixed number of times.'])
    expect(cop.highlights).to eq(['(0...10).each'])
  end

  it "doesn't register an offense if range startpoint is not constant" do
    inspect_source(cop, '(a..10).each {}')
    expect(cop.offenses).to be_empty
  end

  it "doesn't register an offense if range endpoint is not constant" do
    inspect_source(cop, '(0..b).each {}')
    expect(cop.offenses).to be_empty
  end

  it "doesn't register an offense if block takes parameters" do
    inspect_source(cop, '(0..10).each { |n| puts n }')
    expect(cop.offenses).to be_empty
  end
end
