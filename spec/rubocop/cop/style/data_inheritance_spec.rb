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

  context 'Ruby <= 3.1', :ruby31 do
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
