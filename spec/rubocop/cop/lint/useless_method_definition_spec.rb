# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessMethodDefinition, :config do
  it 'does not register an offense for empty constructor' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def initialize(arg1, arg2)
        end
      end
    RUBY
  end

  it 'does not register an offense for constructor with only comments' do
    expect_no_offenses(<<~RUBY)
      def initialize(arg)
        # Comment.
      end
    RUBY
  end

  it 'does not register an offense for constructor containing additional code to `super`' do
    expect_no_offenses(<<~RUBY)
      def initialize(arg)
        super
        do_something
      end
    RUBY
  end

  it 'does not register an offense for empty class level `initialize` method' do
    expect_no_offenses(<<~RUBY)
      def self.initialize
      end
    RUBY
  end

  ['Class.new(Base)', 'Struct.new(:id)', 'included', 'class_methods'].each do |declaration|
    it "corrects a delegating definition inside #{declaration}" do
      expect_offense(<<~RUBY)
        #{declaration} do
          def foo
          ^^^^^^^ Useless method definition detected.
            super
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        #{declaration} do
         #{trailing_whitespace}
        end
      RUBY
    end
  end

  it 'does not register an offense when the method name is assigned' do
    expect_no_offenses(<<~RUBY)
      name ||= def foo
        super
      end
    RUBY
  end

  it 'does not register an offense when the visibility declaration is assigned' do
    expect_no_offenses(<<~RUBY)
      name = private def foo
        super
      end
    RUBY
  end

  it 'does not register an offense when the method name is returned by a block' do
    expect_no_offenses(<<~RUBY)
      names = items.map do |item|
        prepare(item)
        def self.foo
          super
        end
      end
    RUBY
  end

  it 'does not remove other arguments of a visibility declaration' do
    expect_no_offenses(<<~RUBY)
      private :bar, def foo
        super
      end
    RUBY
  end

  it 'does not register an offense when a class body supplies an assignment value' do
    expect_no_offenses(<<~RUBY)
      name = class Example
        def foo
          super
        end
      end
    RUBY
  end

  it 'corrects a standalone definition inside a conditional' do
    expect_offense(<<~RUBY)
      if enabled?
        def foo
        ^^^^^^^ Useless method definition detected.
          super
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if enabled?
       #{trailing_whitespace}
      end
    RUBY
  end

  it 'registers an offense and corrects for method containing only `super` call' do
    expect_offense(<<~RUBY)
      class Foo
        def useful_instance_method
          do_something
        end

        def instance_method
        ^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
          super
        end

        def instance_method_with_args(arg)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
          super(arg)
        end

        def self.useful_class_method
          do_something
        end

        def self.class_method
        ^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
          super
        end

        def self.class_method_with_args(arg)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
          super(arg)
        end

        class << self
          def self.other_useful_class_method
            do_something
          end

          def other_class_method
          ^^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
            super
          end

          def other_class_method_with_parens
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
            super()
          end

          def other_class_method_with_args(arg)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
            super(arg)
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        def useful_instance_method
          do_something
        end

       #{trailing_whitespace}

       #{trailing_whitespace}

        def self.useful_class_method
          do_something
        end

       #{trailing_whitespace}

       #{trailing_whitespace}

        class << self
          def self.other_useful_class_method
            do_something
          end

         #{trailing_whitespace}

         #{trailing_whitespace}

         #{trailing_whitespace}
        end
      end
    RUBY
  end

  it 'registers an offense and corrects when method definition with `public` access modifier containing only `super` call' do
    expect_offense(<<~RUBY)
      public def method
             ^^^^^^^^^^ Useless method definition detected.
        super
      end
    RUBY

    expect_correction("\n")
  end

  it 'registers an offense and corrects when method definition with `protected` access modifier containing only `super` call' do
    expect_offense(<<~RUBY)
      protected def method
                ^^^^^^^^^^ Useless method definition detected.
        super
      end
    RUBY

    expect_correction("\n")
  end

  it 'registers an offense and corrects when method definition with `private` access modifier containing only `super` call' do
    expect_offense(<<~RUBY)
      private def method
              ^^^^^^^^^^ Useless method definition detected.
        super
      end
    RUBY

    expect_correction("\n")
  end

  it 'registers an offense and corrects when method definition with `module_function` access modifier containing only `super` call' do
    expect_offense(<<~RUBY)
      module_function def method
                      ^^^^^^^^^^ Useless method definition detected.
        super
      end
    RUBY

    expect_correction("\n")
  end

  it 'does not register an offense for method containing additional code to `super`' do
    expect_no_offenses(<<~RUBY)
      def method
        super
        do_something
      end
    RUBY
  end

  it 'does not register an offense when `super` arguments differ from method arguments' do
    expect_no_offenses(<<~RUBY)
      def method1(foo)
        super(bar)
      end

      def method2(foo, bar)
        super(bar, foo)
      end

      def method3(foo, bar)
        super()
      end
    RUBY
  end

  it 'does not register an offense when method definition contains rest arguments' do
    expect_no_offenses(<<~RUBY)
      def method(*args)
        super
      end
    RUBY
  end

  it 'does not register an offense when method definition contains optional argument' do
    expect_no_offenses(<<~RUBY)
      def method(x = 1)
        super
      end
    RUBY
  end

  it 'does not register an offense when method definition contains optional keyword argument' do
    expect_no_offenses(<<~RUBY)
      def method(x: 1)
        super
      end
    RUBY
  end

  it 'does not register an offense when method definition contains rest keyword arguments' do
    expect_no_offenses(<<~RUBY)
      def method(**options)
        super
      end
    RUBY
  end

  it 'does not register an offense when method definition with generic method macro containing only `super` call' do
    expect_no_offenses(<<~RUBY)
      do_something def method
        super
      end
    RUBY
  end

  it 'does not register an offense when non-constructor contains only comments' do
    expect_no_offenses(<<~RUBY)
      def non_constructor
        # Comment.
      end
    RUBY
  end
end
