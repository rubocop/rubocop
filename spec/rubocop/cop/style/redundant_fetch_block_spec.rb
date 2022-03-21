# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantFetchBlock, :config do
  context 'with SafeForConstants: true' do
    let(:config) do
      RuboCop::Config.new('Style/RedundantFetchBlock' => { 'SafeForConstants' => true })
    end

    it 'registers an offense and corrects when using `#fetch` with Integer in the block' do
      expect_offense(<<~RUBY)
        hash.fetch(:key) { 5 }
             ^^^^^^^^^^^^^^^^^ Use `fetch(:key, 5)` instead of `fetch(:key) { 5 }`.
      RUBY

      expect_correction(<<~RUBY)
        hash.fetch(:key, 5)
      RUBY
    end

    it 'registers an offense and corrects when using `#fetch` with Float in the block' do
      expect_offense(<<~RUBY)
        hash.fetch(:key) { 2.5 }
             ^^^^^^^^^^^^^^^^^^^ Use `fetch(:key, 2.5)` instead of `fetch(:key) { 2.5 }`.
      RUBY

      expect_correction(<<~RUBY)
        hash.fetch(:key, 2.5)
      RUBY
    end

    it 'registers an offense and corrects when using `#fetch` with Symbol in the block' do
      expect_offense(<<~RUBY)
        hash.fetch(:key) { :value }
             ^^^^^^^^^^^^^^^^^^^^^^ Use `fetch(:key, :value)` instead of `fetch(:key) { :value }`.
      RUBY

      expect_correction(<<~RUBY)
        hash.fetch(:key, :value)
      RUBY
    end

    it 'registers an offense and corrects when using `#fetch` with Rational in the block' do
      expect_offense(<<~RUBY)
        hash.fetch(:key) { 2.0r }
             ^^^^^^^^^^^^^^^^^^^^ Use `fetch(:key, 2.0r)` instead of `fetch(:key) { 2.0r }`.
      RUBY

      expect_correction(<<~RUBY)
        hash.fetch(:key, 2.0r)
      RUBY
    end

    it 'registers an offense and corrects when using `#fetch` with Complex in the block' do
      expect_offense(<<~RUBY)
        hash.fetch(:key) { 1i }
             ^^^^^^^^^^^^^^^^^^ Use `fetch(:key, 1i)` instead of `fetch(:key) { 1i }`.
      RUBY

      expect_correction(<<~RUBY)
        hash.fetch(:key, 1i)
      RUBY
    end

    it 'registers an offense and corrects when using `#fetch` with empty block' do
      expect_offense(<<~RUBY)
        hash.fetch(:key) {}
             ^^^^^^^^^^^^^^ Use `fetch(:key, nil)` instead of `fetch(:key) {}`.
      RUBY

      expect_correction(<<~RUBY)
        hash.fetch(:key, nil)
      RUBY
    end

    it 'registers an offense and corrects when using `#fetch` with constant in the block' do
      expect_offense(<<~RUBY)
        hash.fetch(:key) { CONSTANT }
             ^^^^^^^^^^^^^^^^^^^^^^^^ Use `fetch(:key, CONSTANT)` instead of `fetch(:key) { CONSTANT }`.
      RUBY

      expect_correction(<<~RUBY)
        hash.fetch(:key, CONSTANT)
      RUBY
    end

    it 'registers an offense and corrects when using `#fetch` with String in the block and strings are frozen' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: true
        hash.fetch(:key) { 'value' }
             ^^^^^^^^^^^^^^^^^^^^^^^ Use `fetch(:key, 'value')` instead of `fetch(:key) { 'value' }`.
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true
        hash.fetch(:key, 'value')
      RUBY
    end

    it 'does not register an offense when using `#fetch` with String in the block and strings are not frozen' do
      expect_no_offenses(<<~RUBY)
        hash.fetch(:key) { 'value' }
      RUBY
    end

    it 'does not register an offense when using `#fetch` with argument fallback' do
      expect_no_offenses(<<~RUBY)
        hash.fetch(:key, :value)
      RUBY
    end

    it 'does not register an offense when using `#fetch` with interpolated Symbol in the block' do
      expect_no_offenses('hash.fetch(:key) { :"value_#{value}" }')
    end

    it 'does not register an offense when using `#fetch` with an argument in the block' do
      expect_no_offenses('hash.fetch(:key) { |k| "missing-#{k}" }')
    end

    it 'does not register an offense when using `#fetch` with `Rails.cache`' do
      expect_no_offenses(<<~RUBY)
        Rails.cache.fetch(:key) { :value }
      RUBY
    end
  end

  context 'with SafeForConstants: false' do
    let(:config) do
      RuboCop::Config.new('Style/RedundantFetchBlock' => { 'SafeForConstants' => false })
    end

    it 'does not register an offense when using `#fetch` with constant in the block' do
      expect_no_offenses(<<~RUBY)
        hash.fetch(:key) { CONSTANT }
      RUBY
    end
  end
end
