# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::PercentStringArray do
  subject(:cop) { described_class.new }

  def expect_offense(source)
    inspect_source(cop, source)

    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.message).to eq(described_class::MSG)
    expect(cop.highlights).to eq([source])
  end

  context 'detecting quotes or commas in a %w/%W string' do
    %w(w W).each do |char|
      it 'accepts tokens without quotes or commas' do
        inspect_source(cop, "%#{char}(foo bar baz)")

        expect(cop.offenses).to be_empty
      end

      [
        %(%#{char}(' ")),
        %(%#{char}(' " ! = # ,)),
        ':"#{a}"',
        %(%#{char}(\#{a} b))
      ].each do |false_positive|
        it "accepts likely false positive #{false_positive}" do
          inspect_source(cop, false_positive)

          expect(cop.offenses).to be_empty
        end
      end

      it 'adds an offense if tokens contain quotes and are comma separated' do
        expect_offense("%#{char}('foo', 'bar', 'baz')")
      end

      it 'adds an offense if tokens contain both types of quotes' do
        expect_offense(%{%#{char}('foo' "bar" 'baz')})
      end

      it 'adds an offense if one token is quoted but there are no commas' do
        expect_offense("%#{char}('foo' bar baz)")
      end

      it 'adds an offense if there are no quotes but one comma' do
        expect_offense("%#{char}(foo, bar baz)")
      end
    end
  end

  context 'autocorrection' do
    let(:source) do
      <<-SOURCE
      %w('a', "b", c', "d, e f)
      %W('a', "b", c', "d, e f)
      SOURCE
    end
    let(:expected_corrected_source) do
      <<-CORRECTED_SOURCE
      %w(a b c d e f)
      %W(a b c d e f)
      CORRECTED_SOURCE
    end

    it 'removes undesireable characters' do
      expect(autocorrect_source(cop, source)).to eq(expected_corrected_source)
    end
  end

  context 'with invalid byte sequence in UTF-8' do
    it 'add an offences if tokens contain quotes' do
      expect_offense('%W("a\255\255")')
    end

    it 'accepts if tokens contain invalid byte sequence only' do
      inspect_source(cop, '%W(\255)')

      expect(cop.offenses).to be_empty
    end
  end
end
