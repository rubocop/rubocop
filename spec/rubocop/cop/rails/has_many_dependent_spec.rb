# frozen_string_literal: true

describe RuboCop::Cop::Rails::HasManyDependent do
  subject(:cop) { described_class.new }
  let(:msg) do
    '`has_many` and `has_one` associations must specify a `dependent` option.'
  end

  %w[has_many has_one].each do |has_many_or_has_one|
    context has_many_or_has_one do
      it 'registers an offense when not specifying any options' do
        inspect_source("#{has_many_or_has_one} :foo")

        expect(cop.messages).to eq([msg])
      end

      it 'registers an offense when missing an explicit dependent strategy' do
        inspect_source("#{has_many_or_has_one} :foo, class_name: 'bar'")

        expect(cop.messages).to eq([msg])
      end

      it 'does not register an offense when specifying dependent strategy' do
        expect_no_offenses("#{has_many_or_has_one} :foo, dependent: :destroy")
      end
    end
  end
end
