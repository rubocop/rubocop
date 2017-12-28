# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MultipleCompare do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  shared_examples 'Check to use two comparison operator' do |operator1, operator2| # rubocop:disable Metrics/LineLength
    bad_source = "x #{operator1} y #{operator2} z"
    good_source = "x #{operator1} y && y #{operator2} z"

    it "registers an offense for #{bad_source}" do
      inspect_source(bad_source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use the `&&` operator to compare multiple values.'])
    end

    it 'autocorrects' do
      new_source = autocorrect_source(bad_source)
      expect(new_source).to eq(good_source)
    end

    it "accepts for #{good_source}" do
      inspect_source(good_source)
      expect(cop.offenses.empty?).to be(true)
    end
  end

  %w[< > <= >=].repeated_permutation(2) do |operator1, operator2|
    include_examples 'Check to use two comparison operator',
                     operator1, operator2
  end

  it 'accepts to use one compare operator' do
    expect_no_offenses('x < 1')
  end
end
