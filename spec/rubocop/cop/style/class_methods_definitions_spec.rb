# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassMethodsDefinitions, :config do
  context 'when EnforcedStyle is def_self' do
    let(:cop_config) { { 'EnforcedStyle' => 'def_self' } }

    it 'registers an offense and corrects when defining class methods with `class << self`' do
      expect_offense(<<~RUBY)
        class A
          class << self
          ^^^^^^^^^^^^^ Do not define public methods within class << self.
            attr_reader :two

            def three
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          class << self
            attr_reader :two

          end

          def self.three
          end
        end
      RUBY
    end

    it 'registers an offense and corrects when defining class methods with `class << self` and ' \
       'there is no blank line between method definition and attribute accessor' do
      expect_offense(<<~RUBY)
        class A
          class << self
          ^^^^^^^^^^^^^ Do not define public methods within class << self.
            def three
            end
            attr_reader :two
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          class << self
            attr_reader :two
          end

          def self.three
          end
        end
      RUBY
    end

    it 'correctly handles methods with annotation comments' do
      expect_offense(<<~RUBY)
        class A
          class << self
          ^^^^^^^^^^^^^ Do not define public methods within class << self.
            attr_reader :one

            # Multiline
            # comment.
            def two
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          class << self
            attr_reader :one

          end

          # Multiline
          # comment.
          def self.two
          end
        end
      RUBY
    end

    it 'correctly handles class << self containing multiple methods' do
      expect_offense(<<~RUBY)
        class A
          class << self
          ^^^^^^^^^^^^^ Do not define public methods within class << self.
            def one
              :one
            end

            def two
              :two
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          def self.one
            :one
          end

          def self.two
            :two
          end
        end
      RUBY
    end

    it 'removes empty class << self when correcting' do
      expect_offense(<<~RUBY)
        class A
          def self.one
          end

          class << self
          ^^^^^^^^^^^^^ Do not define public methods within class << self.
            def two
            end

            def three
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          def self.one
          end

          def self.two
          end

          def self.three
          end
        end
      RUBY
    end

    it 'correctly handles def self.x within class << self' do
      expect_offense(<<~RUBY)
        class A
          class << self
          ^^^^^^^^^^^^^ Do not define public methods within class << self.
            def self.one
            end

            def two
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          class << self
            def self.one
            end

          end

          def self.two
          end
        end
      RUBY
    end

    it 'registers and corrects an offense when defining class methods with `class << self` with comment only body' do
      expect_offense(<<~RUBY)
        class Foo
          class << self
          ^^^^^^^^^^^^^ Do not define public methods within class << self.
            def do_something
              # TODO
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          def self.do_something
            # TODO
          end
        end
      RUBY
    end

    it 'registers and corrects an offense when defining class methods with `class << self` with inline comment' do
      expect_offense(<<~RUBY)
        class Foo
          class << self
          ^^^^^^^^^^^^^ Do not define public methods within class << self.
            def do_something # TODO
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          def self.do_something # TODO
          end
        end
      RUBY
    end

    it 'does not register an offense when `class << self` contains non public methods' do
      expect_no_offenses(<<~RUBY)
        class A
          class << self
            def one
            end

            private

            def two
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when class << self does not contain methods' do
      expect_no_offenses(<<~RUBY)
        class A
          class << self
            attr_reader :one
          end
        end
      RUBY
    end

    it 'does not register an offense when defining class methods with `def self.method`' do
      expect_no_offenses(<<~RUBY)
        class A
          def self.one
          end
        end
      RUBY
    end

    it 'does not register an offense when defining singleton methods using `self << object`' do
      expect_no_offenses(<<~RUBY)
        class A
          class << not_self
            def one
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when class << self contains only class methods' do
      expect_no_offenses(<<~RUBY)
        class A
          class << self
            def self.one
            end
          end
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is self_class' do
    let(:cop_config) { { 'EnforcedStyle' => 'self_class' } }

    it 'registers an offense when defining class methods with `def self.method`' do
      expect_offense(<<~RUBY)
        class A
          def self.one
          ^^^^^^^^^^^^ Use `class << self` to define a class method.
          end
        end
      RUBY
    end

    it 'does not register an offense when defining class methods with `class << self`' do
      expect_no_offenses(<<~RUBY)
        class A
          class << self
            def one
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when defining singleton methods not on self' do
      expect_no_offenses(<<~RUBY)
        object = Object.new
        def object.method
        end
      RUBY
    end
  end
end
