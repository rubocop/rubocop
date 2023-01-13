# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantDoubleSplatHashBraces, :config do
  it 'registers an offense when using double splat hash braces' do
    expect_offense(<<~RUBY)
      do_something(**{foo: bar, baz: qux})
                   ^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant double splat and braces, use keyword arguments directly.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo: bar, baz: qux)
    RUBY
  end

  it 'registers an offense when using nested double splat hash braces' do
    expect_offense(<<~RUBY)
      do_something(**{foo: bar, **{baz: qux}})
                                ^^^^^^^^^^^^ Remove the redundant double splat and braces, use keyword arguments directly.
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant double splat and braces, use keyword arguments directly.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo: bar, baz: qux)
    RUBY
  end

  it 'registers an offense when using double splat in double splat hash braces' do
    expect_offense(<<~RUBY)
      do_something(**{foo: bar, **options})
                   ^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant double splat and braces, use keyword arguments directly.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo: bar, **options)
    RUBY
  end

  it 'does not register an offense when using keyword arguments' do
    expect_no_offenses(<<~RUBY)
      do_something(foo: bar, baz: qux)
    RUBY
  end

  it 'does not register an offense when using empty double splat hash braces arguments' do
    expect_no_offenses(<<~RUBY)
      do_something(**{})
    RUBY
  end

  it 'does not register an offense when using empty hash braces arguments' do
    expect_no_offenses(<<~RUBY)
      do_something({})
    RUBY
  end

  it 'does not register an offense when using hash rocket double splat hash braces arguments' do
    expect_no_offenses(<<~RUBY)
      do_something(**{foo => bar})
    RUBY
  end

  it 'does not register an offense when using method call for double splat hash braces arguments' do
    expect_no_offenses(<<~RUBY)
      do_something(**{foo: bar}.merge(options))
    RUBY
  end

  it 'does not register an offense when using hash braces arguments' do
    expect_no_offenses(<<~RUBY)
      do_something({foo: bar, baz: qux})
    RUBY
  end

  it 'does not register an offense when using double splat variable' do
    expect_no_offenses(<<~RUBY)
      do_something(**h)
    RUBY
  end

  it 'does not register an offense when using hash literal' do
    expect_no_offenses(<<~RUBY)
      { a: a }
    RUBY
  end
end
