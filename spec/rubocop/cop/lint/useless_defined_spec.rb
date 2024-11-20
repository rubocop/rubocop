# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessDefined, :config do
  it 'registers an offense when using `defined?` with a string argument' do
    expect_offense(<<~RUBY)
      defined?("FooBar")
      ^^^^^^^^^^^^^^^^^^ Calling `defined?` with a string argument will always return a truthy value.
    RUBY
  end

  it 'registers an offense when using `defined?` with interpolation' do
    expect_offense(<<~'RUBY')
      defined?("Foo#{bar}")
      ^^^^^^^^^^^^^^^^^^^^^ Calling `defined?` with a string argument will always return a truthy value.
    RUBY
  end

  it 'registers an offense when using `defined?` with a symbol' do
    expect_offense(<<~RUBY)
      defined?(:FooBar)
      ^^^^^^^^^^^^^^^^^ Calling `defined?` with a symbol argument will always return a truthy value.
    RUBY
  end

  it 'registers an offense when using `defined?` an interpolated symbol' do
    expect_offense(<<~'RUBY')
      defined?(:"Foo#{bar}")
      ^^^^^^^^^^^^^^^^^^^^^^ Calling `defined?` with a symbol argument will always return a truthy value.
    RUBY
  end

  it 'does not register an offense when using `defined?` with a constant' do
    expect_no_offenses(<<~RUBY)
      defined?(FooBar)
    RUBY
  end

  it 'does not register an offense when using `defined?` with a method' do
    expect_no_offenses(<<~RUBY)
      defined?(foo_bar)
    RUBY
  end

  it 'does not register an offense when calling a method on a symbol' do
    expect_no_offenses(<<~RUBY)
      defined?(:foo.to_proc)
    RUBY
  end
end
