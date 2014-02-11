# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Rails::ReadAttribute do
  subject(:cop) { described_class.new }

  it 'registers an offense for read_attribute' do
    inspect_source(cop,
                   ['res = read_attribute(:test)'])
    expect(cop.offenses.size).to eq(1)
  end
end
