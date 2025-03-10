# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SharedMutableDefault, :config do
  context 'when line is unrelated' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        []
        {}
        Array.new
        Hash.new
        Hash.new { |h, k| h[k] = [] }
        Hash.new { |h, k| h[k] = {} }
        Hash.new { 0 }
        Hash.new { Array.new }
        Hash.new { Hash.new }
        Hash.new { {} }
        Hash.new { [] }
        Hash.new(0)
        Hash.new(false)
        Hash.new(true)
        Hash.new(nil)
        Hash.new(BigDecimal(0))
        Hash.new(BigDecimal(0.0))
        Hash.new(0.0)
        Hash.new(0.0.to_d)
      RUBY
    end
  end

  context 'when default literal is frozen' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Hash.new([].freeze)
        Hash.new({}.freeze)
        Hash.new(Array.new.freeze)
        Hash.new(Hash.new.freeze)
      RUBY
    end
  end

  context 'when `capacity` keyword argument is used' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Hash.new(capacity: 42)
      RUBY
    end
  end

  context 'when Hash is initialized with an array' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Hash.new([])
        ^^^^^^^^^^^^ Do not create a Hash with a mutable default value [...]
        Hash.new Array.new
        ^^^^^^^^^^^^^^^^^^ Do not create a Hash with a mutable default value [...]
      RUBY
    end
  end

  context 'when Hash is initialized with a hash' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Hash.new({})
        ^^^^^^^^^^^^ Do not create a Hash with a mutable default value [...]
        Hash.new(Hash.new)
        ^^^^^^^^^^^^^^^^^^ Do not create a Hash with a mutable default value [...]
      RUBY
    end
  end

  context 'when Hash is initialized with a Hash and `capacity` keyword argument' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Hash.new({}, capacity: 42)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not create a Hash with a mutable default value [...]
      RUBY
    end
  end
end
