# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MissingSuper do
  subject(:cop) { described_class.new }

  context 'constructor' do
    it 'registers an offense when no `super` call' do
      expect_offense(<<~RUBY)
        class Child < Parent
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
          end
        end
      RUBY
    end

    it 'does not register an offense for the class without parent class' do
      expect_no_offenses(<<~RUBY)
        class Child
          def initialize
          end
        end
      RUBY
    end

    it 'does not register an offense for the class with stateless parent class' do
      expect_no_offenses(<<~RUBY)
        class Child < Object
          def initialize
          end
        end
      RUBY
    end

    it 'does not register an offense for the constructor-like method defined outside of a class' do
      expect_no_offenses(<<~RUBY)
        module M
          def initialize
          end
        end
      RUBY
    end

    it 'does not register an offense when there is a `super` call' do
      expect_no_offenses(<<~RUBY)
        class Child < Parent
          def initialize
            super
          end
        end
      RUBY
    end
  end

  context 'callbacks' do
    it 'registers an offense when module callback without `super` call' do
      expect_offense(<<~RUBY)
        module M
          def self.included(base)
          ^^^^^^^^^^^^^^^^^^^^^^^ Call `super` to invoke callback defined in the parent class.
          end
        end
      RUBY
    end

    it 'registers an offense when class callback without `super` call' do
      expect_offense(<<~RUBY)
        class Foo
          def self.inherited(base)
          ^^^^^^^^^^^^^^^^^^^^^^^^ Call `super` to invoke callback defined in the parent class.
          end
        end
      RUBY
    end

    it 'registers an offense when class callback within `self << class` and without `super` call' do
      expect_offense(<<~RUBY)
        class Foo
          class << self
            def inherited(base)
            ^^^^^^^^^^^^^^^^^^^ Call `super` to invoke callback defined in the parent class.
            end
          end
        end
      RUBY
    end

    it 'registers an offense for instance level `method_missing?` with no `super` call' do
      expect_offense(<<~RUBY)
        class Foo
          def method_missing(*args)
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Call `super` to invoke callback defined in the parent class.
          end
        end
      RUBY
    end

    it 'registers an offense for class level `method_missing?` with no `super` call' do
      expect_offense(<<~RUBY)
        class Foo
          def self.method_missing(*args)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Call `super` to invoke callback defined in the parent class.
          end
        end
      RUBY
    end

    it 'does not register an offense when `method_missing?` contains `super` call' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def method_missing(*args)
            super
            do_something
          end
        end
      RUBY
    end

    it 'does not register an offense when class has instance method named as callback' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def included(base)
          end
        end
      RUBY
    end

    it 'does not register an offense when callback has a `super` call' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def self.inherited(base)
            super
          end
        end
      RUBY
    end
  end
end
