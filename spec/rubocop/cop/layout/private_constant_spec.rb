# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::PrivateConstant, :config do
  it do
    expect_no_offenses(<<~RUBY)
      class EverythingPublic
        MSG = 'Hello'

        def method; end
      end
    RUBY
  end

  context 'empty class' do
    it do
      expect_no_offenses(<<~RUBY)
        class CustomError < StandardError; end
      RUBY
    end
  end

  context 'opening up the class' do
    it do
      expect_no_offenses(<<~RUBY)
        class MyClass
          CONSTANT = 1
          MY_CONSTANT = 1
          YOUR_CONSTANT = 1

          class << self
            private
            def method; end
          end
        end
      RUBY
    end
  end

  context 'private constant' do
    it do
      expect_offense(<<~RUBY)
        class Foo
          def public_stuff; end

          private
          MY_CONSTANT = 7
          ^^^^^^^^^^^^^^^ #{RuboCop::Cop::Layout::PrivateConstant::MSG}
          YOUR_CONSTANT = 21
          ^^^^^^^^^^^^^^^^^^ #{RuboCop::Cop::Layout::PrivateConstant::MSG}

          def my_method
            MY_CONSTANT
          end

          public
          PUBLIC_CONSTANT = 'string'
          def public_method; end
        end
      RUBY
    end
  end

  context 'private constant with different order' do
    it do
      expect_offense(<<~RUBY)
        class Foo < Bar
          def public_stuff; end

          private

          def my_method
            MY_CONSTANT
          end

          MY_CONSTANT = 7
          ^^^^^^^^^^^^^^^ #{RuboCop::Cop::Layout::PrivateConstant::MSG}
          YOUR_CONSTANT = 21
          ^^^^^^^^^^^^^^^^^^ #{RuboCop::Cop::Layout::PrivateConstant::MSG}
        end
      RUBY
    end
  end

  context 'private constant that is actually private' do
    it do
      expect_no_offenses(<<~RUBY)
        class Foo
          def public_stuff; end

          private

          def my_method
            MY_CONSTANT
          end

          MY_CONSTANT = 7
          private_constant :MY_CONSTANT
        end
      RUBY
    end
  end

  context 'private constant that is made private as it is declared' do
    it do
      expect_no_offenses(<<~RUBY)
        class Foo
          def public_stuff; end

          private

          def my_method
            MY_CONSTANT
          end

          private_constant MY_CONSTANT = 7
        end
      RUBY
    end
  end

  context 'multiple constants where 1 is missing its privacy declaration' do
    it do
      expect_offense(<<~RUBY)
        class Foo
          def public_stuff; end

          private

          def my_method
            MY_CONSTANT
          end

          private_constant MY_CONSTANT = 7
          MY_OTHER_CONSTANT = 1
          private_constant :MY_OTHER_CONSTANT
          MY_UNPROTECTED_CONSTANT = 2
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{RuboCop::Cop::Layout::PrivateConstant::MSG}
        end
      RUBY
    end
  end

  context 'class with single expression body' do
    it do
      expect_no_offenses(<<~RUBY)
        class Foo
          MY_CONSTANT = 7
        end
      RUBY
    end
  end

  context 'private_constant used in public section' do
    it do
      expect_no_offenses(<<~RUBY)
        class Foo
          private_constant MY_CONSTANT = 7

          def public_stuff; end

          private
          def private_stuff; end
        end
      RUBY
    end
  end

  context 'with other method calls' do
    it do
      expect_no_offenses(<<~RUBY)
        class Foo
          extend SomeModule
          MY_CONSTANT = 7
        end
      RUBY
    end
  end
end
