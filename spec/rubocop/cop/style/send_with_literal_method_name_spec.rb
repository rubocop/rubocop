# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SendWithLiteralMethodName, :config do
  it 'registers an offense when using `public_send` with symbol literal argument' do
    expect_offense(<<~RUBY)
      obj.public_send(:foo)
          ^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
    RUBY

    expect_correction(<<~RUBY)
      obj.foo
    RUBY
  end

  it 'registers an offense when using `public_send` with symbol literal argument and some arguments with parentheses' do
    expect_offense(<<~RUBY)
      obj.public_send(:foo, bar, 42)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
    RUBY

    expect_correction(<<~RUBY)
      obj.foo(bar, 42)
    RUBY
  end

  it 'registers an offense when using `public_send` with symbol literal argument and some arguments without parentheses' do
    expect_offense(<<~RUBY)
      obj.public_send :foo, bar, 42
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
    RUBY

    expect_correction(<<~RUBY)
      obj.foo bar, 42
    RUBY
  end

  it 'registers an offense when using `public_send` with symbol literal argument without receiver' do
    expect_offense(<<~RUBY)
      public_send(:foo)
      ^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
    RUBY

    expect_correction(<<~RUBY)
      foo
    RUBY
  end

  it 'registers an offense when using `public_send` with string literal argument' do
    expect_offense(<<~RUBY)
      obj.public_send('foo')
          ^^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
    RUBY

    expect_correction(<<~RUBY)
      obj.foo
    RUBY
  end

  it 'registers an offense when using `public_send` with method name with underscore' do
    expect_offense(<<~RUBY)
      obj.public_send("name_with_underscore")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `name_with_underscore` method call directly instead.
    RUBY

    expect_correction(<<~RUBY)
      obj.name_with_underscore
    RUBY
  end

  it 'does not register an offense when using `public_send` with variable argument' do
    expect_no_offenses(<<~RUBY)
      obj.public_send(variable)
    RUBY
  end

  it 'does not register an offense when using `public_send` with interpolated string argument' do
    expect_no_offenses(<<~'RUBY')
      obj.public_send("#{interpolated}string")
    RUBY
  end

  it 'does not register an offense when using `public_send` with method name with space' do
    expect_no_offenses(<<~RUBY)
      obj.public_send("name with space")
    RUBY
  end

  it 'does not register an offense when using `public_send` with method name with hyphen' do
    expect_no_offenses(<<~RUBY)
      obj.public_send("name-with-hyphen")
    RUBY
  end

  it 'does not register an offense when using `public_send` with writer method name' do
    expect_no_offenses(<<~RUBY)
      obj.public_send("name=")
    RUBY
  end

  it 'does not register an offense when using `public_send` with method name with brackets' do
    expect_no_offenses(<<~RUBY)
      obj.public_send("{brackets}")
    RUBY
  end

  it 'does not register an offense when using `public_send` with method name with square brackets' do
    expect_no_offenses(<<~RUBY)
      obj.public_send("[square_brackets]")
    RUBY
  end

  it 'does not register an offense when using `public_send` with reserved word argument' do
    described_class::RESERVED_WORDS.each do |reserved_word|
      expect_no_offenses(<<~RUBY)
        obj.public_send(:#{reserved_word})
      RUBY
    end
  end

  it 'does not register an offense when using `public_send` with integer literal argument' do
    expect_no_offenses(<<~RUBY)
      obj.public_send(42)
    RUBY
  end

  it 'does not register an offense when using `public_send` with no arguments' do
    expect_no_offenses(<<~RUBY)
      obj.public_send
    RUBY
  end

  it 'does not register an offense when using method call without `public_send`' do
    expect_no_offenses(<<~RUBY)
      obj.foo
    RUBY
  end

  context 'when `AllowSend: true`' do
    let(:cop_config) { { 'AllowSend' => true } }

    it 'does not register an offense when using `send` with symbol literal argumen' do
      expect_no_offenses(<<~RUBY)
        obj.send(:foo)
      RUBY
    end

    it 'does not register an offense when using `__send__` with symbol literal argument' do
      expect_no_offenses(<<~RUBY)
        obj.__send__(:foo)
      RUBY
    end
  end

  context 'when `AllowSend: false`' do
    let(:cop_config) { { 'AllowSend' => false } }

    it 'registers an offense when using `send` with symbol literal argument' do
      expect_offense(<<~RUBY)
        obj.send(:foo)
            ^^^^^^^^^^ Use `foo` method call directly instead.
      RUBY

      expect_correction(<<~RUBY)
        obj.foo
      RUBY
    end

    it 'registers an offense when using `__send__` with symbol literal argument' do
      expect_offense(<<~RUBY)
        obj.__send__(:foo)
            ^^^^^^^^^^^^^^ Use `foo` method call directly instead.
      RUBY

      expect_correction(<<~RUBY)
        obj.foo
      RUBY
    end
  end
end
