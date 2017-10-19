# frozen_string_literal: true

describe RuboCop::Cop::Lint::PercentSymbolArray do
  subject(:cop) { described_class.new }

  let(:message) do
    "Within `%i`/`%I`, ':' and ',' are unnecessary and may be " \
      'unwanted in the resulting symbols.'
  end

  def expect_offense(source)
    inspect_source(source)

    expect(cop.offenses.map(&:message)).to eq([message])
    expect(cop.highlights).to eq([source])
  end

  context 'detecting colons or commas in a %i/%I string' do
    %w[i I].each do |char|
      it 'accepts tokens without colons or commas' do
        inspect_source("%#{char}(foo bar baz)")

        expect(cop.offenses.empty?).to be(true)
      end

      it 'accepts likely false positive $,' do
        inspect_source("%#{char}{$,}")

        expect(cop.offenses.empty?).to be(true)
      end

      it 'adds an offense if symbols contain colons and are comma separated' do
        expect_offense("%#{char}(:foo, :bar, :baz)")
      end

      it 'adds an offense if one symbol has a colon but there are no commas' do
        expect_offense("%#{char}(:foo bar baz)")
      end

      it 'adds an offense if there are no colons but one comma' do
        expect_offense("%#{char}(foo, bar baz)")
      end
    end
  end

  context 'autocorrection' do
    let(:source) do
      <<-SOURCE
      %i(:a, :b, c, d e :f)
      %I(:a, :b, c, d e :f)
      SOURCE
    end
    let(:expected_corrected_source) do
      <<-CORRECTED_SOURCE
      %i(a b c d e f)
      %I(a b c d e f)
      CORRECTED_SOURCE
    end

    it 'removes undesireable characters' do
      expect(autocorrect_source(source)).to eq(expected_corrected_source)
    end
  end
end
