# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::AssertNot do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects using `assert !`' do
    expect_offense(<<~RUBY)
      assert !foo
      ^^^^^^^^^^^ Prefer `assert_not` over `assert !`.
    RUBY

    expect_correction(<<~RUBY)
      assert_not foo
    RUBY
  end

  it 'registers an offense and corrects using `assert !` ' \
    'with a failure message' do
    expect_offense(<<~RUBY)
      assert !foo, 'a failure message'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `assert_not` over `assert !`.
    RUBY

    expect_correction(<<~RUBY)
      assert_not foo, 'a failure message'
    RUBY
  end

  it 'registers an offense and corrects using `assert !` ' \
    'with a more complex value' do
    expect_offense(<<~RUBY)
      assert !foo.bar(baz)
      ^^^^^^^^^^^^^^^^^^^^ Prefer `assert_not` over `assert !`.
    RUBY

    expect_correction(<<~RUBY)
      assert_not foo.bar(baz)
    RUBY
  end

  it 'autocorrects `assert !` with extra spaces' do
    expect_offense(<<~RUBY)
      assert   !  foo
      ^^^^^^^^^^^^^^^ Prefer `assert_not` over `assert !`.
    RUBY

    expect_correction(<<~RUBY)
      assert_not foo
    RUBY
  end

  it 'autocorrects `assert !` with parentheses' do
    expect_offense(<<~RUBY)
      assert(!foo)
      ^^^^^^^^^^^^ Prefer `assert_not` over `assert !`.
    RUBY

    expect_correction(<<~RUBY)
      assert_not(foo)
    RUBY
  end

  it 'does not register an offense when using `assert_not` ' do
    expect_no_offenses(<<~RUBY)
      assert_not foo
    RUBY
  end
end
