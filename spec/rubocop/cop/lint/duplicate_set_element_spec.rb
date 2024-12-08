# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateSetElement, :config do
  %w[Set SortedSet].each do |class_name|
    it "registers an offense when using duplicate symbol element in `#{class_name}[...]`" do
      expect_offense(<<~RUBY, class_name: class_name)
        #{class_name}[:foo, :bar, :foo]
        _{class_name}             ^^^^ Remove the duplicate element in #{class_name}.
      RUBY

      expect_correction(<<~RUBY)
        #{class_name}[:foo, :bar]
      RUBY
    end

    it "registers an offense when using duplicate symbol element in `::#{class_name}[...]`" do
      expect_offense(<<~RUBY, class_name: class_name)
        ::#{class_name}[:foo, :bar, :foo]
          _{class_name}             ^^^^ Remove the duplicate element in #{class_name}.
      RUBY

      expect_correction(<<~RUBY)
        ::#{class_name}[:foo, :bar]
      RUBY
    end

    it 'registers an offense when using multiple duplicate symbol element' do
      expect_offense(<<~RUBY, class_name: class_name)
        #{class_name}[:foo, :bar, :foo, :baz, :baz]
        _{class_name}             ^^^^ Remove the duplicate element in #{class_name}.
        _{class_name}                         ^^^^ Remove the duplicate element in #{class_name}.
      RUBY

      expect_correction(<<~RUBY)
        #{class_name}[:foo, :bar, :baz]
      RUBY
    end

    it 'registers an offense when using duplicate lvar element' do
      expect_offense(<<~RUBY, class_name: class_name)
        foo = do_foo
        bar = do_bar

        #{class_name}[foo, bar, foo]
        _{class_name}           ^^^ Remove the duplicate element in #{class_name}.
      RUBY

      expect_correction(<<~RUBY)
        foo = do_foo
        bar = do_bar

        #{class_name}[foo, bar]
      RUBY
    end

    it 'registers an offense when using duplicate ivar element' do
      expect_offense(<<~RUBY, class_name: class_name)
        #{class_name}[@foo, @bar, @foo]
        _{class_name}             ^^^^ Remove the duplicate element in #{class_name}.
      RUBY

      expect_correction(<<~RUBY)
        #{class_name}[@foo, @bar]
      RUBY
    end

    it 'registers an offense when using duplicate constant element' do
      expect_offense(<<~RUBY, class_name: class_name)
        #{class_name}[Foo, Bar, Foo]
        _{class_name}           ^^^ Remove the duplicate element in #{class_name}.
      RUBY

      expect_correction(<<~RUBY)
        #{class_name}[Foo, Bar]
      RUBY
    end

    it 'does not register an offense when using duplicate method call element' do
      expect_no_offenses(<<~RUBY)
        #{class_name}[foo, bar, foo]
      RUBY
    end

    it 'does not register an offense when using duplicate safe navigation method call element' do
      expect_no_offenses(<<~RUBY)
        #{class_name}[obj&.foo, obj&.bar, obj&.foo]
      RUBY
    end

    it 'does not register an offense when using duplicate ternary operator element' do
      expect_no_offenses(<<~RUBY)
        #{class_name}[rand > 0.5 ? 1 : 2, rand > 0.5 ? 1 : 2]
      RUBY
    end

    it "registers an offense when using duplicate symbol element in `#{class_name}.new([...])`" do
      expect_offense(<<~RUBY, class_name: class_name)
        #{class_name}.new([:foo, :bar, :foo])
        _{class_name}                  ^^^^ Remove the duplicate element in #{class_name}.
      RUBY

      expect_correction(<<~RUBY)
        #{class_name}.new([:foo, :bar])
      RUBY
    end

    it "registers an offense when using duplicate symbol element in `#{class_name}.new(%i[...])`" do
      expect_offense(<<~RUBY, class_name: class_name)
        #{class_name}.new(%i[foo bar foo])
        _{class_name}                ^^^ Remove the duplicate element in #{class_name}.
      RUBY

      expect_correction(<<~RUBY)
        #{class_name}.new(%i[foo bar])
      RUBY
    end

    it "registers an offense when using duplicate symbol element in `::#{class_name}.new([...])`" do
      expect_offense(<<~RUBY, class_name: class_name)
        ::#{class_name}.new([:foo, :bar, :foo])
          _{class_name}                  ^^^^ Remove the duplicate element in #{class_name}.
      RUBY

      expect_correction(<<~RUBY)
        ::#{class_name}.new([:foo, :bar])
      RUBY
    end

    it "does not register an offense when not using duplicate method call element in `#{class_name}[...]`" do
      expect_no_offenses(<<~RUBY)
        #{class_name}[foo, bar]
      RUBY
    end

    it "does not register an offense when not using duplicate symbol element in `#{class_name}.new([...])`" do
      expect_no_offenses(<<~RUBY)
        #{class_name}.new([:foo, :bar])
      RUBY
    end

    it "does not register an offense when using empty element in `#{class_name}[]`" do
      expect_no_offenses(<<~RUBY)
        #{class_name}[]
      RUBY
    end

    it "does not register an offense when using one element in `#{class_name}[...]`" do
      expect_no_offenses(<<~RUBY)
        #{class_name}[:foo]
      RUBY
    end
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
