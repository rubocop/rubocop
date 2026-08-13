# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ClassStructure, :config do
  let(:config) do
    RuboCop::Config.new(
      'Layout/ClassStructure' => {
        'ExpectedOrder' => %w[
          module_inclusion
          constants
          attribute_macros
          delegate
          macros
          public_class_methods
          initializer
          public_methods
          protected_attribute_macros
          protected_methods
          private_attribute_macros
          private_delegate
          private_class_methods
          private_methods
        ],
        'Categories' => {
          'attribute_macros' => %w[
            attr_accessor
            attr_reader
            attr_writer
          ],
          'macros' => %w[
            validates
            validate
          ],
          'module_inclusion' => %w[
            prepend
            extend
            include
          ]
        }
      }
    )
  end

  context 'when the first line ends with a comment' do
    it 'reports an offense and swaps the lines' do
      expect_offense <<~RUBY
        class GridTask
          DESC = 'Grid Task' # grid task name OID, subclasses should set this
          extend Helpers::MakeFromFile
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `module_inclusion` is supposed to appear before `constants`.
        end
      RUBY

      expect_correction <<~RUBY
        class GridTask
          extend Helpers::MakeFromFile
          DESC = 'Grid Task' # grid task name OID, subclasses should set this
        end
      RUBY
    end
  end

  context 'with a complete ordered example' do
    it 'does not create offense' do
      expect_no_offenses <<~RUBY
        class Person
          # extend and include go first
          extend SomeModule
          include AnotherModule

          # inner classes
          CustomError = Class.new(StandardError)

          # constants are next
          SOME_CONSTANT = 20

          # afterwards we have attribute macros
          attr_reader :name

          # then we have public delegate macros
          delegate :to_s, to: :name

          # followed by other macros (if any)
          validates :name

          # public class methods are next in line
          def self.some_method
          end

          # initialization goes between class methods and other instance methods
          def initialize
          end

          # followed by other public instance methods
          def some_method
          end

          # protected attribute macros and methods go next
          protected

          attr_reader :protected_name

          def some_protected_method
          end

          # private attribute macros, delegate macros and methods are grouped near the end
          private

          attr_reader :private_name

          delegate :some_private_delegate, to: :name

          def some_private_method
          end
        end
      RUBY
    end
  end

  context 'simple example' do
    specify do
      expect_offense <<~RUBY
        class Person
          CONST = 'wrong place'
          include AnotherModule
          ^^^^^^^^^^^^^^^^^^^^^ `module_inclusion` is supposed to appear before `constants`.
          extend SomeModule
        end
      RUBY

      expect_correction(<<~RUBY)
        class Person
          include AnotherModule
          extend SomeModule
          CONST = 'wrong place'
        end
      RUBY
    end
  end

  context 'when the class body is a single non-def/send node' do
    it 'does not get confused by (or crash on) a single safe-navigation call body' do
      expect_no_offenses(<<~RUBY)
        class A
          test&.private_methods(def foo; end)
        end
      RUBY
    end

    it 'does not get confused by a single conditional body' do
      expect_no_offenses(<<~RUBY)
        class A
          def foo; end if bar
        end
      RUBY
    end

    it 'does not get confused by a single block body' do
      expect_no_offenses(<<~RUBY)
        class A
          configure { |c| c.foo = 1 }
        end
      RUBY
    end
  end

  context 'when class body elements are wrapped in a begin block' do
    it 'registers an offense and corrects misordered elements inside a begin block' do
      expect_offense(<<~RUBY)
        class Foo
          begin
            private def do_internal_work; end
            public def do_something; end
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `public_methods` is supposed to appear before `private_methods`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          begin
            public def do_something; end
            private def do_internal_work; end
          end
        end
      RUBY
    end

    it 'registers an offense and corrects misordered elements inside nested begin blocks' do
      expect_offense(<<~RUBY)
        class Foo
          begin
            begin
              private def do_internal_work; end
              public def do_something; end
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `public_methods` is supposed to appear before `private_methods`.
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          begin
            begin
              public def do_something; end
              private def do_internal_work; end
            end
          end
        end
      RUBY
    end

    it 'does not register an offense for ordered elements inside a begin block' do
      expect_no_offenses(<<~RUBY)
        class Foo
          begin
            public def do_something; end
            private def do_internal_work; end
          end
        end
      RUBY
    end

    it 'does not get confused by a begin block with a rescue clause' do
      expect_no_offenses(<<~RUBY)
        class Foo
          begin
            require 'optional_dependency'
          rescue LoadError
            nil
          end
        end
      RUBY
    end
  end

  it 'registers an offense and corrects when public instance method is before class method' do
    expect_offense(<<~RUBY)
      class Foo
        def instance_method; end
        def self.class_method; end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ `public_class_methods` is supposed to appear before `public_methods`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        def self.class_method; end
        def instance_method; end
      end
    RUBY
  end

  context 'with protected methods declared before private' do
    let(:code) { <<~RUBY }
      class MyClass
        def public_method
        end

        private

        def first_private_method
        end

        def second_private_method
        end

        protected

        def first_protected_method
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ `protected_methods` is supposed to appear before `private_methods`.
        end

        def second_protected_method
        end
      end
    RUBY

    it { expect_offense(code) }
  end

  context 'with attribute macros before after validations' do
    let(:code) { <<~RUBY }
      class Person
        include AnotherModule
        extend SomeModule

        CustomError = Class.new(StandardError)

        validates :name

        attr_reader :name
        ^^^^^^^^^^^^^^^^^ `attribute_macros` is supposed to appear before `macros`.

        def self.some_public_class_method
        end

        def initialize
        end

        def some_public_method
        end


        def yet_other_public_method
        end

        protected

        def some_protected_method
        end

        def other_public_method
        end

        private :other_public_method

        private

        def some_private_method
        end
      end
    RUBY

    it { expect_offense(code) }
  end

  context 'constant is not a literal' do
    it 'registers an offense but does not autocorrect' do
      expect_offense <<~RUBY
        class Person
          def name; end

          foo = 5
          LIMIT = foo + 1
          ^^^^^^^^^^^^^^^ `constants` is supposed to appear before `public_methods`.
        end
      RUBY

      expect_no_corrections
    end
  end

  it 'registers an offense and corrects when there is a comment in the macro method' do
    expect_offense(<<~RUBY)
      class Foo
        # This is a comment for macro method.
        validates :attr
        attr_reader :foo
        ^^^^^^^^^^^^^^^^ `attribute_macros` is supposed to appear before `macros`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_reader :foo
        # This is a comment for macro method.
        validates :attr
      end
    RUBY
  end

  it 'registers an offense and corrects when literal constant is after method definitions' do
    expect_offense(<<~RUBY)
      class Foo
        def name; end

        LIMIT = 10
        ^^^^^^^^^^ `constants` is supposed to appear before `public_methods`.
        CONST = 'wrong place'.freeze
        RECURSIVE_BASIC_LITERALS_CONST = [1, 2].freeze
        DYNAMIC_CONST = foo.freeze
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        LIMIT = 10
        CONST = 'wrong place'.freeze
        RECURSIVE_BASIC_LITERALS_CONST = [1, 2].freeze
        def name; end

        DYNAMIC_CONST = foo.freeze
      end
    RUBY
  end

  it 'ignores misplaced private constants' do
    expect_offense(<<~RUBY)
      class Foo
        def name; end

        PRIVATE_CONST1 = 1
        PRIVATE_CONST2 = 2
        private_constant :PRIVATE_CONST1, :PRIVATE_CONST2
        PUBLIC_CONST = 'public'
        ^^^^^^^^^^^^^^^^^^^^^^^ `constants` is supposed to appear before `public_methods`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        PUBLIC_CONST = 'public'
        def name; end

        PRIVATE_CONST1 = 1
        PRIVATE_CONST2 = 2
        private_constant :PRIVATE_CONST1, :PRIVATE_CONST2
      end
    RUBY
  end

  it 'registers an offense and corrects when str heredoc constant is defined after public method' do
    expect_offense(<<~RUBY)
      class Foo
        def do_something
        end

        CONSTANT = <<~EOS
        ^^^^^^^^^^^^^^^^^ `constants` is supposed to appear before `public_methods`.
          str
        EOS
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        CONSTANT = <<~EOS
          str
        EOS

        def do_something
        end
      end
    RUBY
  end

  it 'registers an offense and corrects when dstr heredoc constant is defined after public method' do
    expect_offense(<<~'RUBY')
      class Foo
        def do_something
        end

        CONSTANT = <<~EOS
        ^^^^^^^^^^^^^^^^^ `constants` is supposed to appear before `public_methods`.
          #{str}
        EOS
      end
    RUBY

    expect_correction(<<~'RUBY')
      class Foo
        CONSTANT = <<~EOS
          #{str}
        EOS

        def do_something
        end
      end
    RUBY
  end

  it 'registers an offense and corrects when xstr heredoc constant is defined after public method' do
    expect_offense(<<~RUBY)
      class Foo
        def do_something
        end

        CONSTANT = <<~`EOS`
        ^^^^^^^^^^^^^^^^^^^ `constants` is supposed to appear before `public_methods`.
          str
        EOS
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        CONSTANT = <<~`EOS`
          str
        EOS

        def do_something
        end
      end
    RUBY
  end

  it 'registers an offense and corrects when public class method with heredoc after instance method' do
    expect_offense(<<~RUBY)
      class Foo
        def instance_method
          'instance method'
        end

        def self.class_method
        ^^^^^^^^^^^^^^^^^^^^^ `public_class_methods` is supposed to appear before `public_methods`.
          <<~EOS
            class method
          EOS
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        def self.class_method
          <<~EOS
            class method
          EOS
        end
        def instance_method
          'instance method'
        end

      end
    RUBY
  end

  context 'when def modifier is used' do
    it 'registers an offense and corrects public method with modifier declared after private method with modifier' do
      expect_offense(<<~RUBY)
        class A
          private def foo
          end

          public def bar
          ^^^^^^^^^^^^^^ `public_methods` is supposed to appear before `private_methods`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          public def bar
          end
          private def foo
          end

        end
      RUBY
    end

    it 'registers an offense and corrects public method without modifier declared after private method with modifier' do
      expect_offense(<<~RUBY)
        class A
          private def foo
          end

          def bar
          ^^^^^^^ `public_methods` is supposed to appear before `private_methods`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          def bar
          end
          private def foo
          end

        end
      RUBY
    end

    it 'registers an offense and corrects when definitions that need to be sorted are defined alternately' do
      expect_offense(<<~RUBY)
        class A
          private def foo; end

          def bar; end
          ^^^^^^^^^^^^ `public_methods` is supposed to appear before `private_methods`.

          private def baz; end

          def qux; end
          ^^^^^^^^^^^^ `public_methods` is supposed to appear before `private_methods`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          def bar; end
          def qux; end
          private def foo; end


          private def baz; end

        end
      RUBY
    end

    it 'registers an offense and corrects public class method with modifier declared after private class method with modifier' do
      expect_offense(<<~RUBY)
        class A
          private_class_method def self.do_internal_work
          end

          public_class_method def self.do_something
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `public_class_methods` is supposed to appear before `private_class_methods`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          public_class_method def self.do_something
          end
          private_class_method def self.do_internal_work
          end

        end
      RUBY
    end

    it 'does not register an offense when public class method with modifier is declared before private class method with modifier' do
      expect_no_offenses(<<~RUBY)
        class A
          public_class_method def self.do_something
          end

          private_class_method def self.do_internal_work
          end
        end
      RUBY
    end

    it 'registers an offense and corrects private class method with modifier declared after private instance method' do
      expect_offense(<<~RUBY)
        class A
          private

          def do_something
          end

          private_class_method def self.do_internal_work
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `private_class_methods` is supposed to appear before `private_methods`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          private

          private_class_method def self.do_internal_work
          end
          def do_something
          end

        end
      RUBY
    end

    it 'does not register an offense when private class method with modifier is declared before private instance method' do
      expect_no_offenses(<<~RUBY)
        class A
          private

          private_class_method def self.do_internal_work
          end

          def do_something
          end
        end
      RUBY
    end

    it 'registers an offense and corrects public method after private method marked by its name' do
      expect_offense(<<~RUBY)
        class A
          def foo
          end
          private :foo

          def bar
          ^^^^^^^ `public_methods` is supposed to appear before `private_methods`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          def bar
          end
          def foo
          end
          private :foo

        end
      RUBY
    end
  end

  context 'initializer is private and comes after attribute macro' do
    it 'registers an offense and autocorrects' do
      expect_offense(<<~RUBY)
        class A
          private

          attr_accessor :foo

          def initialize
          ^^^^^^^^^^^^^^ `initializer` is supposed to appear before `private_attribute_macros`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
          private

          def initialize
          end
          attr_accessor :foo

        end
      RUBY
    end
  end

  context 'when misordered elements share their expected position' do
    it 'corrects them in a single pass, preserving their relative order' do
      expect_offense(<<~RUBY)
        class Foo
          def do_something; end
          include M
          ^^^^^^^^^ `module_inclusion` is supposed to appear before `public_methods`.
          CONST = 1
          ^^^^^^^^^ `constants` is supposed to appear before `public_methods`.
        end
      RUBY

      expect_correction(<<~RUBY, loop: false)
        class Foo
          include M
          CONST = 1
          def do_something; end
        end
      RUBY
    end

    it 'reports the category blocking the expected order, not the adjacent element' do
      expect_offense(<<~RUBY)
        class Foo
          def self.do_something; end

          def initialize; end

          include M
          ^^^^^^^^^ `module_inclusion` is supposed to appear before `initializer`.
          CONST = 1
          ^^^^^^^^^ `constants` is supposed to appear before `initializer`.
        end
      RUBY

      expect_correction(<<~RUBY, loop: false)
        class Foo
          include M
          CONST = 1
          def self.do_something; end

          def initialize; end

        end
      RUBY
    end
  end

  context 'when consecutive elements of the same category are misordered' do
    it 'registers an offense only on the first element and moves the whole group in a single pass' do
      expect_offense(<<~RUBY)
        class Foo
          def do_something; end
          FIRST = 1
          ^^^^^^^^^ `constants` is supposed to appear before `public_methods`.
          SECOND = 2
        end
      RUBY

      expect_correction(<<~RUBY, loop: false)
        class Foo
          FIRST = 1
          SECOND = 2
          def do_something; end
        end
      RUBY
    end
  end

  context 'when a constant not assigned with a literal sits between misordered elements' do
    it 'registers offenses but does not move elements across the constant' do
      expect_offense(<<~RUBY)
        class Foo
          def do_something; end
          CONST = [*foo].freeze
          ^^^^^^^^^^^^^^^^^^^^^ `constants` is supposed to appear before `public_methods`.
          include M
          ^^^^^^^^^ `module_inclusion` is supposed to appear before `public_methods`.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for a misordered element that follows the constant' do
      expect_offense(<<~RUBY)
        class Foo
          validates :name
          CONST = do_something.freeze
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ `constants` is supposed to appear before `macros`.
          attr_reader :foo
          ^^^^^^^^^^^^^^^^ `attribute_macros` is supposed to appear before `macros`.
        end
      RUBY

      expect_no_corrections
    end

    it 'moves only the part of a group that precedes the constant' do
      expect_offense(<<~RUBY)
        class Foo
          def do_something; end
          FIRST = 1
          ^^^^^^^^^ `constants` is supposed to appear before `public_methods`.
          DYNAMIC = do_something.freeze
          SECOND = 2
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          FIRST = 1
          def do_something; end
          DYNAMIC = do_something.freeze
          SECOND = 2
        end
      RUBY
    end
  end

  context 'when correcting would move an element across a bare visibility modifier' do
    it 'registers an offense for a method but does not correct' do
      expect_offense(<<~RUBY)
        class Foo
          private

          def do_internal_work; end

          public

          def do_something; end
          ^^^^^^^^^^^^^^^^^^^^^ `public_methods` is supposed to appear before `private_methods`.
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for an attribute macro but does not correct' do
      expect_offense(<<~RUBY)
        class Foo
          private

          def do_internal_work; end

          public

          attr_reader :foo
          ^^^^^^^^^^^^^^^^ `attribute_macros` is supposed to appear before `private_methods`.
        end
      RUBY

      expect_no_corrections
    end

    it 'corrects a misordered constant, which may cross the modifier' do
      expect_offense(<<~RUBY)
        class Foo
          def do_something; end

          private

          CONST = 1
          ^^^^^^^^^ `constants` is supposed to appear before `public_methods`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          CONST = 1
          def do_something; end

          private

        end
      RUBY
    end
  end

  context 'when singleton class' do
    context 'simple example' do
      specify do
        expect_offense <<~RUBY
          class << self
            CONST = 'wrong place'
            include AnotherModule
            ^^^^^^^^^^^^^^^^^^^^^ `module_inclusion` is supposed to appear before `constants`.
            extend SomeModule
          end
        RUBY

        expect_correction(<<~RUBY)
          class << self
            include AnotherModule
            extend SomeModule
            CONST = 'wrong place'
          end
        RUBY
      end
    end
  end

  context 'when constants is in the Categories' do
    let(:config) do
      RuboCop::Config.new(
        'Layout/ClassStructure' => {
          'ExpectedOrder' => %w[
            all_constants
            attribute_macros
          ],
          'Categories' => {
            'all_constants' => %w[
              constants
            ],
            'attribute_macros' => %w[
              attr_accessor
            ]
          }
        }
      )
    end

    it 'registers an offense and corrects when attribute macros after constant' do
      expect_offense(<<~RUBY)
        class Foo
          attr_accessor :foo
          CONST = 'wrong place'
          ^^^^^^^^^^^^^^^^^^^^^ `all_constants` is supposed to appear before `attribute_macros`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          CONST = 'wrong place'
          attr_accessor :foo
        end
      RUBY
    end
  end
end
