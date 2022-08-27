# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RaiseException, :config do
  let(:cop_config) { { 'AllowedImplicitNamespaces' => ['Gem'] } }

  it 'registers an offense and corrects for `raise` with `::Exception`' do
    expect_offense(<<~RUBY)
      raise ::Exception
            ^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY

    expect_correction(<<~RUBY)
      raise ::StandardError
    RUBY
  end

  it 'registers an offense and corrects for `raise` with `::Exception.new`' do
    expect_offense(<<~RUBY)
      raise ::Exception.new 'Error with exception'
            ^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY

    expect_correction(<<~RUBY)
      raise ::StandardError.new 'Error with exception'
    RUBY
  end

  it 'registers an offense and corrects for `raise` with `::Exception` and message' do
    expect_offense(<<~RUBY)
      raise ::Exception, 'Error with exception'
            ^^^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY

    expect_correction(<<~RUBY)
      raise ::StandardError, 'Error with exception'
    RUBY
  end

  it 'registers an offense and corrects for `raise` with `Exception`' do
    expect_offense(<<~RUBY)
      raise Exception
            ^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY

    expect_correction(<<~RUBY)
      raise StandardError
    RUBY
  end

  it 'registers an offense and corrects for `raise` with `Exception` and message' do
    expect_offense(<<~RUBY)
      raise Exception, 'Error with exception'
            ^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY

    expect_correction(<<~RUBY)
      raise StandardError, 'Error with exception'
    RUBY
  end

  it 'registers an offense and corrects for `raise` with `Exception.new` and message' do
    expect_offense(<<~RUBY)
      raise Exception.new 'Error with exception'
            ^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY

    expect_correction(<<~RUBY)
      raise StandardError.new 'Error with exception'
    RUBY
  end

  it 'registers an offense and corrects for `raise` with `Exception.new(args*)`' do
    expect_offense(<<~RUBY)
      raise Exception.new('arg1', 'arg2')
            ^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY

    expect_correction(<<~RUBY)
      raise StandardError.new('arg1', 'arg2')
    RUBY
  end

  it 'registers an offense and corrects for `fail` with `Exception`' do
    expect_offense(<<~RUBY)
      fail Exception
           ^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY

    expect_correction(<<~RUBY)
      fail StandardError
    RUBY
  end

  it 'registers an offense and corrects for `fail` with `Exception` and message' do
    expect_offense(<<~RUBY)
      fail Exception, 'Error with exception'
           ^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY

    expect_correction(<<~RUBY)
      fail StandardError, 'Error with exception'
    RUBY
  end

  it 'registers an offense and corrects for `fail` with `Exception.new` and message' do
    expect_offense(<<~RUBY)
      fail Exception.new 'Error with exception'
           ^^^^^^^^^ Use `StandardError` over `Exception`.
    RUBY

    expect_correction(<<~RUBY)
      fail StandardError.new 'Error with exception'
    RUBY
  end

  it 'does not register an offense for `raise` without arguments' do
    expect_no_offenses('raise')
  end

  it 'does not register an offense for `fail` without arguments' do
    expect_no_offenses('fail')
  end

  it 'does not register an offense when raising Exception with explicit namespace' do
    expect_no_offenses(<<~RUBY)
      raise Foo::Exception
    RUBY
  end

  context 'when under namespace' do
    it 'does not register an offense when Exception without cbase specified' do
      expect_no_offenses(<<~RUBY)
        module Gem
          def self.foo
            raise Exception
          end
        end
      RUBY
    end

    it 'registers an offense and corrects when Exception with cbase specified' do
      expect_offense(<<~RUBY)
        module Gem
          def self.foo
            raise ::Exception
                  ^^^^^^^^^^^ Use `StandardError` over `Exception`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Gem
          def self.foo
            raise ::StandardError
          end
        end
      RUBY
    end
  end
end
