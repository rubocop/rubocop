# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RefuteMethods do
  subject(:cop) { described_class.new }

  it 'registers an offense and correct using `refute` with a single argument' do
    expect_offense(<<~RUBY)
      refute foo
      ^^^^^^ Prefer `assert_not` over `refute`.
    RUBY

    expect_correction(<<~RUBY)
      assert_not foo
    RUBY
  end

  it 'registers an offense and corrects using `refute` ' \
    'with multiple arguments' do
    expect_offense(<<~RUBY)
      refute foo, bar, baz
      ^^^^^^ Prefer `assert_not` over `refute`.
    RUBY

    expect_correction(<<~RUBY)
      assert_not foo, bar, baz
    RUBY
  end

  it 'registers an offense when using `refute_empty`' do
    expect_offense(<<~RUBY)
      refute_empty foo
      ^^^^^^^^^^^^ Prefer `assert_not_empty` over `refute_empty`.
    RUBY

    expect_correction(<<~RUBY)
      assert_not_empty foo
    RUBY
  end

  it 'does not registers an offense when using `assert_not` ' \
     'with a single argument' do
    expect_no_offenses(<<~RUBY)
      assert_not foo
    RUBY
  end

  it 'does not registers an offense when using `assert_not` ' \
     'with a multiple arguments' do
    expect_no_offenses(<<~RUBY)
      assert_not foo, bar, baz
    RUBY
  end
end
