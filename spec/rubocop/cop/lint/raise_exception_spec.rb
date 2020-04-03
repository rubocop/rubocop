# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RaiseException do
  subject(:cop) { described_class.new }

  it 'registers an offense for `raise` with `::Exception`' do
    expect_offense(<<~RUBY)
      raise ::Exception
      ^^^^^^^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY
  end

  it 'registers an offense for `raise` with `::Exception.new`' do
    expect_offense(<<~RUBY)
      raise ::Exception.new 'Error with exception'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY
  end

  it 'registers an offense for `raise` with `::Exception` and message' do
    expect_offense(<<~RUBY)
      raise ::Exception, 'Error with exception'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY
  end

  it 'registers an offense for `raise` with `Exception`' do
    expect_offense(<<~RUBY)
      raise Exception
      ^^^^^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY
  end

  it 'registers an offense for `raise` with `Exception` and message' do
    expect_offense(<<~RUBY)
      raise Exception, 'Error with exception'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY
  end

  it 'registers an offense for `raise` with `Exception.new` and message' do
    expect_offense(<<~RUBY)
      raise Exception.new 'Error with exception'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY
  end

  it 'registers an offense for `raise` with `Exception.new(args*)` ' do
    expect_offense(<<~RUBY)
      raise Exception.new('arg1', 'arg2')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY
  end

  it 'registers an offense for `fail` with `Exception`' do
    expect_offense(<<~RUBY)
      fail Exception
      ^^^^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY
  end

  it 'registers an offense for `fail` with `Exception` and message' do
    expect_offense(<<~RUBY)
      fail Exception, 'Error with exception'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY
  end

  it 'registers an offense for `fail` with `Exception.new` and message' do
    expect_offense(<<~RUBY)
      fail Exception.new 'Error with exception'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY
  end

  it 'does not register an offense for `raise` without arguments' do
    expect_no_offenses('raise')
  end

  it 'does not register an offense for `fail` without arguments' do
    expect_no_offenses('fail')
  end

  it 'does not register an offense when raising Exception with explicit ' \
     'namespace' do
    expect_no_offenses(<<~RUBY)
      raise Foo::Exception
    RUBY
  end
end
