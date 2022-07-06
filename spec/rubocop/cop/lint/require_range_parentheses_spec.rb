# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RequireRangeParentheses, :config do
  it 'registers an offense when the end of the range (`..`) is line break' do
    expect_offense(<<~RUBY)
      42..
      ^^^^ Wrap the endless range literal `42..` to avoid precedence ambiguity.
      do_something
    RUBY
  end

  it 'registers an offense when the end of the range (`...`) is line break' do
    expect_offense(<<~RUBY)
      42...
      ^^^^^ Wrap the endless range literal `42...` to avoid precedence ambiguity.
      do_something
    RUBY
  end

  it 'does not register an offense when the end of the range (`..`) is line break and is enclosed in parentheses' do
    expect_no_offenses(<<~RUBY)
      (42..
      do_something)
    RUBY
  end

  context 'Ruby >= 2.6', :ruby26 do
    it 'does not register an offense when using endless range only' do
      expect_no_offenses(<<~RUBY)
        42..
      RUBY
    end
  end

  context 'Ruby >= 2.7', :ruby27 do
    it 'does not register an offense when using beginless range only' do
      expect_no_offenses(<<~RUBY)
        ..42
      RUBY
    end
  end

  it 'does not register an offense when using `42..nil`' do
    expect_no_offenses(<<~RUBY)
      42..nil
    RUBY
  end

  it 'does not register an offense when using `nil..42`' do
    expect_no_offenses(<<~RUBY)
      nil..42
    RUBY
  end

  it 'does not register an offense when begin and end of the range are on the same line' do
    expect_no_offenses(<<~RUBY)
      42..do_something
    RUBY
  end
end
