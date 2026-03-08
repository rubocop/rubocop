# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessConstantScoping, :config do
  it 'registers an offense when using constant after `private` access modifier' do
    expect_offense(<<~RUBY)
      class Foo
        private
        CONST = 42
        ^^^^^^^^^^ Useless `private` access modifier for constant scope.
      end
    RUBY
  end

  it 'does not register an offense when there are multiple preceding access modifiers if the most recent one is not `private`' do
    expect_no_offenses(<<~RUBY)
      class Foo
        private

        public

        CONST = 42
      end
    RUBY
  end

  it 'registers an offense when there are multiple preceding access modifiers and the most recent one is not `private` but has args to limit what it affects' do
    expect_offense(<<~RUBY)
      class Foo
        private

        public bar

        CONST = 42
        ^^^^^^^^^^ Useless `private` access modifier for constant scope.
      end
    RUBY
  end

  it 'does not register an offense when there are multiple preceding access modifiers and the most recent one is not `private` and has args to limit what it affects if the constant is declared a `private_constant` later' do
    expect_no_offenses(<<~RUBY)
      class Foo
        private

        public bar

        CONST = 42

        private_constant :CONST
      end
    RUBY
  end

  it 'registers an offense when a non-modifier method call exists between `private` and the constant' do
    expect_offense(<<~RUBY)
      class Foo
        private

        do_something

        CONST = 42
        ^^^^^^^^^^ Useless `private` access modifier for constant scope.
      end
    RUBY
  end

  it 'registers an offense when using constant not defined in `private_constant`' do
    expect_offense(<<~RUBY)
      class Foo
        private

        CONST = 42
        ^^^^^^^^^^ Useless `private` access modifier for constant scope.
        private_constant :X
      end
    RUBY
  end

  it 'does not crash an offense when using constant and `private_constant` with variable argument' do
    expect_offense(<<~RUBY)
      class Foo
        private

        CONST = 42
        ^^^^^^^^^^ Useless `private` access modifier for constant scope.

        private_constant var
      end
    RUBY
  end

  it 'registers an offense when multiple assigning to constants after `private` access modifier' do
    expect_offense(<<~RUBY)
      class Foo
        private
        FOO = BAR = 42
        ^^^^^^^^^^^^^^ Useless `private` access modifier for constant scope.
      end
    RUBY
  end

  it 'does not register an offense when using constant' do
    expect_no_offenses(<<~RUBY)
      class Foo
        CONST = 42
      end
    RUBY
  end

  it 'registers an offense when using constant after `private` access modifier in `class << self`' do
    expect_offense(<<~RUBY)
      class Foo
        class << self
          private
          CONST = 42
          ^^^^^^^^^^ Useless `private` access modifier for constant scope.
        end
      end
    RUBY
  end

  it 'does not register an offense when using constant after `private` access modifier in `class << self` with `private_constant`' do
    expect_no_offenses(<<~RUBY)
      class Foo
        class << self
          private
          CONST = 42
          private_constant :CONST
        end
      end
    RUBY
  end

  it 'does not register an offense when using constant defined in symbol argument of `private_constant`' do
    expect_no_offenses(<<~RUBY)
      class Foo
        private

        CONST = 42
        private_constant :CONST
      end
    RUBY
  end

  it 'does not register an offense when using constant defined in multiple symbol arguments of `private_constant`' do
    expect_no_offenses(<<~RUBY)
      class Foo
        private

        CONST = 42
        private_constant :CONST, :X
      end
    RUBY
  end

  it 'does not register an offense when using constant defined in string argument of `private_constant`' do
    expect_no_offenses(<<~RUBY)
      class Foo
        private

        CONST = 42
        private_constant 'CONST'
      end
    RUBY
  end

  it 'does not register an offense when using constant after `private` access modifier with arguments' do
    expect_no_offenses(<<~RUBY)
      class Foo
        private do_something

        CONST = 42
      end
    RUBY
  end
end
