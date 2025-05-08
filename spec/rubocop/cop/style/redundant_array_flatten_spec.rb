# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantArrayFlatten, :config do
  it 'registers an offense for `x.flatten.join`' do
    expect_offense(<<~RUBY)
      x.flatten.join
       ^^^^^^^^ Remove the redundant `flatten`.
    RUBY

    expect_correction(<<~RUBY)
      x.join
    RUBY
  end

  it 'registers an offense for `x.flatten.join(separator)`' do
    expect_offense(<<~RUBY)
      x.flatten.join(separator)
       ^^^^^^^^ Remove the redundant `flatten`.
    RUBY

    expect_correction(<<~RUBY)
      x.join(separator)
    RUBY
  end

  it 'registers an offense for `x.flatten(depth).join`' do
    expect_offense(<<~RUBY)
      x.flatten(depth).join
       ^^^^^^^^^^^^^^^ Remove the redundant `flatten`.
    RUBY

    expect_correction(<<~RUBY)
      x.join
    RUBY
  end

  it 'registers an offense for `x&.flatten&.join`' do
    expect_offense(<<~RUBY)
      x&.flatten&.join
       ^^^^^^^^^ Remove the redundant `flatten`.
    RUBY

    expect_correction(<<~RUBY)
      x&.join
    RUBY
  end

  it 'does not register an offense for `x.flatten.foo`' do
    expect_no_offenses(<<~RUBY)
      x.flatten.foo
    RUBY
  end

  it 'does not register an offense for `x.flatten`' do
    expect_no_offenses(<<~RUBY)
      x.flatten
    RUBY
  end

  it 'does not register an offense for `flatten.join` without an explicit receiver' do
    expect_no_offenses(<<~RUBY)
      flatten.join
    RUBY
  end

  it 'does not register an offense for `x.flatten(depth, extra_arg).join`' do
    expect_no_offenses(<<~RUBY)
      x.flatten(depth, extra_arg).join
    RUBY
  end

  it 'does not register an offense for `x.flatten.join(separator, extra_arg)`' do
    expect_no_offenses(<<~RUBY)
      x.flatten.join(separator, extra_arg)
    RUBY
  end
end
