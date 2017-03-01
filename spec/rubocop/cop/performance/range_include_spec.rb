# frozen_string_literal: true

describe RuboCop::Cop::Performance::RangeInclude do
  subject(:cop) { described_class.new }

  it 'autocorrects (a..b).include? without parens' do
    new_source = autocorrect_source(cop, '(a..b).include? 1')
    expect(new_source).to eq '(a..b).cover? 1'
  end

  it 'autocorrects (a...b).include? without parens' do
    new_source = autocorrect_source(cop, '(a...b).include? 1')
    expect(new_source).to eq '(a...b).cover? 1'
  end

  it 'autocorrects (a..b).include? with parens' do
    new_source = autocorrect_source(cop, '(a..b).include?(1)')
    expect(new_source).to eq '(a..b).cover?(1)'
  end

  it 'autocorrects (a...b).include? with parens' do
    new_source = autocorrect_source(cop, '(a...b).include?(1)')
    expect(new_source).to eq '(a...b).cover?(1)'
  end

  it 'formats the error message correctly for (a..b).include? 1' do
    inspect_source(cop, '(a..b).include? 1')
    expect(cop.messages).to eq(
      ['Use `Range#cover?` instead of `Range#include?`.']
    )
  end
end
