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

  it 'registers an offense when using double splat hash braces with `merge` method call' do
    expect_offense(<<~RUBY)
      do_something(**{foo: bar, baz: qux}.merge(options))
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant double splat and braces, use keyword arguments directly.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo: bar, baz: qux, **options)
    RUBY
  end

  it 'registers an offense when using double splat hash braces with `merge!` method call' do
    expect_offense(<<~RUBY)
      do_something(**{foo: bar, baz: qux}.merge!(options))
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant double splat and braces, use keyword arguments directly.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo: bar, baz: qux, **options)
    RUBY
  end

  it 'registers an offense when using double splat hash braces with `merge` pair arguments method call' do
    expect_offense(<<~RUBY)
      do_something(**{foo: bar, baz: qux}.merge(x: y))
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant double splat and braces, use keyword arguments directly.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo: bar, baz: qux, x: y)
    RUBY
  end

  it 'registers an offense when using double splat hash braces with `merge` safe navigation method call' do
    expect_offense(<<~RUBY)
      do_something(**{foo: bar, baz: qux}&.merge(options))
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant double splat and braces, use keyword arguments directly.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo: bar, baz: qux, **options)
    RUBY
  end

  it 'registers an offense when using double splat hash braces with `merge` multiple arguments method call' do
    expect_offense(<<~RUBY)
      do_something(**{foo: bar, baz: qux}.merge(options1, options2))
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant double splat and braces, use keyword arguments directly.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo: bar, baz: qux, **options1, **options2)
    RUBY
  end

  it 'registers an offense when using double splat hash braces with `merge` method chain' do
    expect_offense(<<~RUBY)
      do_something(**{foo: bar, baz: qux}.merge(options1, options2).merge(options3))
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant double splat and braces, use keyword arguments directly.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo: bar, baz: qux, **options1, **options2, **options3)
    RUBY
  end

  it 'registers an offense when using double splat hash braces with complex `merge` method chain' do
    expect_offense(<<~RUBY)
      do_something(**{foo: bar, baz: qux}.merge(options1, options2)&.merge!(options3))
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant double splat and braces, use keyword arguments directly.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo: bar, baz: qux, **options1, **options2, **options3)
    RUBY
  end

  it 'does not register an offense when using keyword arguments' do
    expect_no_offenses(<<~RUBY)
      do_something(foo: bar, baz: qux)
    RUBY
  end

  it 'does not register an offense when using no hash brace' do
    expect_no_offenses(<<~RUBY)
      do_something(**options.merge(foo: bar, baz: qux))
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

  it 'does not register an offense when using method call that is not `merge` for double splat hash braces arguments' do
    expect_no_offenses(<<~RUBY)
      do_something(**{foo: bar}.invert)
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
