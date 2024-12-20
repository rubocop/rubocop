# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ConstantReassignment, :config do
  it 'registers an offense when reassigning a constant on top-level namespace' do
    expect_offense(<<~RUBY)
      FOO = :bar
      FOO = :baz
      ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a constant on top-level namespace within a block' do
    expect_offense(<<~RUBY)
      FOO = :bar

      begin
        FOO = :baz
        ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
      end
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

  it 'registers an offense when reassigning a constant in a module' do
    expect_offense(<<~RUBY)
      module A
        FOO = :bar
        FOO = :baz
        ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
      end
    RUBY
  end

  it 'registers an offense when reassigning a constant by referencing a relative namespace' do
    expect_offense(<<~RUBY)
      class A
        FOO = :bar
      end

      A::FOO = :baz
      ^^^^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a constant by referencing an absolute namespace' do
    expect_offense(<<~RUBY)
      class A
        FOO = :bar
      end

      ::A::FOO = :baz
      ^^^^^^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
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
      ^^^^^^^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
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
      ^^^^^^^^^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
    RUBY
  end

  it 'registers an offense when reassigning a constant in a Class.new block' do
    expect_offense(<<~RUBY)
      FOO = :bar

      Class.new do
        FOO = :baz
        ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
      end
    RUBY
  end

  it 'registers an offense when assigning a constant in two Class.new blocks' do
    expect_offense(<<~RUBY)
      Class.new do
        FOO = :bar
      end

      Class.new do
        FOO = :baz
        ^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
      end
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
        ^^^^^^^^^^^^^ Constant `FOO` is already assigned in this namespace.
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

  it 'does not register an offense when assigning a constant with the same name as top-level constant after remove_const' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar

      class A
        FOO = :baz

        remove_const :FOO

        FOO = :quux
      end
    RUBY
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

  it 'does not register an offense for simple constant assignment' do
    expect_no_offenses(<<~RUBY)
      FOO = :bar
    RUBY
  end
end
