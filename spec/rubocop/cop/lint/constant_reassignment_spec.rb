# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ConstantReassignment, :config do
  it 'registers an offense when reassigning a constant on top-level namespace' do
    expect_offense(<<~RUBY)
      FOO = :bar
      FOO = :baz
      ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a constant on top-level namespace referencing self' do
    expect_offense(<<~RUBY)
      self::FOO = :bar
      self::FOO = :baz
      ^^^^^^^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a constant in a class' do
    expect_offense(<<~RUBY)
      class A
        FOO = :bar
        FOO = :baz
        ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
      end
    RUBY
  end

  it 'registers an offense when reassigning a constant in a class referencing self' do
    expect_offense(<<~RUBY)
      class A
        self::FOO = :bar
        self::FOO = :baz
        ^^^^^^^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
      end
    RUBY
  end

  it 'registers an offense when reassigning a constant in a module' do
    expect_offense(<<~RUBY)
      module A
        FOO = :bar
        FOO = :baz
        ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
      end
    RUBY
  end

  it 'registers an offense when reassigning a constant in a module referencing self' do
    expect_offense(<<~RUBY)
      module A
        self::FOO = :bar
        self::FOO = :baz
        ^^^^^^^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
      end
    RUBY
  end

  it 'registers an offense when reassigning a constant by referencing a relative namespace' do
    expect_offense(<<~RUBY)
      class A
        FOO = :bar
      end

      A::FOO = :baz
      ^^^^^^^^^^^^^ Constant `A::FOO` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a constant by referencing an absolute namespace' do
    expect_offense(<<~RUBY)
      class A
        FOO = :bar
      end

      ::A::FOO = :baz
      ^^^^^^^^^^^^^^^ Constant `A::FOO` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a constant by referencing a nested relative namespace' do
    expect_offense(<<~RUBY)
      module A
        class B
          FOO = :bar
        end
      end

      A::B::FOO = :baz
      ^^^^^^^^^^^^^^^^ Constant `A::B::FOO` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a constant by referencing a nested absolute namespace' do
    expect_offense(<<~RUBY)
      module A
        class B
          FOO = :bar
        end
      end

      ::A::B::FOO = :baz
      ^^^^^^^^^^^^^^^^^^ Constant `A::B::FOO` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a top-level constant assigned under a different namespace' do
    expect_offense(<<~RUBY)
      class A
        ::FOO = :bar
      end

      FOO = :baz
      ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a class constant from a module' do
    expect_offense(<<~RUBY)
      module A
        class B
          FOO = :bar
        end

        B::FOO = :baz
        ^^^^^^^^^^^^^ Constant `B::FOO` is already assigned in this namespace.
      end
    RUBY
  end

  it 'registers an offense when reassigning a constant in a reopened class' do
    expect_offense(<<~RUBY)
      module A
        class B
          FOO = :bar
        end

        class B
          FOO = :baz
          ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
        end
      end
    RUBY
  end

  it 'registers an offense when reassigning a constant within another constant' do
    expect_offense(<<~RUBY)
      class A
        ALL = [
          FOO = :a,
          BAR = :b,
          BAZ = :c,
          FOO = :d,
          ^^^^^^^^ Constant `FOO` is already assigned in this namespace.
        ]
      end
    RUBY
  end

  it 'registers an offense when reassigning a constant within another constant with freeze' do
    expect_offense(<<~RUBY)
      class A
        ALL = [
          FOO = :a,
          BAR = :b,
          BAZ = :c,
          FOO = :d,
          ^^^^^^^^ Constant `FOO` is already assigned in this namespace.
        ].freeze
      end
    RUBY
  end

  it 'registers an offense when reassigning a constant within a conditionally defined class' do
    expect_offense(<<~RUBY)
      class A
        FOO = :bar
        FOO = :baz
        ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
      end unless defined?(A)
    RUBY
  end

  it 'does not register an offense when using OR assignment' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar
      FOO ||= :baz
    RUBY
  end

  it 'does not register an offense when assigning a constant with the same name in a different class' do
    expect_no_offenses(<<~RUBY)
      class A
        FOO = :bar
      end

      class B
        FOO = :baz
      end
    RUBY
  end

  it 'does not register an offense when assigning a constant with the same name in a different module' do
    expect_no_offenses(<<~RUBY)
      module A
        FOO = :bar
      end

      module B
        FOO = :baz
      end
    RUBY
  end

  it 'does not register an offense when assigning a constant with the same name in a class with the same name in a different namespace' do
    expect_no_offenses(<<~RUBY)
      module A
        class C
          FOO = :bar
        end
      end

      module B
        class C
          FOO = :baz
        end
      end
    RUBY
  end

  it 'does not register an offense when assigning a constant with the same name on top-level and class namespace' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar

      class A
        FOO = :baz
      end
    RUBY
  end

  it 'does not register an offense when assigning a constant with the same name on top-level and class namespace referencing self' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar

      class A
        self::FOO = :baz
      end
    RUBY
  end

  it 'does not register an offense when assigning a constant with the same name on top-level and module namespace' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar

      module A
        FOO = :baz
      end
    RUBY
  end

  it 'does not register an offense when assigning a constant in a namespace with the same name but on top-level' do
    expect_no_offenses(<<~RUBY)
      module A
        FOO = :bar
        ::FOO = :baz
      end
    RUBY
  end

  it 'does not register an offense when assigning a constant with the same name and namespace name but on top-level' do
    expect_no_offenses(<<~RUBY)
      module A
        module B
          FOO = :bar
        end

        ::B::FOO = :baz
      end
    RUBY
  end

  it 'does not register an offense when assigning a constant with the same name as top-level constant after remove_const with symbol argument' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar

      class A
        FOO = :baz

        remove_const :FOO

        FOO = :quux
      end
    RUBY
  end

  it 'does not register an offense when assigning a constant with the same name as top-level constant after remove_const with string argument' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar

      class A
        FOO = :baz

        remove_const 'FOO'

        FOO = :quux
      end
    RUBY
  end

  it 'does not raise an error when using remove_const with variable argument' do
    expect do
      expect_no_offenses(<<~RUBY)
        class A
          FOO = :bar

          constant = :FOO
          remove_const constant
        end
      RUBY
    end.not_to raise_error
  end

  it 'does not register an offense when assigning a constant with the same name as top-level constant after self.remove_const' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar

      class A
        FOO = :baz

        self.remove_const :FOO

        FOO = :quux
      end
    RUBY
  end

  it 'does not register an offense when reassigning a constant inside a block' do
    expect_no_offenses(<<~RUBY)
      class A
        FOO = :bar

        silence_warnings do
          FOO = :baz
        end
      end
    RUBY
  end

  it 'does not register an offense when reassigning a constant inside a block with multiple statements' do
    expect_no_offenses(<<~RUBY)
      class A
        FOO = :bar

        silence_warnings do
          FOO = :baz
          BAR = :quux
        end
      end
    RUBY
  end

  it 'does not register an offense for simple constant assignment' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar
    RUBY
  end

  it 'does not register an offense for constant assignment with a condition' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar
      FOO = :baz unless something
    RUBY
  end

  it 'does not register an offense for constant assignment within an if...else block' do
    expect_no_offenses(<<~RUBY)
      if something
        FOO = :bar
      else
        FOO = :baz
      end
    RUBY
  end

  it 'does not register an offense for constant assignment within an if...else block with multiple statements' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar

      if something
        FOO = :baz
        FOO = :quux
      else
        FOO = :baz
      end
    RUBY
  end

  it 'does not register an offense for constant assignment within an if...else block with multiple statements inside a class' do
    expect_no_offenses(<<~RUBY)
      class Foo
        FOO = :bar

        if something
          FOO = :baz
          FOO = :quux
        end
      end
    RUBY
  end

  it 'does not register an offense for constant assignment within an if statement inside a class' do
    expect_no_offenses(<<~RUBY)
      class Foo
        if something
          FOO = :bar
        end
      end
    RUBY
  end

  it 'does not register an offense when reassigning a constant in a Class.new block' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar

      Class.new do
        FOO = :baz
      end
    RUBY
  end

  it 'does not register an offense when assigning a constant in a begin...rescue block' do
    expect_no_offenses(<<~RUBY)
      begin
        FOO = File.read(filename)
      rescue
        FOO = nil
      end
    RUBY
  end

  it 'does not register an offense when constant is reasigned with a variable path' do
    expect_no_offenses(<<~RUBY)
      lvar::FOO = 1
      lvar::FOO = 2
    RUBY
  end

  it 'does not register an offense when a nested constant is reassigned with a variable path' do
    expect_no_offenses(<<~RUBY)
      lvar::FOO::BAR = 1
      lvar::FOO::BAR = 2
    RUBY
  end

  it 'registers an offense when reassigning a constant after class keyword definition' do
    expect_offense(<<~RUBY)
      class FooError < StandardError; end
      FooError = Class.new(RuntimeError)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Constant `FooError` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a constant after class keyword definition in a module' do
    expect_offense(<<~RUBY)
      module A
        class FooError < StandardError; end
        FooError = Class.new(RuntimeError)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Constant `FooError` is already assigned in this namespace.
      end
    RUBY
  end

  it 'registers an offense when reassigning a constant after class keyword definition with compact namespace' do
    expect_offense(<<~RUBY)
      class A::FooError < StandardError; end
      A::FooError = Class.new(RuntimeError)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Constant `A::FooError` is already assigned in this namespace.
    RUBY
  end

  it 'does not register an offense when class keyword reopens after constant assignment' do
    expect_no_offenses(<<~RUBY)
      FooError = Class.new(StandardError)
      class FooError < StandardError; end
    RUBY
  end

  it 'does not register an offense for class keyword definition inside a conditional' do
    expect_no_offenses(<<~RUBY)
      if condition
        class FooError < StandardError; end
      end
      FooError = Class.new(StandardError)
    RUBY
  end

  it 'does not register an offense for class keyword and constant in different namespaces' do
    expect_no_offenses(<<~RUBY)
      module A
        class FooError < StandardError; end
      end
      module B
        FooError = Class.new(StandardError)
      end
    RUBY
  end

  it 'registers an offense when reassigning after class with absolute namespace' do
    expect_offense(<<~RUBY)
      class ::A::FooError < StandardError; end
      A::FooError = Class.new(RuntimeError)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Constant `A::FooError` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning after class keyword definition inside a class' do
    expect_offense(<<~RUBY)
      class Parent
        class FooError < StandardError; end
        FooError = Class.new(RuntimeError)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Constant `FooError` is already assigned in this namespace.
      end
    RUBY
  end

  it 'registers an offense when reassigning a constant after module keyword definition' do
    expect_offense(<<~RUBY)
      module M; end
      M = 1
      ^^^^^ Constant `M` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a constant after module keyword definition in a class' do
    expect_offense(<<~RUBY)
      class A
        module M; end
        M = 1
        ^^^^^ Constant `M` is already assigned in this namespace.
      end
    RUBY
  end

  it 'registers an offense when reassigning after remove_const on a different object' do
    expect_offense(<<~RUBY)
      class A
        FOO = :bar
        Other.remove_const :FOO
        FOO = :baz
        ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
      end
    RUBY
  end

  it 'does not register an offense when constant is removed via implicit self' do
    expect_no_offenses(<<~RUBY)
      class A
        FOO = :bar
        remove_const :FOO
        FOO = :baz
      end
    RUBY
  end

  it 'does not register an offense for module keyword and constant in different namespaces' do
    expect_no_offenses(<<~RUBY)
      module A
        module M; end
      end
      module B
        M = 1
      end
    RUBY
  end

  it 'does not register an offense when module keyword reopens after constant assignment' do
    expect_no_offenses(<<~RUBY)
      M = Module.new
      module M; end
    RUBY
  end

  it 'registers an offense when reassigning a constant via multiple assignment' do
    expect_offense(<<~RUBY)
      FOO = 1
      FOO, BAR = 2, 3
      ^^^ Constant `FOO` is already assigned in this namespace.
    RUBY
  end

  it 'does not register an offense for module definition inside a conditional' do
    expect_no_offenses(<<~RUBY)
      if condition
        module M; end
      end
      M = 1
    RUBY
  end
end
