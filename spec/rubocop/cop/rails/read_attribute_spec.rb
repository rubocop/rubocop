# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Rails::ReadAttribute do
  subject(:cop) { described_class.new }

  it 'registers an offence for read_attribute' do
    inspect_source(cop,
                   ['res = read_attribute(:test)'])
    expect(cop.offences.size).to eq(1)
  end
end
