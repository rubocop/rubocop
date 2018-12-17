# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Validation do
  subject(:cop) { described_class.new }

  it 'accepts new style validations' do
    expect_no_offenses('validates :name')
  end

  described_class::DENYLIST.each_with_index do |validation, number|
    it "registers an offense for #{validation}" do
      inspect_source("#{validation} :name")
      expect(cop.offenses.size).to eq(1)
    end

    it "outputs the correct message for #{validation}" do
      inspect_source("#{validation} :name")
      expect(cop.offenses.first.message)
        .to include(described_class::ALLOWLIST[number])
    end
  end

  describe 'autocorrect' do
    described_class::TYPES.each do |parameter|
      it "corrects validates_#{parameter}_of" do
        new_source = autocorrect_source(
          "validates_#{parameter}_of :full_name, :birth_date"
        )
        expect(new_source).to eq(
          "validates :full_name, :birth_date, #{parameter}: true"
        )
      end
    end

    it 'corrects validates_numericality_of with options' do
      new_source = autocorrect_source(
        'validates_numericality_of :age, minimum: 0, maximum: 122'
      )
      expect(new_source).to eq(
        'validates :age, numericality: { minimum: 0, maximum: 122 }'
      )
    end

    it 'autocorrect validates_numericality_of with options in braces' do
      new_source = autocorrect_source(
        'validates_numericality_of :age, { minimum: 0, maximum: 122 }'
      )
      expect(new_source).to eq(
        'validates :age, numericality: { minimum: 0, maximum: 122 }'
      )
    end
  end
end
