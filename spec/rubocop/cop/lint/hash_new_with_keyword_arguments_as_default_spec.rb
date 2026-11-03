# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::HashNewWithKeywordArgumentsAsDefault, :config do
  it 'registers an offense when using `Hash.new` with keyword arguments for default' do
    expect_offense(<<~RUBY)
      Hash.new(key: :value)
               ^^^^^^^^^^^ Use a hash literal instead of keyword arguments.
    RUBY

    expect_correction(<<~RUBY)
      Hash.new({key: :value})
    RUBY
  end

  it 'registers an offense when using `Hash.new` with keyword arguments including `capacity` for default' do
    # NOTE: This `capacity` is used as a hash element for the initial value.
    expect_offense(<<~RUBY)
      Hash.new(capacity: 42, key: :value)
               ^^^^^^^^^^^^^^^^^^^^^^^^^ Use a hash literal instead of keyword arguments.
    RUBY

    expect_correction(<<~RUBY)
      Hash.new({capacity: 42, key: :value})
    RUBY
  end

  it 'registers an offense when using `::Hash.new` with keyword arguments for default' do
    expect_offense(<<~RUBY)
      ::Hash.new(key: :value)
                 ^^^^^^^^^^^ Use a hash literal instead of keyword arguments.
    RUBY

    expect_correction(<<~RUBY)
      ::Hash.new({key: :value})
    RUBY
  end

  it 'registers an offense when using `Hash.new` with keyword arguments for default without parentheses' do
    expect_offense(<<~RUBY)
      Hash.new key: :value
               ^^^^^^^^^^^ Use a hash literal instead of keyword arguments.
    RUBY

    expect_correction(<<~RUBY)
      Hash.new({key: :value})
    RUBY
  end

  it 'registers an offense when using `::Hash.new` with keyword arguments for default without parentheses' do
    expect_offense(<<~RUBY)
      ::Hash.new key: :value
                 ^^^^^^^^^^^ Use a hash literal instead of keyword arguments.
    RUBY

    expect_correction(<<~RUBY)
      ::Hash.new({key: :value})
    RUBY
  end

  it 'registers an offense when using `Hash.new` with multiple keyword arguments for default without parentheses' do
    expect_offense(<<~RUBY)
      Hash.new foo: 1, bar: 2
               ^^^^^^^^^^^^^^ Use a hash literal instead of keyword arguments.
    RUBY

    expect_correction(<<~RUBY)
      Hash.new({foo: 1, bar: 2})
    RUBY
  end

  it 'registers an offense when using `Hash.new` with keyword arguments for default without parentheses and a block' do
    expect_offense(<<~RUBY)
      Hash.new key: :value do |hash, key|
               ^^^^^^^^^^^ Use a hash literal instead of keyword arguments.
        hash[key] = key
      end
    RUBY

    expect_correction(<<~RUBY)
      Hash.new({key: :value}) do |hash, key|
        hash[key] = key
      end
    RUBY
  end

  it 'registers an offense when using `Hash.new` with keyword arguments for default without parentheses as a receiver' do
    expect_offense(<<~RUBY)
      (Hash.new key: :value).do_something
                ^^^^^^^^^^^ Use a hash literal instead of keyword arguments.
    RUBY

    expect_correction(<<~RUBY)
      (Hash.new({key: :value})).do_something
    RUBY
  end

  it 'registers an offense when using `Hash.new` with keyword arguments for default without parentheses as an argument' do
    expect_offense(<<~RUBY)
      do_something Hash.new key: :value
                            ^^^^^^^^^^^ Use a hash literal instead of keyword arguments.
    RUBY

    expect_correction(<<~RUBY)
      do_something Hash.new({key: :value})
    RUBY
  end

  it 'registers an offense when using `Hash.new` with hash rocket argument for default' do
    expect_offense(<<~RUBY)
      Hash.new(:key => :value)
               ^^^^^^^^^^^^^^ Use a hash literal instead of keyword arguments.
    RUBY

    expect_correction(<<~RUBY)
      Hash.new({:key => :value})
    RUBY
  end

  it 'registers an offense when using `Hash.new` with key as method call and hash rocket argument for default' do
    expect_offense(<<~RUBY)
      Hash.new(key => 'value')
               ^^^^^^^^^^^^^^ Use a hash literal instead of keyword arguments.
    RUBY

    expect_correction(<<~RUBY)
      Hash.new({key => 'value'})
    RUBY
  end

  it 'does not register an offense when using `Hash.new` with hash for default' do
    expect_no_offenses(<<~RUBY)
      Hash.new({key: :value})
    RUBY
  end

  it 'does not register an offense when using `Hash.new` with `capacity` keyword' do
    # NOTE: `capacity` is correctly used as a keyword argument.
    expect_no_offenses(<<~RUBY)
      Hash.new(capacity: 42)
    RUBY
  end

  it 'does not register an offense when using `Hash.new` with no arguments' do
    expect_no_offenses(<<~RUBY)
      Hash.new
    RUBY
  end

  it 'does not register an offense when using `.new` for no `Hash` receiver' do
    expect_no_offenses(<<~RUBY)
      Foo.new(key: :value)
    RUBY
  end

  it 'does not register an offense when using `Hash.new` with non hash object for default' do
    expect_no_offenses(<<~RUBY)
      Hash.new(42)
    RUBY
  end
end
