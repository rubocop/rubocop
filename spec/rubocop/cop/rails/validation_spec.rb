# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::Validation do
  subject(:cop) { described_class.new }

  described_class::BLACKLIST.each_with_index do |validation, number|
    it "registers an offense for #{validation}" do
      inspect_source(cop, "#{validation} :name")
      expect(cop.offenses.size).to eq(1)
    end

    it "outputs the correct message for #{validation}" do
      inspect_source(cop, "#{validation} :name")
      expect(cop.offenses.first.message)
        .to include(described_class::WHITELIST[number])
    end
  end

  described_class::TYPES.each_with_index do |parameter|
    it "autocorrect validates_#{parameter}_of" do
      new_source = autocorrect_source(
        cop,
        "validates_#{parameter}_of :full_name, :birth_date"
      )
      expect(new_source).to eq(
        "validates :full_name, :birth_date, #{parameter}: true"
      )
    end
  end

  it 'accepts new style validations' do
    inspect_source(cop, 'validates :name')
    expect(cop.offenses).to be_empty
  end

  it 'autocorrect validates_length_of' do
    new_source = autocorrect_source(
      cop,
      'validates_numericality_of :age, minimum: 0, maximum: 122'
    )
    expect(new_source).to eq(
      'validates :age, numericality: { minimum: 0, maximum: 122 }'
    )
  end
end
