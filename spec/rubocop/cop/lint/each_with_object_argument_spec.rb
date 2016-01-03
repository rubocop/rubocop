# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::EachWithObjectArgument do
  subject(:cop) { described_class.new }

  it 'registers an offense for fixnum argument' do
    inspect_source(cop,
                   'collection.each_with_object(0) { |e, a| a + e }')
    expect(cop.messages)
      .to eq(['The argument to each_with_object can not be immutable.'])
  end

  it 'registers an offense for float argument' do
    inspect_source(cop,
                   'collection.each_with_object(0.1) { |e, a| a + e }')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for bignum argument' do
    inspect_source(cop,
                   'c.each_with_object(100000000000000000000) { |e, o| o + e }')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a variable argument' do
    inspect_source(cop,
                   'collection.each_with_object(x) { |e, a| a.add(e) }')
    expect(cop.offenses).to be_empty
  end

  it 'accepts two arguments' do
    # Two arguments would indicate that this is not Enumerable#each_with_object.
    inspect_source(cop,
                   'collection.each_with_object(1, 2) { |e, a| a.add(e) }')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a string argument' do
    inspect_source(cop,
                   "collection.each_with_object('') { |e, a| a << e.to_s }")
    expect(cop.offenses).to be_empty
  end
end
