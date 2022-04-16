# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateRequire, :config do
  it 'registers and corrects an offense when duplicate `require` is detected' do
    expect_offense(<<~RUBY)
      require 'foo'
      require 'foo'
      ^^^^^^^^^^^^^ Duplicate `require` detected.
    RUBY

    expect_correction(<<~RUBY)
      require 'foo'
    RUBY
  end

  it 'registers and corrects an offense when duplicate `require_relative` is detected' do
    expect_offense(<<~RUBY)
      require_relative '../bar'
      require_relative '../bar'
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Duplicate `require_relative` detected.
    RUBY

    expect_correction(<<~RUBY)
      require_relative '../bar'
    RUBY
  end

  it 'registers and corrects an offense when duplicate `require` through `Kernel` is detected' do
    expect_offense(<<~RUBY)
      require 'foo'
      Kernel.require 'foo'
      ^^^^^^^^^^^^^^^^^^^^ Duplicate `require` detected.
    RUBY

    expect_correction(<<~RUBY)
      require 'foo'
    RUBY
  end

  it 'registers and corrects an offense for multiple duplicate requires' do
    expect_offense(<<~RUBY)
      require 'foo'
      require_relative '../bar'
      require 'foo/baz'
      require_relative '../bar'
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Duplicate `require_relative` detected.
      Kernel.require 'foo'
      ^^^^^^^^^^^^^^^^^^^^ Duplicate `require` detected.
      require 'quux'
    RUBY

    expect_correction(<<~RUBY)
      require 'foo'
      require_relative '../bar'
      require 'foo/baz'
      require 'quux'
    RUBY
  end

  it 'registers and corrects an offense when duplicate requires are interleaved with some other code' do
    expect_offense(<<~RUBY)
      require 'foo'
      def m
      end
      require 'foo'
      ^^^^^^^^^^^^^ Duplicate `require` detected.
    RUBY

    expect_correction(<<~RUBY)
      require 'foo'
      def m
      end
    RUBY
  end

  it 'registers and corrects an offense for duplicate non top-level requires' do
    expect_offense(<<~RUBY)
      def m
        require 'foo'
        require 'foo'
        ^^^^^^^^^^^^^ Duplicate `require` detected.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m
        require 'foo'
      end
    RUBY
  end

  it 'does not register an offense when there are no duplicate `require`s' do
    expect_no_offenses(<<~RUBY)
      require 'foo'
      require 'bar'
    RUBY
  end

  it 'does not register an offense when using single `require`' do
    expect_no_offenses(<<~RUBY)
      require 'foo'
    RUBY
  end

  it 'does not register an offense when same feature argument but different require method' do
    expect_no_offenses(<<~RUBY)
      require 'feature'
      require_relative 'feature'
    RUBY
  end

  it 'does not register an offense when calling user-defined `require` method' do
    expect_no_offenses(<<~RUBY)
      params.require(:user)
      params.require(:user)
    RUBY
  end
end
