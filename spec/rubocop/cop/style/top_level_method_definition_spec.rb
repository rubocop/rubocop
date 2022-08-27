# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TopLevelMethodDefinition, :config do
  it 'registers an offense top-level methods' do
    expect_offense(<<~RUBY)
      def foo; end
      ^^^^^^^^^^^^ Do not define methods at the top-level.
    RUBY
  end

  it 'registers an offense top-level class methods' do
    expect_offense(<<~RUBY)
      def self.foo; end
      ^^^^^^^^^^^^^^^^^ Do not define methods at the top-level.
    RUBY
  end

  context 'top-level define_method' do
    it 'registers offense with inline block' do
      expect_offense(<<~RUBY)
        define_method(:foo) { puts 1 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not define methods at the top-level.
      RUBY
    end

    context 'Ruby >= 2.7', :ruby27 do
      it 'registers offense with inline numblock' do
        expect_offense(<<~RUBY)
          define_method(:foo) { puts _1 }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not define methods at the top-level.
        RUBY
      end
    end

    it 'registers offense for multi-line block' do
      expect_offense(<<~RUBY)
        define_method(:foo) do |x|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not define methods at the top-level.
          puts 1
        end
      RUBY
    end

    it 'registers offense for proc argument' do
      expect_offense(<<~RUBY)
        define_method(:foo, instance_method(:bar))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not define methods at the top-level.
      RUBY
    end
  end

  it 'registers an offense when defining a top-level method after a class definition' do
    expect_offense(<<~RUBY)
      class Foo
      end

      def foo; end
      ^^^^^^^^^^^^ Do not define methods at the top-level.
    RUBY
  end

  it 'does not register an offense when using module' do
    expect_no_offenses(<<~RUBY)
      module Foo
        def foo; end
      end
    RUBY
  end

  it 'does not register an offense when using class' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.foo; end
      end
    RUBY
  end

  it 'does not register an offense when using Struct' do
    expect_no_offenses(<<~RUBY)
      Foo = Struct.new do
        def foo; end
      end
    RUBY
  end

  it 'does not register an offense when defined within arbitrary block' do
    expect_no_offenses(<<~RUBY)
      Foo = types.each do |type|
        def foo(type)
          puts type
        end
      end
    RUBY
  end

  it 'does not register an offense when define_method is not top-level' do
    expect_no_offenses(<<~RUBY)
      class Foo
        define_method(:a) { puts 1 }

        define_method(:b) do |x|
          puts x
        end

        define_method(:c, instance_method(:d))
      end
    RUBY
  end

  it 'does not register an offense when just called method on top-level' do
    expect_no_offenses(<<~RUBY)
      require_relative 'foo'
    RUBY
  end
end
