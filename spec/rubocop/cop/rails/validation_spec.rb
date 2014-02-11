# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Rails::Validation do
  subject(:cop) { described_class.new }

  described_class::BLACKLIST.each do |validation|
    it "registers an offense for #{validation}" do
      inspect_source(cop,
                     ["#{validation} :name"])
      expect(cop.offenses.size).to eq(1)
    end
  end

  it 'accepts sexy validations' do
    inspect_source(cop,
                   ['validates :name'])
    expect(cop.offenses).to be_empty
  end
end
