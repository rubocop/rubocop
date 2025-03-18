# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::PercentSymbolArray, :config do
  context 'detecting colons or commas in a %i/%I string' do
    %w[i I].each do |char|
      it 'accepts tokens without colons or commas' do
        expect_no_offenses("%#{char}(foo bar baz)")
      end

      it 'accepts likely false positive $,' do
        expect_no_offenses("%#{char}{$,}")
      end

      it 'registers an offense and corrects when symbols contain colons and are comma separated' do
        expect_offense(<<~RUBY)
          %#{char}(:foo, :bar, :baz)
          ^^^^^^^^^^^^^^^^^^^^ Within `%i`/`%I`, ':' and ',' are unnecessary and may be unwanted in the resulting symbols.
        RUBY

        expect_correction(<<~RUBY)
          %#{char}(foo bar baz)
        RUBY
      end

      it 'registers an offense and corrects when one symbol has a colon but there are no commas' do
        expect_offense(<<~RUBY)
          %#{char}(:foo bar baz)
          ^^^^^^^^^^^^^^^^ Within `%i`/`%I`, ':' and ',' are unnecessary and may be unwanted in the resulting symbols.
        RUBY

        expect_correction(<<~RUBY)
          %#{char}(foo bar baz)
        RUBY
      end

      it 'registers an offense and corrects when there are no colons but one comma' do
        expect_offense(<<~RUBY)
          %#{char}(foo, bar baz)
          ^^^^^^^^^^^^^^^^ Within `%i`/`%I`, ':' and ',' are unnecessary and may be unwanted in the resulting symbols.
        RUBY

        expect_correction(<<~RUBY)
          %#{char}(foo bar baz)
        RUBY
      end
    end

    context 'with binary encoded source' do
      it 'registers an offense and corrects when tokens contain quotes' do
        expect_offense(<<~RUBY.b)
          # encoding: BINARY

          %i[\xC0 :foo]
          ^^^^^^^^^^ Within `%i`/`%I`, ':' and ',' are unnecessary and may be unwanted in the resulting symbols.
        RUBY

        expect_correction(<<~RUBY.b)
          # encoding: BINARY

          %i[\xC0 foo]
        RUBY
      end

      it 'accepts if tokens contain no quotes' do
        expect_no_offenses(<<~RUBY.b)
          # encoding: BINARY

          %i[\xC0 \xC1]
        RUBY
      end
    end
  end
end
