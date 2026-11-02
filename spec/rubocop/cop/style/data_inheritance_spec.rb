# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DataInheritance, :config do
  context 'Ruby >= 3.2', :ruby32 do
    it 'registers an offense when extending instance of `Data.define`' do
      expect_offense(<<~RUBY)
        class Person < Data.define(:first_name, :last_name)
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
          def foo; end
        end
      RUBY

      expect_correction(<<~RUBY)
        Person = Data.define(:first_name, :last_name) do
          def foo; end
        end
      RUBY
    end

    it 'registers an offense when extending instance of `::Data.define`' do
      expect_offense(<<~RUBY)
        class Person < ::Data.define(:first_name, :last_name)
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
          def foo; end
        end
      RUBY

      expect_correction(<<~RUBY)
        Person = ::Data.define(:first_name, :last_name) do
          def foo; end
        end
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` with do ... end' do
      expect_offense(<<~RUBY)
        class Person < Data.define(:first_name, :last_name) do end
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end
      RUBY

      expect_correction(<<~RUBY)
        Person = Data.define(:first_name, :last_name) do
        end
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` with an empty brace block' do
      expect_offense(<<~RUBY)
        class Person < Data.define(:first_name, :last_name) { }
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end
      RUBY

      expect_correction(<<~RUBY)
        Person = Data.define(:first_name, :last_name) do
        end
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` with a brace block' do
      expect_offense(<<~RUBY)
        class Person < Data.define(:first_name, :last_name) { def age = 42 }
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end
      RUBY

      expect_correction(<<~RUBY)
        Person = Data.define(:first_name, :last_name) do def age = 42
        end
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` without `do` ... `end` and class body is empty' do
      expect_offense(<<~RUBY)
        class Person < Data.define(:first_name, :last_name)
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end
      RUBY

      expect_correction(<<~RUBY)
        Person = Data.define(:first_name, :last_name)
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` without `do` ... `end` and class body is empty and single line definition' do
      expect_offense(<<~RUBY)
        class Person < Data.define(:first_name, :last_name); end
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
      RUBY

      expect_correction(<<~RUBY)
        Person = Data.define(:first_name, :last_name)
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` and class body is empty and `end` is followed by code' do
      expect_offense(<<~RUBY)
        foo(class Person < Data.define(:first_name, :last_name)
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end, bar)
      RUBY

      expect_correction(<<~RUBY)
        foo(Person = Data.define(:first_name, :last_name), bar)
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` without parentheses and class body is empty and `end` is followed by code' do
      expect_offense(<<~RUBY)
        foo(class Person < Data.define :first_name, :last_name
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end, bar)
      RUBY

      expect_correction(<<~RUBY)
        foo(Person = Data.define(:first_name, :last_name), bar)
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` and class body is empty with a comment' do
      expect_offense(<<~RUBY)
        class Person < Data.define(:first_name, :last_name) # comment
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end
      RUBY

      expect_correction(<<~RUBY)
        Person = Data.define(:first_name, :last_name) # comment
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` and class body is empty with a comment and `end` is followed by code' do
      expect_offense(<<~RUBY)
        foo(class Person < Data.define(:first_name, :last_name) # comment
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end, bar)
      RUBY

      expect_correction(<<~RUBY)
        foo(Person = Data.define(:first_name, :last_name) do # comment
        end, bar)
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` without parentheses and class body is empty with a comment and `end` is followed by code' do
      expect_offense(<<~RUBY)
        foo(class Person < Data.define :first_name, :last_name # comment
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end, bar)
      RUBY

      expect_correction(<<~RUBY)
        foo(Person = Data.define(:first_name, :last_name) do # comment
        end, bar)
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` without parentheses and class body is empty' do
      expect_offense(<<~RUBY)
        class Person < Data.define :first_name, :last_name
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end
      RUBY

      expect_correction(<<~RUBY)
        Person = Data.define :first_name, :last_name
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` without parentheses and with a comment between arguments and `end` is followed by code' do
      expect_offense(<<~RUBY)
        foo(class Person < Data.define :first_name, # comment
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
              :last_name
        end, bar)
      RUBY

      expect_correction(<<~RUBY)
        foo(Person = Data.define(:first_name, # comment
              :last_name), bar)
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` without parentheses and class body is empty and the class is an argument' do
      expect_offense(<<~RUBY)
        foo(class Person < Data.define :first_name, :last_name
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end
        )
      RUBY

      expect_correction(<<~RUBY)
        foo(Person = Data.define(:first_name, :last_name)
        )
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` without parentheses and class body is empty in the body of a `while` modifier' do
      expect_offense(<<~RUBY)
        class Person < Data.define :first_name, :last_name
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end while foo
      RUBY

      expect_correction(<<~RUBY)
        Person = Data.define :first_name, :last_name while foo
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` and class body is empty and the class is the left operand of `&&`' do
      expect_offense(<<~RUBY)
        class Person < Data.define(:first_name)
                       ^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end && foo
      RUBY

      expect_correction(<<~RUBY)
        (Person = Data.define(:first_name)) && foo
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` and the class is the receiver of a method call in an argument without parentheses' do
      expect_offense(<<~RUBY)
        foo class Person < Data.define(:first_name)
                           ^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end.bar
      RUBY

      expect_correction(<<~RUBY)
        foo (Person = Data.define(:first_name)).bar
      RUBY
    end

    it 'registers an offense when extending instance of `::Data.define` with do ... end' do
      expect_offense(<<~RUBY)
        class Person < ::Data.define(:first_name, :last_name) do end
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end
      RUBY

      expect_correction(<<~RUBY)
        Person = ::Data.define(:first_name, :last_name) do
        end
      RUBY
    end

    it 'registers an offense when extending instance of `Data.define` when there is a comment ' \
       'before class declaration' do
      expect_offense(<<~RUBY)
        # comment
        class Person < Data.define(:first_name, :last_name) do end
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Data.define`. Use a block to customize the class.
        end
      RUBY

      expect_correction(<<~RUBY)
        # comment
        Person = Data.define(:first_name, :last_name) do
        end
      RUBY
    end

    it 'accepts extending instance of `Data.define` when the class body assigns a constant' do
      expect_no_offenses(<<~RUBY)
        class Person < Data.define(:first_name, :last_name)
          MAX_AGE = 120
        end
      RUBY
    end

    it 'accepts extending instance of `Data.define` when a constant is assigned in a nested scope' do
      expect_no_offenses(<<~RUBY)
        class Person < Data.define(:first_name, :last_name)
          if something
            MAX_AGE = 120
          end
        end
      RUBY
    end

    it 'accepts extending instance of `Data.define` when the class body defines a nested class' do
      expect_no_offenses(<<~RUBY)
        class Person < Data.define(:first_name, :last_name)
          class Error < StandardError; end
        end
      RUBY
    end

    it 'accepts extending instance of `Data.define` when the class body defines a nested module' do
      expect_no_offenses(<<~RUBY)
        class Person < Data.define(:first_name, :last_name)
          module Helpers; end
        end
      RUBY
    end

    it 'accepts plain class' do
      expect_no_offenses(<<~RUBY)
        class Person
        end
      RUBY
    end

    it 'accepts extending DelegateClass' do
      expect_no_offenses(<<~RUBY)
        class Person < DelegateClass(Animal)
        end
      RUBY
    end

    it 'accepts assignment to `Data.define`' do
      expect_no_offenses('Person = Data.define(:first_name, :last_name)')
    end

    it 'accepts assignment to `::Data.define`' do
      expect_no_offenses('Person = ::Data.define(:first_name, :last_name)')
    end

    it 'accepts assignment to block form of `Data.define`' do
      expect_no_offenses(<<~RUBY)
        Person = Data.define(:first_name, :last_name) do
          def age
            42
          end
        end
      RUBY
    end
  end

  context 'Ruby <= 3.1', :ruby31, unsupported_on: :prism do
    it 'accepts extending instance of `Data.define`' do
      expect_no_offenses(<<~RUBY)
        class Person < Data.define(:first_name, :last_name)
          def foo; end
        end
      RUBY
    end

    it 'accepts extending instance of `::Data.define`' do
      expect_no_offenses(<<~RUBY)
        class Person < ::Data.define(:first_name, :last_name)
          def foo; end
        end
      RUBY
    end

    it 'accepts extending instance of `Data.define` with do ... end' do
      expect_no_offenses(<<~RUBY)
        class Person < Data.define(:first_name, :last_name) do end
        end
      RUBY
    end

    it 'accepts extending instance of `Data.define` without `do` ... `end` and class body is empty' do
      expect_no_offenses(<<~RUBY)
        class Person < Data.define(:first_name, :last_name)
        end
      RUBY
    end

    it 'accepts extending instance of `Data.define` without `do` ... `end` and class body is empty and single line definition' do
      expect_no_offenses(<<~RUBY)
        class Person < Data.define(:first_name, :last_name); end
      RUBY
    end

    it 'accepts extending instance of `::Data.define` with do ... end' do
      expect_no_offenses(<<~RUBY)
        class Person < ::Data.define(:first_name, :last_name) do end
        end
      RUBY
    end

    it 'accepts extending instance of `Data.define` when there is a comment ' \
       'before class declaration' do
      expect_no_offenses(<<~RUBY)
        # comment
        class Person < Data.define(:first_name, :last_name) do end
        end
      RUBY
    end

    it 'accepts plain class' do
      expect_no_offenses(<<~RUBY)
        class Person
        end
      RUBY
    end

    it 'accepts extending DelegateClass' do
      expect_no_offenses(<<~RUBY)
        class Person < DelegateClass(Animal)
        end
      RUBY
    end

    it 'accepts assignment to `Data.define`' do
      expect_no_offenses('Person = Data.define(:first_name, :last_name)')
    end

    it 'accepts assignment to `::Data.define`' do
      expect_no_offenses('Person = ::Data.define(:first_name, :last_name)')
    end

    it 'accepts assignment to block form of `Data.define`' do
      expect_no_offenses(<<~RUBY)
        Person = Data.define(:first_name, :last_name) do
          def age
            42
          end
        end
      RUBY
    end
  end
end
