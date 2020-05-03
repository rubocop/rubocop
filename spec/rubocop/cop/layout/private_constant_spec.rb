# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::PrivateConstant do
  subject(:cop) { described_class.new }

  it 'allows public constants' do
    expect_no_offenses(<<~RUBY)
      class EverythingPublic
        MSG = 'Hello'

        def method; end
      end
    RUBY
  end

  context 'empty class' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class CustomError < StandardError; end
      RUBY
    end
  end

  context 'opening up the class' do
    it 'does not incorrectly register an offense' do
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

  context 'constant in private block' do
    it 'registers an offense' do
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

  context 'public block after private block' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def public_stuff; end

          private

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

  context 'private constant that is explicitly marked private' do
    it 'does not register an offense' do
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
end
