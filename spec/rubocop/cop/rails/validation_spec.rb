# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::Validation do
  subject(:cop) { described_class.new }

  described_class::BLACKLIST.each_with_index do |validation, number|
    it "registers an offense for #{validation}" do
      inspect_source(cop,
                     "#{validation} :name")
      expect(cop.offenses.size).to eq(1)
    end

    it "outputs the correct message for #{validation}" do
      inspect_source(cop,
                     "#{validation} :name")
      expect(cop.offenses.first.message)
        .to include(described_class::WHITELIST[number])
    end
  end

  it 'accepts new style validations' do
    inspect_source(cop,
                   'validates :name')
    expect(cop.offenses).to be_empty
  end
end
