# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantRegexpQuantifiers, :config do
  # silence Ruby's own warnings for the tested redundant quantifiers
  around { |example| RuboCop::Util.silence_warnings(&example) }

  context 'with non-redundant quantifiers' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /(?:ab+)+/')
      expect_no_offenses('foo = /(?:a|b+)+/')
      expect_no_offenses('foo = /(?:a+|b)+/')
      expect_no_offenses('foo = /(?:a+|b)+/')
      expect_no_offenses('foo = /(?:\d\D+)+/')
      # Quantifiers that apply to capture groups or their contents are not redundant.
      # Merging them with other quantifiers could affect the (final) captured value.
      expect_no_offenses('foo = /(a+)+/')
      expect_no_offenses('foo = /(?:(a+))+/')
      expect_no_offenses('foo = /(?:(a)+)+/')
    end
  end

  context 'with nested possessive quantifiers' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /(?:a++)+/')
      expect_no_offenses('foo = /(?:a+)++/')
    end
  end

  context 'with nested reluctant quantifiers' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /(?:a+?)+/')
      expect_no_offenses('foo = /(?:a+)+?/')
    end
  end

  context 'with nested interval quantifiers' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /(?:a{3,4})+/')
      expect_no_offenses('foo = /(?:a+){3,4}/')
    end
  end

  context 'with duplicate "+" quantifiers' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /(?:a+)+/
                   ^^^ Replace redundant quantifiers `+` and `+` with a single `+`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(?:a+)/
      RUBY
    end
  end

  context 'with duplicate "*" quantifiers' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /(?:a*)*/
                   ^^^ Replace redundant quantifiers `*` and `*` with a single `*`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(?:a*)/
      RUBY
    end
  end

  context 'with duplicate "?" quantifiers' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /(?:a?)?/
                   ^^^ Replace redundant quantifiers `?` and `?` with a single `?`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(?:a?)/
      RUBY
    end
  end

  context 'with any other redundant combination of greedy quantifiers' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /(?:a+)?/
                   ^^^ Replace redundant quantifiers `+` and `?` with a single `*`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(?:a*)/
      RUBY
    end
  end

  context 'with nested interval quantifiers that can be normalized' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /(?:a{1,}){,1}/
                   ^^^^^^^^^ Replace redundant quantifiers `{1,}` and `{,1}` with a single `*`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(?:a*)/
      RUBY
    end
  end

  context 'with redundant quantifiers applied to character sets' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /(?:[abc]+)+/
                       ^^^ Replace redundant quantifiers `+` and `+` with a single `+`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(?:[abc]+)/
      RUBY
    end
  end

  context 'with redundant quantifiers in x-mode' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /(?: a ? ) + /x
                     ^^^^^ Replace redundant quantifiers `?` and `+` with a single `*`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(?: a * )  /x
      RUBY
    end
  end

  context 'with non-redundant quantifiers and interpolation in x-mode' do
    it 'does not register an offense' do
      expect_no_offenses(<<~'RUBY')
        foo = /(?:a*#{interpolation})?/x
      RUBY
    end
  end

  context 'with deeply nested redundant quantifiers' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /(?:(?:(?:(?:a)?))+)/
                             ^^^^ Replace redundant quantifiers `?` and `+` with a single `*`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(?:(?:(?:(?:a)*)))/
      RUBY
    end
  end

  context 'with multiple redundant quantifiers' do
    it 'registers offenses and corrects with leading optional quantifer' do
      expect_offense(<<~RUBY)
        foo = /(?:(?:a?)+)+/
                        ^^^ Replace redundant quantifiers `+` and `+` with a single `+`.
                      ^^^^^ Replace redundant quantifiers `?` and `+` with a single `*`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(?:(?:a*))/
      RUBY
    end

    it 'registers offenses and corrects with interspersed optional quantifer' do
      expect_offense(<<~RUBY)
        foo = /(?:(?:a+)?)+/
                        ^^^ Replace redundant quantifiers `?` and `+` with a single `*`.
                      ^^^^^ Replace redundant quantifiers `+` and `+` with a single `+`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(?:(?:a*))/
      RUBY
    end

    it 'registers offenses and corrects with trailing optional quantifer' do
      expect_offense(<<~RUBY)
        foo = /(?:(?:a+)+)?/
                        ^^^ Replace redundant quantifiers `+` and `?` with a single `*`.
                      ^^^^^ Replace redundant quantifiers `+` and `?` with a single `*`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(?:(?:a*))/
      RUBY
    end
  end
end
