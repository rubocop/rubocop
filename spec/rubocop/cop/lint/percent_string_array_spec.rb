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

      it 'adds an offense and corrects to an array literal when quoted strings contain whitespace' do
        expect_offense(<<~RUBY)
          %#{char}('foo bar', 'baz')
          ^^^^^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quoted strings are split at whitespace; use an array literal instead.
        RUBY

        expect_correction(<<~RUBY)
          ['foo bar', 'baz']
        RUBY
      end

      it 'adds an offense and corrects to an array literal when a single quoted string contains whitespace' do
        expect_offense(<<~RUBY)
          %#{char}('foo != ""',)
          ^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quoted strings are split at whitespace; use an array literal instead.
        RUBY

        expect_correction(<<~RUBY)
          ['foo != ""',]
        RUBY
      end

      it 'adds an offense and corrects to a multiline array literal when quoted strings contain whitespace' do
        expect_offense(<<~RUBY)
          %#{char}[
          ^^^ Within `%w`/`%W`, quoted strings are split at whitespace; use an array literal instead.
            'foo bar',
            "baz qux"
          ]
        RUBY

        expect_correction(<<~RUBY)
          [
            'foo bar',
            "baz qux"
          ]
        RUBY
      end

      it 'adds an offense without correction when a comma is missing between quoted strings' do
        expect_offense(<<~RUBY)
          %#{char}('foo bar' 'baz')
          ^^^^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quoted strings are split at whitespace; use an array literal instead.
        RUBY

        # Adjacent strings in an array literal would be concatenated into one.
        expect_no_corrections
      end

      it 'adds an offense without correction when a value is not a quoted string' do
        expect_offense(<<~RUBY)
          %#{char}('foo bar', baz)
          ^^^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quoted strings are split at whitespace; use an array literal instead.
        RUBY

        # An unquoted value in an array literal would be a method call.
        expect_no_corrections
      end

      it 'adds an offense without correction when the content does not read as an array literal' do
        expect_offense(<<~RUBY)
          %#{char}{'foo'] + ['bar baz'}
          ^^^^^^^^^^^^^^^^^^^^^^^ Within `%w`/`%W`, quoted strings are split at whitespace; use an array literal instead.
        RUBY

        # Wrapped in brackets, the content reads as an expression other than an array literal.
        expect_no_corrections
      end

      it 'adds an offense without correction when the content contains a comment' do
        expect_offense(<<~RUBY)
          %#{char}[
          ^^^ Within `%w`/`%W`, quoted strings are split at whitespace; use an array literal instead.
            'foo bar', # baz
            'qux'
          ]
        RUBY

        # The comment in an array literal would swallow the values after it on the same line.
        expect_no_corrections
      end

      it 'accepts an unclosed quote without a closing quote in a later token' do
        expect_no_offenses("%#{char}('tis foo bar)")
      end
    end
  end

  context 'with invalid byte sequence in UTF-8' do
    it 'adds an offense and corrects when tokens contain quotes' do
      expect_offense(<<~RUBY)
        %W("a\\255\\255")
        ^^^^^^^^^^^^^^^ Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings.
      RUBY

      expect_correction(<<~RUBY)
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
