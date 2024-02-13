# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RedundantExpectOffenseArguments, :config do
  it 'registers an offense when using `expect_no_offenses` with string and single keyword arguments' do
    expect_offense(<<~RUBY)
      expect_no_offenses('code', keyword: keyword)
                               ^^^^^^^^^^^^^^^^^^ Remove the redundant arguments.
    RUBY

    expect_correction(<<~RUBY)
      expect_no_offenses('code')
    RUBY
  end

  it 'registers an offense when using `expect_no_offenses` with heredoc and single keyword arguments' do
    expect_offense(<<~RUBY)
      expect_no_offenses(<<~CODE, keyword: keyword)
                                ^^^^^^^^^^^^^^^^^^ Remove the redundant arguments.
      CODE
    RUBY

    expect_correction(<<~RUBY)
      expect_no_offenses(<<~CODE)
      CODE
    RUBY
  end

  it 'registers an offense when using `expect_no_offenses` with heredoc multiple keyword arguments' do
    expect_offense(<<~RUBY)
      expect_no_offenses(<<~CODE, foo: foo, bar: bar)
                                ^^^^^^^^^^^^^^^^^^^^ Remove the redundant arguments.
      CODE
    RUBY

    expect_correction(<<~RUBY)
      expect_no_offenses(<<~CODE)
      CODE
    RUBY
  end

  it 'does not register an offense when using `expect_no_offenses` with string argument only' do
    expect_no_offenses(<<~RUBY)
      expect_no_offenses('code')
    RUBY
  end

  it 'does not register an offense when using `expect_no_offenses` with heredoc argument only' do
    expect_no_offenses(<<~RUBY)
      expect_no_offenses(<<~CODE)
      CODE
    RUBY
  end

  it 'does not register an offense when using `expect_no_offenses` with string and positional arguments' do
    expect_no_offenses(<<~RUBY)
      expect_no_offenses('code', file)
    RUBY
  end

  it 'does not register an offense when using `expect_no_offenses` with heredoc and positional arguments' do
    expect_no_offenses(<<~RUBY)
      expect_no_offenses(<<~CODE, file)
      CODE
    RUBY
  end

  it 'does not crash when using `expect_no_offenses` with no arguments' do
    expect_no_offenses(<<~RUBY)
      expect_no_offenses
      CODE
    RUBY
  end
end
