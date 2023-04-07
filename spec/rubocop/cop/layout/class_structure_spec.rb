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
      expect_offense <<-RUBY
        class GridTask
          DESC = 'Grid Task' # grid task name OID, subclasses should set this
          extend Helpers::MakeFromFile
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `module_inclusion` is supposed to appear before `constants`.
        end
      RUBY

      expect_correction <<-RUBY
        class GridTask
          extend Helpers::MakeFromFile
          DESC = 'Grid Task' # grid task name OID, subclasses should set this
        end
      RUBY
    end
  end

  context 'with a complete ordered example' do
    it 'does not create offense' do
      expect_no_offenses <<-RUBY
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
    let(:code) { <<-RUBY }
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
    let(:code) { <<-RUBY }
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
    it 'registers offense but does not autocorrect' do
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
end
