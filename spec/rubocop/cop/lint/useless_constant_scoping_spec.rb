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

  it 'does not register an offense when using constant' do
    expect_no_offenses(<<~RUBY)
      class Foo
        CONST = 42
      end
    RUBY
  end

  it 'does not register an offense when using constant after `private` access modifier in `class << self`' do
    expect_no_offenses(<<~RUBY)
      class Foo
        class << self
          private
          CONST = 42
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
end
