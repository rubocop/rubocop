# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Rails::DefaultScope do
  subject(:cop) { described_class.new }

  it 'registers an offence for default scope with a lambda arg' do
    inspect_source(cop,
                   ['default_scope -> { something }'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for default scope with a proc arg' do
    inspect_source(cop,
                   ['default_scope proc { something }'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for default scope with a proc(Proc.new) arg' do
    inspect_source(cop,
                   ['default_scope Proc.new { something }'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for non blocks' do
    inspect_source(cop,
                   ['default_scope order: "position"'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts a block arg' do
    inspect_source(cop,
                   ['default_scope { something }'])
    expect(cop.offences).to be_empty
  end
end
