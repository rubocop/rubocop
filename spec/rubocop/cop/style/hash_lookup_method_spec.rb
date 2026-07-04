# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashLookupMethod, :config do
  context 'with EnforcedStyle: brackets (default)' do
    let(:cop_config) { { 'EnforcedStyle' => 'brackets' } }

    it 'registers an offense for fetch with one argument' do
      expect_offense(<<~RUBY)
        hash.fetch(key)
             ^^^^^ Use `Hash#[]` instead of `Hash#fetch`.
      RUBY

      expect_correction(<<~RUBY)
        hash[key]
      RUBY
    end

    it 'registers an offense for fetch with one argument and receiver chain' do
      expect_offense(<<~RUBY)
        some_method.hash.fetch(key)
                         ^^^^^ Use `Hash#[]` instead of `Hash#fetch`.
      RUBY

      expect_correction(<<~RUBY)
        some_method.hash[key]
      RUBY
    end

    it 'accepts bracket access' do
      expect_no_offenses('hash[key]')
    end

    it 'registers an offense for chained fetch calls without raising a clobbering error' do
      expect_offense(<<~RUBY)
        result.fetch(:foo).fetch(:bar)
               ^^^^^ Use `Hash#[]` instead of `Hash#fetch`.
                           ^^^^^ Use `Hash#[]` instead of `Hash#fetch`.
      RUBY

      expect_correction(<<~RUBY)
        result[:foo][:bar]
      RUBY
    end

    it 'accepts fetch with default value' do
      expect_no_offenses('hash.fetch(key, default)')
    end

    it 'accepts fetch with block' do
      expect_no_offenses('hash.fetch(key) { default }')
    end

    it 'accepts `fetch` without receiver' do
      expect_no_offenses('fetch(key)')
    end

    it 'accepts `fetch` without receiver and with block' do
      expect_no_offenses('fetch(key) { default }')
    end

    context 'when using safe navigation operator' do
      it 'does not register an offense for fetch with one argument' do
        # The bracket equivalent would be the unreadable `hash&.[](key)`.
        expect_no_offenses(<<~RUBY)
          hash&.fetch(key)
        RUBY
      end
    end
  end

  context 'with EnforcedStyle: fetch' do
    let(:cop_config) { { 'EnforcedStyle' => 'fetch' } }

    it 'registers an offense for bracket access with one argument' do
      expect_offense(<<~RUBY)
        hash[key]
        ^^^^^^^^^ Use `Hash#fetch` instead of `Hash#[]`.
      RUBY

      expect_correction(<<~RUBY)
        hash.fetch(key)
      RUBY
    end

    it 'registers an offense for bracket access with receiver chain' do
      expect_offense(<<~RUBY)
        some_method.hash[key]
        ^^^^^^^^^^^^^^^^^^^^^ Use `Hash#fetch` instead of `Hash#[]`.
      RUBY

      expect_correction(<<~RUBY)
        some_method.hash.fetch(key)
      RUBY
    end

    it 'accepts fetch with one argument' do
      expect_no_offenses('hash.fetch(key)')
    end

    it 'accepts fetch with default value' do
      expect_no_offenses('hash.fetch(key, default)')
    end

    it 'accepts fetch with block' do
      expect_no_offenses('hash.fetch(key) { default }')
    end

    it 'does not flag bracket access with multiple arguments' do
      expect_no_offenses('array[1, 2]')
    end

    it 'registers an offense for chained bracket access without raising a clobbering error' do
      expect_offense(<<~RUBY)
        result[:foo][:bar]
        ^^^^^^^^^^^^^^^^^^ Use `Hash#fetch` instead of `Hash#[]`.
        ^^^^^^^^^^^^ Use `Hash#fetch` instead of `Hash#[]`.
      RUBY

      expect_correction(<<~RUBY)
        result.fetch(:foo).fetch(:bar)
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense for bracket access' do
        expect_offense(<<~RUBY)
          hash&.[](key)
          ^^^^^^^^^^^^^ Use `Hash#fetch` instead of `Hash#[]`.
        RUBY

        expect_correction(<<~RUBY)
          hash&.fetch(key)
        RUBY
      end
    end
  end

  context "when `AllowedReceivers: ['Rails.cache']`" do
    let(:cop_config) { { 'AllowedReceivers' => ['Rails.cache'] } }

    it 'does not register an offense for `Rails.cache.fetch(name, options) { block }`' do
      expect_no_offenses(<<~RUBY)
        Rails.cache.fetch(name, options) { block }
      RUBY
    end
  end
end
