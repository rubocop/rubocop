# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::IdentityComparison, :config do
  it 'registers an offense and corrects when using `==` for comparison between `object_id`s' do
    expect_offense(<<~RUBY)
      foo.object_id == bar.object_id
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `equal?` instead `==` when comparing `object_id`.
    RUBY

    expect_correction(<<~RUBY)
      foo.equal?(bar)
    RUBY
  end

  it 'does not register an offense when using `==` for comparison between `object_id` and other' do
    expect_no_offenses(<<~RUBY)
      foo.object_id == bar.do_something
    RUBY
  end

  it 'does not register an offense when a receiver that is not `object_id` uses `==`' do
    expect_no_offenses(<<~RUBY)
      foo.do_something == bar.object_id
    RUBY
  end

  it 'does not register an offense when using `==`' do
    expect_no_offenses(<<~RUBY)
      foo.equal(bar)
    RUBY
  end

  it 'does not register an offense when lhs is `object_id` without receiver' do
    expect_no_offenses(<<~RUBY)
      object_id == bar.object_id
    RUBY
  end

  it 'does not register an offense when rhs is `object_id` without receiver' do
    expect_no_offenses(<<~RUBY)
      foo.object_id == object_id
    RUBY
  end
end
