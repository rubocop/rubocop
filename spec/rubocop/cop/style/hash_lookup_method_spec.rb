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
      it 'registers an offense for fetch with one argument' do
        expect_offense(<<~RUBY)
          hash&.fetch(key)
                ^^^^^ Use `Hash#[]` instead of `Hash#fetch`.
        RUBY

        expect_correction(<<~RUBY)
          (hash[key])
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
end
