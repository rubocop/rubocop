# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::SortWithBlock do
  subject(:cop) { described_class.new }

  it 'autocorrects array.sort { |a, b| a.foo <=> b.foo }' do
    new_source =
      autocorrect_source(cop, 'array.sort { |a, b| a.foo <=> b.foo }')
    expect(new_source).to eq 'array.sort_by(&:foo)'
  end

  it 'autocorrects array.sort { |x, y| x.foo <=> y.foo }' do
    new_source =
      autocorrect_source(cop, 'array.sort { |x, y| x.foo <=> y.foo }')
    expect(new_source).to eq 'array.sort_by(&:foo)'
  end

  it 'autocorrects array.sort do |a, b| a.foo <=> b.foo end' do
    new_source = autocorrect_source(cop, ['array.sort do |a, b|',
                                          '  a.foo <=> b.foo',
                                          'end'])
    expect(new_source).to eq 'array.sort_by(&:foo)'
  end

  it 'formats the error message correctly for ' \
     'array.sort { |a, b| a.foo <=> b.foo }' do
    inspect_source(cop, 'array.sort { |a, b| a.foo <=> b.foo }')
    expect(cop.messages).to eq(['Use `sort_by(&:foo)` instead of ' \
                                '`sort { |a, b| a.foo <=> b.foo }`.'])
  end
end
