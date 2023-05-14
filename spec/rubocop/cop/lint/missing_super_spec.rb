# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MissingSuper, :config do
  context 'constructor' do
    it 'registers an offense and does not autocorrect when no `super` call' do
      expect_offense(<<~RUBY)
        class Child < Parent
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense and does not autocorrect when no `super` call and when defining some method' do
      expect_offense(<<~RUBY)
        class Child < Parent
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
          end

          def do_something
          end
        end
      RUBY

      expect_no_corrections
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

    it 'does not register an offense for the `Class.new` without parent class argument' do
      expect_no_offenses(<<~RUBY)
        class Child < Parent
          Class.new do
            def initialize
            end
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

  context '`Class.new` block' do
    it 'registers an offense and does not autocorrect when no `super` call' do
      expect_offense(<<~RUBY)
        Class.new(Parent) do
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for the `Class.new` without parent class argument' do
      expect_no_offenses(<<~RUBY)
        Class.new do
          def initialize
          end
        end
      RUBY
    end

    it 'does not register an offense for the `Class.new` with stateless parent class argument' do
      expect_no_offenses(<<~RUBY)
        Class.new(Object) do
          def initialize
          end
        end
      RUBY
    end
  end

  context '`Class.new` numbered block', :ruby27 do
    it 'registers an offense and does not autocorrect when no `super` call' do
      expect_offense(<<~RUBY)
        Class.new(Parent) do
          def initialize
          ^^^^^^^^^^^^^^ Call `super` to initialize state of the parent class.
          end

          do_something(_1)
        end
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for the `Class.new` without parent class argument' do
      expect_no_offenses(<<~RUBY)
        Class.new do
          def initialize
          end

          do_something(_1)
        end
      RUBY
    end

    it 'does not register an offense for the `Class.new` with stateless parent class argument' do
      expect_no_offenses(<<~RUBY)
        Class.new(Object) do
          def initialize
          end

          do_something(_1)
        end
      RUBY
    end
  end

  context 'callbacks' do
    it 'registers no offense when module callback without `super` call' do
      expect_no_offenses(<<~RUBY)
        module M
          def self.included(base)
          end
        end
      RUBY
    end

    it 'registers an offense and does not autocorrect when class callback without `super` call' do
      expect_offense(<<~RUBY)
        class Foo
          def self.inherited(base)
          ^^^^^^^^^^^^^^^^^^^^^^^^ Call `super` to invoke callback defined in the parent class.
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense and does not autocorrect when class callback within `self << class` and without `super` call' do
      expect_offense(<<~RUBY)
        class Foo
          class << self
            def inherited(base)
            ^^^^^^^^^^^^^^^^^^^ Call `super` to invoke callback defined in the parent class.
            end
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense and does not autocorrect when method callback is without `super` call' do
      expect_offense(<<~RUBY)
        class Foo
          def method_added(*)
          ^^^^^^^^^^^^^^^^^^^ Call `super` to invoke callback defined in the parent class.
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense when callback has a `super` call' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def self.inherited(base)
            do_something
            super
          end
        end
      RUBY
    end
  end
end
