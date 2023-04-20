# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Attr, :config do
  it 'registers an offense attr' do
    expect_offense(<<~RUBY)
      class SomeClass
        attr :name
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      end
    RUBY
  end

  it 'registers offense for attr within class_eval' do
    expect_offense(<<~RUBY)
      SomeClass.class_eval do
        attr :name
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      end
    RUBY
  end

  it 'registers offense for attr within module_eval' do
    expect_offense(<<~RUBY)
      SomeClass.module_eval do
        attr :name
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      end
    RUBY
  end

  it 'registers an offense when using `attr` and method definitions' do
    expect_offense(<<~RUBY)
      class SomeClass
        attr :name
        ^^^^ Do not use `attr`. Use `attr_reader` instead.

        def foo
        end
      end
    RUBY
  end

  it 'accepts attr when it does not take arguments' do
    expect_no_offenses('func(attr)')
  end

  it 'accepts attr when it has a receiver' do
    expect_no_offenses('x.attr arg')
  end

  it 'does not register offense for custom `attr` method' do
    expect_no_offenses(<<~RUBY)
      class SomeClass
        def attr(*args)
          p args
        end

        def a
          attr(1)
        end
      end
    RUBY
  end

  context 'autocorrects' do
    it 'attr to attr_reader' do
      expect_offense(<<~RUBY)
        attr :name
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      RUBY

      expect_correction(<<~RUBY)
        attr_reader :name
      RUBY
    end

    it 'attr, false to attr_reader' do
      expect_offense(<<~RUBY)
        attr :name, false
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      RUBY

      expect_correction(<<~RUBY)
        attr_reader :name
      RUBY
    end

    it 'attr :name, true to attr_accessor :name' do
      expect_offense(<<~RUBY)
        attr :name, true
        ^^^^ Do not use `attr`. Use `attr_accessor` instead.
      RUBY

      expect_correction(<<~RUBY)
        attr_accessor :name
      RUBY
    end

    it 'attr with multiple names to attr_reader' do
      expect_offense(<<~RUBY)
        attr :foo, :bar
        ^^^^ Do not use `attr`. Use `attr_reader` instead.
      RUBY

      expect_correction(<<~RUBY)
        attr_reader :foo, :bar
      RUBY
    end
  end
end
