# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Rails::ReadWriteAttribute do
  subject(:cop) { described_class.new }

  it 'registers an offense for read_attribute' do
    inspect_source(cop, 'res = read_attribute(:test)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['read_attribute'])
  end

  it 'registers an offense for write_attribute' do
    inspect_source(cop, 'write_attribute(:test, val)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['write_attribute'])
  end
end
