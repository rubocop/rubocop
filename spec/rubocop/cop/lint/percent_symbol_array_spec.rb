# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::PercentSymbolArray do
  subject(:cop) { described_class.new }

  context 'detecting colons or commas in a %i/%I string' do
    %w[i I].each do |char|
      it 'accepts tokens without colons or commas' do
        expect_no_offenses("%#{char}(foo bar baz)")
      end

      it 'accepts likely false positive $,' do
        expect_no_offenses("%#{char}{$,}")
      end

      it 'adds an offense if symbols contain colons and are comma separated' do
        expect_offense(<<-RUBY.strip_indent)
          %#{char}(:foo, :bar, :baz)
          ^^^^^^^^^^^^^^^^^^^^ Within `%i`/`%I`, ':' and ',' are unnecessary and may be unwanted in the resulting symbols.
        RUBY
      end

      it 'adds an offense if one symbol has a colon but there are no commas' do
        expect_offense(<<-RUBY.strip_indent)
          %#{char}(:foo bar baz)
          ^^^^^^^^^^^^^^^^ Within `%i`/`%I`, ':' and ',' are unnecessary and may be unwanted in the resulting symbols.
        RUBY
      end

      it 'adds an offense if there are no colons but one comma' do
        expect_offense(<<-RUBY.strip_indent)
          %#{char}(foo, bar baz)
          ^^^^^^^^^^^^^^^^ Within `%i`/`%I`, ':' and ',' are unnecessary and may be unwanted in the resulting symbols.
        RUBY
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

    it 'removes undesirable characters' do
      expect(autocorrect_source(source)).to eq(expected_corrected_source)
    end
  end
end
