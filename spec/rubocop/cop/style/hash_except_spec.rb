# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashExcept, :config do
  context 'Ruby 3.0 or higher', :ruby30 do
    it 'registers and corrects an offense when using `reject` and comparing with `lvar == :sym`' do
      expect_offense(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.reject { |k, v| k == :bar }
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.except(:bar)
      RUBY
    end

    it 'registers and corrects an offense when using `reject` and comparing with `:sym == lvar`' do
      expect_offense(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.reject { |k, v| :bar == k }
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.except(:bar)
      RUBY
    end

    it 'registers and corrects an offense when using `select` and comparing with `lvar != :sym`' do
      expect_offense(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.select { |k, v| k != :bar }
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.except(:bar)
      RUBY
    end

    it 'registers and corrects an offense when using `select` and comparing with `:sym != lvar`' do
      expect_offense(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.select { |k, v| :bar != k }
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.except(:bar)
      RUBY
    end

    it "registers and corrects an offense when using `reject` and comparing with `lvar == 'str'`" do
      expect_offense(<<~RUBY)
        hash.reject { |k, v| k == 'str' }
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except('str')` instead.
      RUBY

      expect_correction(<<~RUBY)
        hash.except('str')
      RUBY
    end

    it 'registers and corrects an offense when using `reject` and other than comparison by string and symbol using `eql?`' do
      expect_offense(<<~RUBY)
        hash.reject { |k, v| k.eql?(0.0) }
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(0.0)` instead.
      RUBY

      expect_correction(<<~RUBY)
        hash.except(0.0)
      RUBY
    end

    it 'registers and corrects an offense when using `filter` and comparing with `lvar != :sym`' do
      expect_offense(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.filter { |k, v| k != :bar }
                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `except(:bar)` instead.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.except(:bar)
      RUBY
    end

    it 'does not register an offense when using `reject` and other than comparison by string and symbol using `==`' do
      expect_no_offenses(<<~RUBY)
        hash.reject { |k, v| k == 0.0 }
      RUBY
    end

    it 'does not register an offense when using `delete_if` and comparing with `lvar == :sym`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.delete_if { |k, v| k == :bar }
      RUBY
    end

    it 'does not register an offense when using `keep_if` and comparing with `lvar != :sym`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.keep_if { |k, v| k != :bar }
      RUBY
    end

    it 'does not register an offense when comparing with hash value' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.reject { |k, v| v.eql? :bar }
      RUBY
    end
  end

  context 'Ruby 2.7 or lower', :ruby27 do
    it 'does not register an offense when using `reject` and comparing with `lvar == :key`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.reject { |k, v| k == :bar }
      RUBY
    end

    it 'does not register an offense when using `reject` and comparing with `:key == lvar`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.reject { |k, v| :bar == k }
      RUBY
    end

    it 'does not register an offense when using `select` and comparing with `lvar != :key`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.select { |k, v| k != :bar }
      RUBY
    end

    it 'does not register an offense when using `select` and comparing with `:key != lvar`' do
      expect_no_offenses(<<~RUBY)
        {foo: 1, bar: 2, baz: 3}.select { |k, v| :bar != k }
      RUBY
    end
  end

  it 'does not register an offense when using `reject` and comparing with `lvar != :key`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.reject { |k, v| k != :bar }
    RUBY
  end

  it 'does not register an offense when using `reject` and comparing with `:key != lvar`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.reject { |k, v| :bar != key }
    RUBY
  end

  it 'does not register an offense when using `select` and comparing with `lvar == :key`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.select { |k, v| k == :bar }
    RUBY
  end

  it 'does not register an offense when using `select` and comparing with `:key == lvar`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.select { |k, v| :bar == key }
    RUBY
  end

  it 'does not register an offense when not using key block argument`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.reject { |k, v| do_something != :bar }
    RUBY
  end

  it 'does not register an offense when not using block`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.reject
    RUBY
  end

  it 'does not register an offense when using `Hash#except`' do
    expect_no_offenses(<<~RUBY)
      {foo: 1, bar: 2, baz: 3}.except(:bar)
    RUBY
  end
end
