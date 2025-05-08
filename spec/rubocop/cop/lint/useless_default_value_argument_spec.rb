# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessDefaultValueArgument, :config do
  context 'with `fetch`' do
    it 'registers an offense for `x.fetch(key, default_value) { block_value }`' do
      expect_offense(<<~RUBY)
        x.fetch(key, default_value) { block_value }
                     ^^^^^^^^^^^^^ Block supersedes default value argument.
      RUBY

      expect_correction(<<~RUBY)
        x.fetch(key) { block_value }
      RUBY
    end

    it 'registers an offense for `x.fetch(key, default_value) { |arg| arg }`' do
      expect_offense(<<~RUBY)
        x.fetch(key, default_value) { |arg| arg }
                     ^^^^^^^^^^^^^ Block supersedes default value argument.
      RUBY

      expect_correction(<<~RUBY)
        x.fetch(key) { |arg| arg }
      RUBY
    end

    it 'registers an offense for `x&.fetch(key, default_value) { block_value }`' do
      expect_offense(<<~RUBY)
        x&.fetch(key, default_value) { block_value }
                      ^^^^^^^^^^^^^ Block supersedes default value argument.
      RUBY

      expect_correction(<<~RUBY)
        x&.fetch(key) { block_value }
      RUBY
    end

    it 'registers an offense for `x&.fetch(key, default_value) { |arg| arg }`' do
      expect_offense(<<~RUBY)
        x&.fetch(key, default_value) { |arg| arg }
                      ^^^^^^^^^^^^^ Block supersedes default value argument.
      RUBY

      expect_correction(<<~RUBY)
        x&.fetch(key) { |arg| arg }
      RUBY
    end

    it 'registers an offense for `x.fetch(key, {}) { block_value }`' do
      expect_offense(<<~RUBY)
        x.fetch(key, {}) { block_value }
                     ^^ Block supersedes default value argument.
      RUBY

      expect_correction(<<~RUBY)
        x.fetch(key) { block_value }
      RUBY
    end

    it 'registers an offense for `x.fetch(key, default_value) { _1 }`' do
      expect_offense(<<~RUBY)
        x.fetch(key, default_value) { _1 }
                     ^^^^^^^^^^^^^ Block supersedes default value argument.
      RUBY

      expect_correction(<<~RUBY)
        x.fetch(key) { _1 }
      RUBY
    end

    it 'registers an offense for `x.fetch(key, default_value) { it }`' do
      expect_offense(<<~RUBY)
        x.fetch(key, default_value) { it }
                     ^^^^^^^^^^^^^ Block supersedes default value argument.
      RUBY

      expect_correction(<<~RUBY)
        x.fetch(key) { it }
      RUBY
    end

    it 'does not register an offense for `x.fetch(key, default: value) { block_value }`' do
      expect_no_offenses(<<~RUBY)
        x.fetch(key, default: value) { block_value }
      RUBY
    end

    it 'does not register an offense for `x.fetch(key, default_value)`' do
      expect_no_offenses(<<~RUBY)
        x.fetch(key, default_value)
      RUBY
    end

    it 'does not register an offense for `x.fetch(key) { block_value }`' do
      expect_no_offenses(<<~RUBY)
        x.fetch(key) { block_value }
      RUBY
    end

    it 'does not register an offense for `x.fetch(key) { |arg1, arg2| block_value }`' do
      expect_no_offenses(<<~RUBY)
        x.fetch(key) { |arg1, arg2| block_value }
      RUBY
    end

    it 'does not register an offense for `x.fetch(key, default_value, third_argument) { block_value }`' do
      expect_no_offenses(<<~RUBY)
        x.fetch(key, default_value, third_argument) { block_value }
      RUBY
    end

    it 'does not register an offense for `x.fetch(key, **kwarg) { block_value }`' do
      expect_no_offenses(<<~RUBY)
        x.fetch(key, **kwarg) { block_value }
      RUBY
    end
  end

  context 'with `Array.new`' do
    it 'registers an offense for `Array.new(size, default_value) { block_value }`' do
      expect_offense(<<~RUBY)
        Array.new(size, default_value) { block_value }
                        ^^^^^^^^^^^^^ Block supersedes default value argument.
      RUBY

      expect_correction(<<~RUBY)
        Array.new(size) { block_value }
      RUBY
    end

    it 'registers an offense for `::Array.new(size, default_value) { block_value }`' do
      expect_offense(<<~RUBY)
        ::Array.new(size, default_value) { block_value }
                          ^^^^^^^^^^^^^ Block supersedes default value argument.
      RUBY

      expect_correction(<<~RUBY)
        ::Array.new(size) { block_value }
      RUBY
    end

    it 'registers an offense for `Array.new(size, default_value) { _1 }`' do
      expect_offense(<<~RUBY)
        Array.new(size, default_value) { _1 }
                        ^^^^^^^^^^^^^ Block supersedes default value argument.
      RUBY

      expect_correction(<<~RUBY)
        Array.new(size) { _1 }
      RUBY
    end

    it 'registers an offense for `Array.new(size, default_value) { it }`' do
      expect_offense(<<~RUBY)
        Array.new(size, default_value) { it }
                        ^^^^^^^^^^^^^ Block supersedes default value argument.
      RUBY

      expect_correction(<<~RUBY)
        Array.new(size) { it }
      RUBY
    end

    it 'does not register an offense for `Array.new(size, default_value)`' do
      expect_no_offenses(<<~RUBY)
        Array.new(size, default_value)
      RUBY
    end

    it 'does not register an offense for `Array.new(size)`' do
      expect_no_offenses(<<~RUBY)
        Array.new(size)
      RUBY
    end

    it 'does not register an offense for `Array.new(size) { block_value }`' do
      expect_no_offenses(<<~RUBY)
        Array.new(size) { block_value }
      RUBY
    end

    it 'does not register an offense for `Array.new(size) { |arg1, arg2| block_value }`' do
      expect_no_offenses(<<~RUBY)
        Array.new(size) { |arg1, arg2| block_value }
      RUBY
    end

    it 'does not register an offense for `Array.new(size, default_value, third_argument) { block_value }`' do
      expect_no_offenses(<<~RUBY)
        Array.new(size, default_value, third_argument) { block_value }
      RUBY
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
