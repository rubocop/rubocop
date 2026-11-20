# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StructInheritance, :config do
  it 'registers an offense when extending instance of Struct' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
        def foo; end
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new(:first_name, :last_name) do
        def foo; end
      end
    RUBY
  end

  it 'registers an offense and adds parentheses when extending instance of Struct without parentheses' do
    expect_offense(<<~RUBY)
      class Person < Struct.new :first_name, :last_name
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
        def foo; end
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new(:first_name, :last_name) do
        def foo; end
      end
    RUBY
  end

  it 'registers an offense when extending instance of ::Struct' do
    expect_offense(<<~RUBY)
      class Person < ::Struct.new(:first_name, :last_name)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
        def foo; end
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = ::Struct.new(:first_name, :last_name) do
        def foo; end
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct with do ... end' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name) do end
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new(:first_name, :last_name) do
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct without `do` ... `end` and class body is empty' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new(:first_name, :last_name)
    RUBY
  end

  it 'registers an offense when extending instance of Struct without `do` ... `end` and class body is empty and single line definition' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name); end
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new(:first_name, :last_name)
    RUBY
  end

  it 'registers an offense when extending instance of Struct with an empty brace block' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name) { }
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new(:first_name, :last_name) do
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct with a brace block' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name) { include Comparable }
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new(:first_name, :last_name) do include Comparable
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct with a brace block without inner spaces' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name) {include Comparable}
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new(:first_name, :last_name) do include Comparable
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct with a multiline brace block' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name) {
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
        include Comparable
      }
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new(:first_name, :last_name) do
        include Comparable

      end
    RUBY
  end

  it 'registers an offense when extending instance of ::Struct with do ... end' do
    expect_offense(<<~RUBY)
      class Person < ::Struct.new(:first_name, :last_name) do end
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = ::Struct.new(:first_name, :last_name) do
      end
    RUBY
  end

  it 'registers an offense when extending instance of `Struct` when there is a comment ' \
     'before class declaration' do
    expect_offense(<<~RUBY)
      # comment
      class Person < Struct.new(:first_name, :last_name) do end
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      Person = Struct.new(:first_name, :last_name) do
      end
    RUBY
  end

  it 'registers an offense and preserves indentation when class is inside a module' do
    expect_offense(<<~RUBY)
      module MyModule
        class Person < Struct.new(:first_name, :last_name)
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
          def foo; end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module MyModule
        Person = Struct.new(:first_name, :last_name) do
          def foo; end
        end
      end
    RUBY
  end

  it 'accepts extending instance of Struct when the class body assigns a constant' do
    expect_no_offenses(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name)
        MAX_AGE = 120
      end
    RUBY
  end

  it 'accepts extending instance of Struct when a constant is assigned in a nested scope' do
    expect_no_offenses(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name)
        if something
          MAX_AGE = 120
        end
      end
    RUBY
  end

  it 'accepts extending instance of Struct when the class body defines a nested class' do
    expect_no_offenses(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name)
        class Error < StandardError; end
      end
    RUBY
  end

  it 'accepts extending instance of Struct when the class body defines a nested module' do
    expect_no_offenses(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name)
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

  it 'accepts assignment to Struct.new' do
    expect_no_offenses('Person = Struct.new(:first_name, :last_name)')
  end

  it 'accepts assignment to ::Struct.new' do
    expect_no_offenses('Person = ::Struct.new(:first_name, :last_name)')
  end

  it 'accepts assignment to block form of Struct.new' do
    expect_no_offenses(<<~RUBY)
      Person = Struct.new(:first_name, :last_name) do
        def age
          42
        end
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct and class body is empty and `end` is followed by code' do
    expect_offense(<<~RUBY)
      foo(class Person < Struct.new(:first_name, :last_name)
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end, bar)
    RUBY

    expect_correction(<<~RUBY)
      foo(Person = Struct.new(:first_name, :last_name), bar)
    RUBY
  end

  it 'registers an offense when extending instance of Struct without parentheses and class body is empty and `end` is followed by code' do
    expect_offense(<<~RUBY)
      foo(class Person < Struct.new :first_name, :last_name
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end, bar)
    RUBY

    expect_correction(<<~RUBY)
      foo(Person = Struct.new(:first_name, :last_name), bar)
    RUBY
  end

  it 'registers an offense when extending instance of Struct and class body is empty with a comment' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name) # comment
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new(:first_name, :last_name) # comment
    RUBY
  end

  it 'registers an offense when extending instance of Struct and class body is empty with a comment and `end` is followed by code' do
    expect_offense(<<~RUBY)
      foo(class Person < Struct.new(:first_name, :last_name) # comment
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end, bar)
    RUBY

    expect_correction(<<~RUBY)
      foo(Person = Struct.new(:first_name, :last_name) do # comment
      end, bar)
    RUBY
  end

  it 'registers an offense when extending instance of Struct with a heredoc argument and class body is empty and `end` is followed by code' do
    expect_offense(<<~RUBY)
      foo(class Person < Struct.new(<<~NAME)
                         ^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
        first_name
      NAME
      end, bar)
    RUBY

    expect_correction(<<~RUBY)
      foo(Person = Struct.new(<<~NAME) do
        first_name
      NAME
      end, bar)
    RUBY
  end

  it 'registers an offense when extending instance of Struct without parentheses and class body is empty' do
    expect_offense(<<~RUBY)
      class Person < Struct.new :first_name, :last_name
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new :first_name, :last_name
    RUBY
  end

  it 'registers an offense when extending instance of Struct without parentheses and with a comment between arguments and `end` is followed by code' do
    expect_offense(<<~RUBY)
      foo(class Person < Struct.new :first_name, # comment
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
            :last_name
      end, bar)
    RUBY

    expect_correction(<<~RUBY)
      foo(Person = Struct.new(:first_name, # comment
            :last_name), bar)
    RUBY
  end

  it 'registers an offense when extending instance of Struct without parentheses and class body is empty and the class is an argument' do
    expect_offense(<<~RUBY)
      foo(
        class Person < Struct.new :first_name, :last_name
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
        end
      )
    RUBY

    expect_correction(<<~RUBY)
      foo(
        Person = Struct.new(:first_name, :last_name)
      )
    RUBY
  end

  it 'registers an offense when extending instance of Struct without parentheses and class body is empty and the class is a hash value' do
    expect_offense(<<~RUBY)
      { key: class Person < Struct.new :first_name, :last_name
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
      }
    RUBY

    expect_correction(<<~RUBY)
      { key: Person = Struct.new(:first_name, :last_name)
      }
    RUBY
  end

  it 'registers an offense when extending instance of Struct without parentheses and class body is empty in a block body' do
    expect_offense(<<~RUBY)
      foo do
        class Person < Struct.new :first_name, :last_name
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      foo do
        Person = Struct.new :first_name, :last_name
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct without parentheses and class body is empty in a module body' do
    expect_offense(<<~RUBY)
      module Foo
        class Person < Struct.new :first_name, :last_name
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module Foo
        Person = Struct.new :first_name, :last_name
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct without parentheses and class body is empty in a `when` body' do
    expect_offense(<<~RUBY)
      case foo
      when bar
        class Person < Struct.new :first_name, :last_name
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      case foo
      when bar
        Person = Struct.new :first_name, :last_name
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct without parentheses and class body is empty in a `rescue` body' do
    expect_offense(<<~RUBY)
      begin
        foo
      rescue
        class Person < Struct.new :first_name, :last_name
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        foo
      rescue
        Person = Struct.new :first_name, :last_name
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct without parentheses and class body is empty in the body of a `while` modifier' do
    expect_offense(<<~RUBY)
      class Person < Struct.new :first_name, :last_name
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end while foo
    RUBY

    expect_correction(<<~RUBY)
      Person = Struct.new :first_name, :last_name while foo
    RUBY
  end

  it 'registers an offense when extending instance of Struct without parentheses and class body is empty in the condition of `if`' do
    expect_offense(<<~RUBY)
      if class Person < Struct.new :first_name, :last_name
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
        foo
      end
    RUBY

    expect_correction(<<~RUBY)
      if Person = Struct.new(:first_name, :last_name)
        foo
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct and class body is empty and the class is the left operand of `&&`' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name)
                     ^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end && foo
    RUBY

    expect_correction(<<~RUBY)
      (Person = Struct.new(:first_name)) && foo
    RUBY
  end

  it 'registers an offense when extending instance of Struct and the class is the receiver of a method call' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name)
                     ^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
        def age
        end
      end.do_something
    RUBY

    expect_correction(<<~RUBY)
      (Person = Struct.new(:first_name) do
        def age
        end
      end).do_something
    RUBY
  end

  it 'registers an offense when extending instance of Struct and class body is empty with a comment and the class is the receiver of a method call with a leading dot' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name) # comment
                     ^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
        .do_something
    RUBY

    expect_correction(<<~RUBY)
      (Person = Struct.new(:first_name) do # comment
      end)
        .do_something
    RUBY
  end
end
