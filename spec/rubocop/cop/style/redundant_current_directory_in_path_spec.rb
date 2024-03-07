# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantCurrentDirectoryInPath, :config do
  it "registers an offense when using a current directory path in `require_relative '...'`" do
    expect_offense(<<~RUBY)
      require_relative './path/to/feature'
                        ^^ Remove the redundant current directory path.
    RUBY

    expect_correction(<<~RUBY)
      require_relative 'path/to/feature'
    RUBY
  end

  it "registers an offense when using a current directory path with string interpolation in `require_relative '...'`" do
    expect_offense(<<~'RUBY')
      require_relative './path/#{to}/feature'
                        ^^ Remove the redundant current directory path.
    RUBY

    expect_correction(<<~'RUBY')
      require_relative 'path/#{to}/feature'
    RUBY
  end

  it 'registers an offense when using a current directory path in `require_relative %q(...)`' do
    expect_offense(<<~RUBY)
      require_relative %q(./path/to/feature)
                          ^^ Remove the redundant current directory path.
    RUBY

    expect_correction(<<~RUBY)
      require_relative %q(path/to/feature)
    RUBY
  end

  it 'does not register an offense when using a parent directory path in `require_relative`' do
    expect_no_offenses(<<~RUBY)
      require_relative '../path/to/feature'
    RUBY
  end

  it 'does not register an offense when not using a current directory path in `require_relative`' do
    expect_no_offenses(<<~RUBY)
      require_relative 'path/to/feature'
    RUBY
  end

  it 'does not register an offense when not using a current directory path with string interpolation in `require_relative`' do
    expect_no_offenses(<<~'RUBY')
      require_relative "path/#{to}/feature"
    RUBY
  end

  it 'does not register an offense when not using a current directory path in not `require_relative`' do
    expect_no_offenses(<<~RUBY)
      do_something './path/to/feature'
    RUBY
  end

  it 'does not register an offense when a method with no arguments is used' do
    expect_no_offenses(<<~RUBY)
      do_something
    RUBY
  end

  it 'does not register an offense when a `require_relative` with no arguments is used' do
    expect_no_offenses(<<~RUBY)
      require_relative
    RUBY
  end
end
