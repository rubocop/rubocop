# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateSetElement, :config do
  it 'registers an offense when using duplicate symbol element in `Set[...]`' do
    expect_offense(<<~RUBY)
      Set[:foo, :bar, :foo]
                      ^^^^ Remove the duplicate element in Set.
    RUBY

    expect_correction(<<~RUBY)
      Set[:foo, :bar]
    RUBY
  end

  it 'registers an offense when using duplicate symbol element in `::Set[...]`' do
    expect_offense(<<~RUBY)
      ::Set[:foo, :bar, :foo]
                        ^^^^ Remove the duplicate element in Set.
    RUBY

    expect_correction(<<~RUBY)
      ::Set[:foo, :bar]
    RUBY
  end

  it 'registers an offense when using multiple duplicate symbol element' do
    expect_offense(<<~RUBY)
      Set[:foo, :bar, :foo, :baz, :baz]
                      ^^^^ Remove the duplicate element in Set.
                                  ^^^^ Remove the duplicate element in Set.
    RUBY

    expect_correction(<<~RUBY)
      Set[:foo, :bar, :baz]
    RUBY
  end

  it 'registers an offense when using duplicate lvar element' do
    expect_offense(<<~RUBY)
      foo = do_foo
      bar = do_bar

      Set[foo, bar, foo]
                    ^^^ Remove the duplicate element in Set.
    RUBY

    expect_correction(<<~RUBY)
      foo = do_foo
      bar = do_bar

      Set[foo, bar]
    RUBY
  end

  it 'registers an offense when using duplicate ivar element' do
    expect_offense(<<~RUBY)
      Set[@foo, @bar, @foo]
                      ^^^^ Remove the duplicate element in Set.
    RUBY

    expect_correction(<<~RUBY)
      Set[@foo, @bar]
    RUBY
  end

  it 'registers an offense when using duplicate constant element' do
    expect_offense(<<~RUBY)
      Set[Foo, Bar, Foo]
                    ^^^ Remove the duplicate element in Set.
    RUBY

    expect_correction(<<~RUBY)
      Set[Foo, Bar]
    RUBY
  end

  it 'does not register an offense when using duplicate method call element' do
    expect_no_offenses(<<~RUBY)
      Set[foo, bar, foo]
    RUBY
  end

  it 'does not register an offense when using duplicate safe navigation method call element' do
    expect_no_offenses(<<~RUBY)
      Set[obj&.foo, obj&.bar, obj&.foo]
    RUBY
  end

  it 'does not register an offense when using duplicate ternary operator element' do
    expect_no_offenses(<<~RUBY)
      Set[rand > 0.5 ? 1 : 2, rand > 0.5 ? 1 : 2]
    RUBY
  end

  it 'registers an offense when using duplicate symbol element in `Set.new([...])`' do
    expect_offense(<<~RUBY)
      Set.new([:foo, :bar, :foo])
                           ^^^^ Remove the duplicate element in Set.
    RUBY

    expect_correction(<<~RUBY)
      Set.new([:foo, :bar])
    RUBY
  end

  it 'registers an offense when using duplicate symbol element in `Set.new(%i[...])`' do
    expect_offense(<<~RUBY)
      Set.new(%i[foo bar foo])
                         ^^^ Remove the duplicate element in Set.
    RUBY

    expect_correction(<<~RUBY)
      Set.new(%i[foo bar])
    RUBY
  end

  it 'registers an offense when using duplicate symbol element in `::Set.new([...])`' do
    expect_offense(<<~RUBY)
      ::Set.new([:foo, :bar, :foo])
                             ^^^^ Remove the duplicate element in Set.
    RUBY

    expect_correction(<<~RUBY)
      ::Set.new([:foo, :bar])
    RUBY
  end

  it 'does not register an offense when not using duplicate method call element in `Set[...]`' do
    expect_no_offenses(<<~RUBY)
      Set[foo, bar]
    RUBY
  end

  it 'does not register an offense when not using duplicate symbol element in `Set.new([...])`' do
    expect_no_offenses(<<~RUBY)
      Set.new([:foo, :bar])
    RUBY
  end

  it 'registers an offense when using duplicate symbol element in `[...].to_set`' do
    expect_offense(<<~RUBY)
      [:foo, :bar, :foo].to_set
                   ^^^^ Remove the duplicate element in Set.
    RUBY

    expect_correction(<<~RUBY)
      [:foo, :bar].to_set
    RUBY
  end

  it 'registers an offense when using duplicate symbol element in `[...]&.to_set`' do
    expect_offense(<<~RUBY)
      [:foo, :bar, :foo]&.to_set
                   ^^^^ Remove the duplicate element in Set.
    RUBY

    expect_correction(<<~RUBY)
      [:foo, :bar]&.to_set
    RUBY
  end

  it 'does not register an offense when using empty element in `Set[]`' do
    expect_no_offenses(<<~RUBY)
      Set[]
    RUBY
  end

  it 'does not register an offense when using one element in `Set[...]`' do
    expect_no_offenses(<<~RUBY)
      Set[:foo]
    RUBY
  end

  it 'does not register an offense when using duplicate symbol element in `Array[...]`' do
    expect_no_offenses(<<~RUBY)
      Array[:foo, :bar, :foo]
    RUBY
  end

  it 'does not register an offense when using duplicate symbol element in `Array.new([...])`' do
    expect_no_offenses(<<~RUBY)
      Array.new([:foo, :bar, :foo])
    RUBY
  end
end
