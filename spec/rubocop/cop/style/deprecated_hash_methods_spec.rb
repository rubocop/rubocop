# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::DeprecatedHashMethods do
  subject(:cop) { described_class.new }

  it 'registers an offense for has_key? with one arg' do
    inspect_source(cop,
                   'o.has_key?(o)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['`Hash#has_key?` is deprecated in favor of `Hash#key?`.'])
  end

  it 'accepts has_key? with no args' do
    inspect_source(cop,
                   'o.has_key?')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for has_value? with one arg' do
    inspect_source(cop,
                   'o.has_value?(o)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['`Hash#has_value?` is deprecated in favor of `Hash#value?`.'])
  end

  it 'accepts has_value? with no args' do
    inspect_source(cop,
                   'o.has_value?')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects has_key? with key?' do
    new_source = autocorrect_source(cop, 'hash.has_key?(:test)')
    expect(new_source).to eq('hash.key?(:test)')
  end

  it 'auto-corrects has_value? with value?' do
    new_source = autocorrect_source(cop, 'hash.has_value?(value)')
    expect(new_source).to eq('hash.value?(value)')
  end
end
