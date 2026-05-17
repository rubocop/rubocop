# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RequireRelative, :config do
  it 'registers an offense and corrects when using require with __dir__ interpolation' do
    expect_offense(<<~RUBY)
      require "\#{__dir__}/foo"
      ^^^^^^^^^^^^^^^^^^^^^^^^ Use `require_relative` instead of `require` for paths relative to the current file.
    RUBY

    expect_correction(<<~RUBY)
      require_relative 'foo'
    RUBY
  end

  it 'registers an offense and corrects for nested paths with __dir__ interpolation' do
    expect_offense(<<~RUBY)
      require "\#{__dir__}/foo/bar"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `require_relative` instead of `require` for paths relative to the current file.
    RUBY

    expect_correction(<<~RUBY)
      require_relative 'foo/bar'
    RUBY
  end

  it 'registers an offense and corrects when using require with File.expand_path and __dir__' do
    expect_offense(<<~RUBY)
      require File.expand_path('foo', __dir__)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `require_relative` instead of `require` for paths relative to the current file.
    RUBY

    expect_correction(<<~RUBY)
      require_relative 'foo'
    RUBY
  end

  it 'registers an offense and corrects for relative paths with File.expand_path and __dir__' do
    expect_offense(<<~RUBY)
      require File.expand_path('../foo', __dir__)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `require_relative` instead of `require` for paths relative to the current file.
    RUBY

    expect_correction(<<~RUBY)
      require_relative '../foo'
    RUBY
  end

  it 'does not register an offense when already using require_relative' do
    expect_no_offenses(<<~RUBY)
      require_relative 'foo'
    RUBY
  end

  it 'does not register an offense for external gem requires' do
    expect_no_offenses(<<~RUBY)
      require 'foo'
    RUBY
  end

  it 'does not register an offense for require with a plain string variable' do
    expect_no_offenses(<<~RUBY)
      require name
    RUBY
  end

  it 'does not register an offense for require with non-__dir__ interpolation' do
    expect_no_offenses(<<~RUBY)
      require "\#{some_path}/foo"
    RUBY
  end
end
