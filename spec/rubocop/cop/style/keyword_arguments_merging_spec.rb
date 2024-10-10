# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::KeywordArgumentsMerging, :config do
  it 'registers an offense and corrects when using `merge` with keyword arguments' do
    expect_offense(<<~RUBY)
      foo(x, **options.merge(y: 1))
               ^^^^^^^^^^^^^^^^^^^ Add additional arguments directly rather than using `merge`.
    RUBY

    expect_correction(<<~RUBY)
      foo(x, **options, y: 1)
    RUBY
  end

  it 'registers an offense and corrects when using `merge` with non-keyword arguments' do
    expect_offense(<<~RUBY)
      foo(x, **options.merge(other_options))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add additional arguments directly rather than using `merge`.
    RUBY

    expect_correction(<<~RUBY)
      foo(x, **options, **other_options)
    RUBY
  end

  it 'registers an offense and corrects when using `merge` with keyword and non-keyword arguments' do
    expect_offense(<<~RUBY)
      foo(x, **options.merge(y: 1, **other_options, z: 2))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add additional arguments directly rather than using `merge`.
    RUBY

    expect_correction(<<~RUBY)
      foo(x, **options, y: 1, **other_options, z: 2)
    RUBY
  end

  it 'registers an offense and corrects when using `merge` with hash with braces' do
    expect_offense(<<~RUBY)
      foo(x, **options.merge({ y: 1 }))
               ^^^^^^^^^^^^^^^^^^^^^^^ Add additional arguments directly rather than using `merge`.
    RUBY

    expect_correction(<<~RUBY)
      foo(x, **options,  y: 1 )
    RUBY
  end

  it 'registers an offense and corrects when using `merge` with multiple arguments' do
    expect_offense(<<~RUBY)
      foo(x, **options.merge(y: 1, **other_options))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add additional arguments directly rather than using `merge`.
    RUBY

    expect_correction(<<~RUBY)
      foo(x, **options, y: 1, **other_options)
    RUBY
  end

  it 'registers an offense and corrects when using a chain of `merge`s' do
    expect_offense(<<~RUBY)
      foo(x, **options.merge(other_options).merge(more_options))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add additional arguments directly rather than using `merge`.
    RUBY

    expect_correction(<<~RUBY)
      foo(x, **options, **other_options, **more_options)
    RUBY
  end

  it 'does not register an offense when not using `merge`' do
    expect_no_offenses(<<~RUBY)
      foo(x, **options)
    RUBY
  end

  it 'does not register an offense when using `merge!`' do
    expect_no_offenses(<<~RUBY)
      foo(x, **options.merge!(other_options))
    RUBY
  end
end
