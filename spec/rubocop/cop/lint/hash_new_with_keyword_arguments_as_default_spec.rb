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
