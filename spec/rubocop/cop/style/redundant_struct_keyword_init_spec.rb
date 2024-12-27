# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantStructKeywordInit, :config do
  context 'Ruby >= 3.2', :ruby32 do
    it 'registers an offense when using `keyword_init: nil` in `Struct.new`' do
      expect_offense(<<~RUBY)
        Struct.new(:foo, keyword_init: nil)
                         ^^^^^^^^^^^^^^^^^ Remove the redundant `keyword_init: nil`.
      RUBY

      expect_correction(<<~RUBY)
        Struct.new(:foo)
      RUBY
    end

    it 'registers an offense when using `keyword_init: true` in `Struct.new`' do
      expect_offense(<<~RUBY)
        Struct.new(:foo, keyword_init: true)
                         ^^^^^^^^^^^^^^^^^^ Remove the redundant `keyword_init: true`.
      RUBY

      expect_correction(<<~RUBY)
        Struct.new(:foo)
      RUBY
    end

    it 'registers an offense when using only `keyword_init: true` in `Struct.new`' do
      expect_offense(<<~RUBY)
        Struct.new(keyword_init: true)
                   ^^^^^^^^^^^^^^^^^^ Remove the redundant `keyword_init: true`.
      RUBY

      expect_correction(<<~RUBY)
        Struct.new()
      RUBY
    end

    it 'registers an offense when using `keyword_init: true` in `Struct&.new`' do
      expect_offense(<<~RUBY)
        Struct&.new(:foo, keyword_init: true)
                          ^^^^^^^^^^^^^^^^^^ Remove the redundant `keyword_init: true`.
      RUBY

      expect_correction(<<~RUBY)
        Struct&.new(:foo)
      RUBY
    end

    it 'registers an offense when using `keyword_init: true` in `::Struct.new`' do
      expect_offense(<<~RUBY)
        ::Struct.new(:foo, keyword_init: true)
                           ^^^^^^^^^^^^^^^^^^ Remove the redundant `keyword_init: true`.
      RUBY

      expect_correction(<<~RUBY)
        ::Struct.new(:foo)
      RUBY
    end

    it 'registers an offense when using `keyword_init: true` and `keyword_init: true` in `Hash.new`' do
      expect_offense(<<~RUBY)
        Struct.new(:foo, keyword_init: true, keyword_init: true)
                                             ^^^^^^^^^^^^^^^^^^ Remove the redundant `keyword_init: true`.
                         ^^^^^^^^^^^^^^^^^^ Remove the redundant `keyword_init: true`.
      RUBY

      expect_correction(<<~RUBY)
        Struct.new(:foo)
      RUBY
    end

    it 'registers an offense when using `keyword_init: nil` and `keyword_init: true` in `Hash.new`' do
      expect_offense(<<~RUBY)
        Struct.new(:foo, keyword_init: nil, keyword_init: true)
                                            ^^^^^^^^^^^^^^^^^^ Remove the redundant `keyword_init: true`.
                         ^^^^^^^^^^^^^^^^^ Remove the redundant `keyword_init: nil`.
      RUBY

      expect_correction(<<~RUBY)
        Struct.new(:foo)
      RUBY
    end

    it 'does not register an offense when using `keyword_init: false` in `Hash.new`' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo, keyword_init: false)
      RUBY
    end

    it 'does not register an offense when not using `keyword_init` keyword argument' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo)
      RUBY
    end

    it 'does not register an offense when using `keyword_init: false` and `keyword_init: true` in `Hash.new`' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo, keyword_init: false, keyword_init: true)
      RUBY
    end
  end

  context 'Ruby <= 3.1', :ruby31, unsupported_on: :prism do
    it 'does not register an offense when using `keyword_init: true` in `Struct.new`' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo, keyword_init: true)
      RUBY
    end

    it 'does not register an offense when using only `keyword_init: true` in `Struct.new`' do
      expect_no_offenses(<<~RUBY)
        Struct.new(keyword_init: true)
      RUBY
    end

    it 'does not register an offense when using `keyword_init: true` in `Struct&.new`' do
      expect_no_offenses(<<~RUBY)
        Struct&.new(:foo, keyword_init: true)
      RUBY
    end

    it 'does not register an offense when using `keyword_init: true` in `::Struct.new`' do
      expect_no_offenses(<<~RUBY)
        ::Struct.new(:foo, keyword_init: true)
      RUBY
    end

    it 'does not register an offense when using `keyword_init: true` and `keyword_init: false` in `Hash.new`' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo, keyword_init: true, keyword_init: false)
      RUBY
    end

    it 'does not register an offense when using `keyword_init: false` in `Hash.new`' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo, keyword_init: false)
      RUBY
    end

    it 'does not register an offense when using `keyword_init: false` and `keyword_init: true` in `Hash.new`' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo, keyword_init: false, keyword_init: true)
      RUBY
    end
  end
end
