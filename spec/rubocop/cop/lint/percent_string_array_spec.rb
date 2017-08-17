# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::PercentStringArray do
  subject(:cop) { described_class.new }

  context 'detecting quotes or commas in a %w/%W string' do
    %w[w W].each do |char|
      it 'accepts tokens without quotes or commas' do
        expect_no_offenses("%#{char}(foo bar baz)")
      end

      [
        %(%#{char}(' ")),
        %(%#{char}(' " ! = # ,)),
        ':"#{a}"',
        %(%#{char}(\#{a} b))
      ].each do |false_positive|
        it "accepts likely false positive #{false_positive}" do
          expect_no_offenses(false_positive)
        end
      end

      it 'adds an offense if tokens contain quotes and are comma separated' do
        expect_offense(<<-RUBY.strip_indent)
          %#{char}('foo', 'bar', 'baz')
          ^^^^^^^^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
        RUBY
      end

      it 'adds an offense if tokens contain both types of quotes' do
        expect_offense(<<-RUBY.strip_indent)
          %#{char}('foo' "bar" 'baz')
          ^^^^^^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
        RUBY
      end

      it 'adds an offense if one token is quoted but there are no commas' do
        expect_offense(<<-RUBY.strip_indent)
          %#{char}('foo' bar baz)
          ^^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
        RUBY
      end

      it 'adds an offense if there are no quotes but one comma' do
        expect_offense(<<-RUBY.strip_indent)
          %#{char}(foo, bar baz)
          ^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
        RUBY
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

    it 'removes undesirable characters' do
      expect(autocorrect_source(source)).to eq(expected_corrected_source)
    end
  end

  context 'with invalid byte sequence in UTF-8' do
    it 'add an offences if tokens contain quotes' do
      expect_offense(<<-RUBY)
        %W("a\\255\\255")
        ^^^^^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
      RUBY
    end

    it 'accepts if tokens contain invalid byte sequence only' do
      expect_no_offenses('%W(\255)')
    end
  end
end
