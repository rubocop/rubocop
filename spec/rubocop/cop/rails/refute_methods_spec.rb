# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RefuteMethods do
  subject(:cop) { described_class.new }

  it 'registers an offense and correct using `refute` with a single argument' do
    expect_offense(<<-RUBY.strip_indent)
      refute foo
      ^^^^^^ Prefer `assert_not` over `refute`.
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      assert_not foo
    RUBY
  end

  it 'registers an offense and corrects using `refute` ' \
    'with multiple arguments' do
    expect_offense(<<-RUBY.strip_indent)
      refute foo, bar, baz
      ^^^^^^ Prefer `assert_not` over `refute`.
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      assert_not foo, bar, baz
    RUBY
  end

  it 'registers an offense when using `refute_empty`' do
    expect_offense(<<-RUBY.strip_indent)
      refute_empty foo
      ^^^^^^^^^^^^ Prefer `assert_not_empty` over `refute_empty`.
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      assert_not_empty foo
    RUBY
  end

  it 'does not registers an offense when using `assert_not` ' \
     'with a single argument' do
    expect_no_offenses(<<-RUBY.strip_indent)
      assert_not foo
    RUBY
  end

  it 'does not registers an offense when using `assert_not` ' \
     'with a multiple arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      assert_not foo, bar, baz
    RUBY
  end
end
