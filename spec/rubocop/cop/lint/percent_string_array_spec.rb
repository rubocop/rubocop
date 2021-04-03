# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::PercentStringArray, :config do
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

      it 'adds an offense and corrects when tokens contain quotes and are comma separated' do
        expect_offense(<<~RUBY)
          %#{char}('foo', 'bar', 'baz')
          ^^^^^^^^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
        RUBY

        expect_correction(<<~RUBY)
          %#{char}(foo bar baz)
        RUBY
      end

      it 'adds an offense and corrects when tokens contain both types of quotes' do
        expect_offense(<<~RUBY)
          %#{char}('foo' "bar" 'baz')
          ^^^^^^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
        RUBY

        expect_correction(<<~RUBY)
          %#{char}(foo bar baz)
        RUBY
      end

      it 'adds an offense and corrects when one token is quoted but there are no commas' do
        expect_offense(<<~RUBY)
          %#{char}('foo' bar baz)
          ^^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
        RUBY

        expect_correction(<<~RUBY)
          %#{char}(foo bar baz)
        RUBY
      end

      it 'adds an offense and corrects when there are no quotes but one comma' do
        expect_offense(<<~RUBY)
          %#{char}(foo, bar baz)
          ^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
        RUBY

        expect_correction(<<~RUBY)
          %#{char}(foo bar baz)
        RUBY
      end
    end
  end

  context 'with invalid byte sequence in UTF-8' do
    it 'add an offense and corrects when tokens contain quotes' do
      expect_offense(<<-RUBY)
        %W("a\\255\\255")
        ^^^^^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
      RUBY

      expect_correction(<<-RUBY)
        %W(a\\255\\255)
      RUBY
    end

    it 'accepts if tokens contain invalid byte sequence only' do
      expect_no_offenses('%W(\255)')
    end
  end

  context 'with binary encoded source' do
    it 'adds an offense and corrects when tokens contain quotes' do
      expect_offense(<<~RUBY.b)
        # encoding: BINARY

        %W[\xC0 "foo"]
        ^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
      RUBY

      expect_correction(<<~RUBY.b)
        # encoding: BINARY

        %W[\xC0 foo]
      RUBY
    end

    it 'accepts if tokens contain no quotes' do
      expect_no_offenses(<<~RUBY.b)
        # encoding: BINARY

        %W[\xC0 \xC1]
      RUBY
    end
  end
end
