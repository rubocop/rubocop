# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantFileExtensionInRequire, :config do
  it 'registers an offense and corrects when requiring filename ending with `.rb`' do
    expect_offense(<<~RUBY)
      require 'foo.rb'
                  ^^^ Redundant `.rb` file extension detected.
      require_relative '../foo.rb'
                              ^^^ Redundant `.rb` file extension detected.
    RUBY

    expect_correction(<<~RUBY)
      require 'foo'
      require_relative '../foo'
    RUBY
  end

  it 'does not register an offense when requiring filename ending with `.so`' do
    expect_no_offenses(<<~RUBY)
      require 'foo.so'
      require_relative '../foo.so'
    RUBY
  end

  it 'does not register an offense when requiring filename without an extension' do
    expect_no_offenses(<<~RUBY)
      require 'foo'
      require_relative '../foo'
    RUBY
  end

  it 'does not register an offense when requiring variable as a filename' do
    expect_no_offenses(<<~RUBY)
      require name
      require_relative name
    RUBY
  end
end
