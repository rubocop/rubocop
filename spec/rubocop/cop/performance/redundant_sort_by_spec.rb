# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::RedundantSortBy do
  subject(:cop) { described_class.new }

  it 'autocorrects array.sort_by { |x| x }' do
    new_source = autocorrect_source(cop, 'array.sort_by { |x| x }')
    expect(new_source).to eq 'array.sort'
  end

  it 'autocorrects array.sort_by { |y| y }' do
    new_source = autocorrect_source(cop, 'array.sort_by { |y| y }')
    expect(new_source).to eq 'array.sort'
  end

  it 'autocorrects array.sort_by do |x| x end' do
    new_source = autocorrect_source(cop, ['array.sort_by do |x|',
                                          '  x',
                                          'end'])
    expect(new_source).to eq 'array.sort'
  end

  it 'formats the error message correctly for array.sort_by { |x| x }' do
    inspect_source(cop, 'array.sort_by { |x| x }')
    expect(cop.messages).to eq(['Use `sort` instead of `sort_by { |x| x }`.'])
  end
end
