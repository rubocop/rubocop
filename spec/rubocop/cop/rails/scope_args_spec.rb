# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::ScopeArgs do
  subject(:cop) { described_class.new }

  it 'registers an offense a scope with a method arg' do
    inspect_source(cop,
                   'scope :active, where(active: true)')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a lambda arg' do
    inspect_source(cop,
                   'scope :active, -> { where(active: true) }')
    inspect_source(cop,
                   'scope :active, lambda do where(active: true) end')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a proc arg' do
    inspect_source(cop,
                   'scope :active, proc { where(active: true) }')
    expect(cop.offenses).to be_empty
  end
end
