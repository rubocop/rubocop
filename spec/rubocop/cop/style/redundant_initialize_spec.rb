# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantInitialize, :config do
  let(:cop_config) { { 'AllowComments' => true } }

  it 'does not register an offense for an empty method not named `initialize`' do
    expect_no_offenses(<<~RUBY)
      def do_something
      end
    RUBY
  end

  it 'does not register an offense for a method not named `initialize` that only calls super' do
    expect_no_offenses(<<~RUBY)
      def do_something
        super
      end
    RUBY
  end

  it 'registers and corrects an offense for an empty `initialize` method' do
    expect_offense(<<~RUBY)
      def initialize
      ^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
      end
    RUBY

    expect_correction('')
  end

  it 'does not register an offense for an `initialize` method with only a comment' do
    expect_no_offenses(<<~RUBY)
      def initialize
        # initializer
      end
    RUBY
  end

  it 'registers and corrects an offense for an `initialize` method that only calls `super`' do
    expect_offense(<<~RUBY)
      def initialize
      ^^^^^^^^^^^^^^ Remove unnecessary `initialize` method.
        super
      end
    RUBY

    expect_correction('')
  end

  it 'registers and corrects an offense for an `initialize` method with arguments that only calls `super`' do
    expect_offense(<<~RUBY)
      def initialize(a, b)
      ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `initialize` method.
        super
      end
    RUBY

    expect_correction('')
  end

  it 'registers and corrects an offense for an `initialize` method with arguments that only calls `super` with explicit args' do
    expect_offense(<<~RUBY)
      def initialize(a, b)
      ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `initialize` method.
        super(a, b)
      end
    RUBY

    expect_correction('')
  end

  it 'does not register an offense for an `initialize` method that calls another method' do
    expect_no_offenses(<<~RUBY)
      def initialize(a, b)
        do_something
      end
    RUBY
  end

  it 'does not register an offense for an `initialize` method that calls another method before `super`' do
    expect_no_offenses(<<~RUBY)
      def initialize(a, b)
        do_something
        super
      end
    RUBY
  end

  it 'does not register an offense for an `initialize` method that calls another method after `super`' do
    expect_no_offenses(<<~RUBY)
      def initialize(a, b)
        super
        do_something
      end
    RUBY
  end

  it 'does not register an offense for an `initialize` method that calls `super` with a different argument list' do
    expect_no_offenses(<<~RUBY)
      def initialize(a, b)
        super(a)
      end
    RUBY
  end

  it 'does not register an offense for an `initialize` method that calls `super` with no arguments' do
    expect_no_offenses(<<~RUBY)
      def initialize(a, b)
        super()
      end
    RUBY
  end

  it 'registers and corrects an offense for an `initialize` method with no arguments that calls `super` with no arguments' do
    expect_offense(<<~RUBY)
      def initialize()
      ^^^^^^^^^^^^^^^^ Remove unnecessary `initialize` method.
        super()
      end
    RUBY

    expect_correction('')
  end

  it 'registers and corrects an offense for an endless `initialize` method that only calls `super`', :ruby30 do
    expect_offense(<<~RUBY)
      def initialize(a, b) = super
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `initialize` method.
    RUBY

    expect_correction('')
  end

  it 'does not register an offense for an empty `initialize` method used as a method argument' do
    expect_no_offenses(<<~RUBY)
      foo(bar, def initialize
      end)
    RUBY
  end

  it 'does not register an offense for an `initialize` method that only calls `super` on its own lines as a method argument' do
    expect_no_offenses(<<~RUBY)
      foo(
        def initialize
          super
        end
      )
    RUBY
  end

  it 'registers and corrects an offense for an `initialize` method that only calls `super` in a block' do
    expect_offense(<<~RUBY)
      Class.new do
        def initialize
        ^^^^^^^^^^^^^^ Remove unnecessary `initialize` method.
          super
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      Class.new do
      end
    RUBY
  end

  it 'registers and corrects an offense for an empty `initialize` method in an `if` branch' do
    expect_offense(<<~RUBY)
      if condition
        def initialize
        ^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if condition
      end
    RUBY
  end

  it 'registers and corrects an offense for an empty `initialize` method in a `when` branch' do
    expect_offense(<<~RUBY)
      case x
      when y
        def initialize
        ^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      case x
      when y
      end
    RUBY
  end

  it 'registers and corrects an offense for an empty `initialize` method in an `ensure` clause' do
    expect_offense(<<~RUBY)
      begin
      ensure
        def initialize
        ^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
      ensure
      end
    RUBY
  end

  it 'registers and corrects an offense for a private `initialize` method that only calls `super`' do
    expect_offense(<<~RUBY)
      class Foo
        private def initialize
                ^^^^^^^^^^^^^^ Remove unnecessary `initialize` method.
          super
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
      end
    RUBY
  end

  it 'does not register an offense for a public `initialize` method that only calls `super`' do
    expect_no_offenses(<<~RUBY)
      class Foo
        public def initialize
          super
        end
      end
    RUBY
  end

  it 'does not register an offense for an `initialize` method that only calls `super` used as a value' do
    expect_no_offenses(<<~RUBY)
      x = def initialize
        super
      end
    RUBY
  end

  it 'does not register an offense for an empty `initialize` method used as a value in parentheses' do
    expect_no_offenses(<<~RUBY)
      x = (
        def initialize
        end
      )
    RUBY
  end

  it 'does not register an offense for an empty `initialize` method that is the value of an assigned `if`' do
    expect_no_offenses(<<~RUBY)
      x = if condition
        def initialize
        end
      end
    RUBY
  end

  it 'does not register an offense for an empty `initialize` method that is the value of an assigned `case`' do
    expect_no_offenses(<<~RUBY)
      x = case y
          when z
            def initialize
            end
          end
    RUBY
  end

  it 'does not register an offense for an empty `initialize` method that is the value of an assigned `begin`' do
    expect_no_offenses(<<~RUBY)
      x = begin
        def initialize
        end
      rescue StandardError
        y
      end
    RUBY
  end

  it 'registers and corrects an offense for an empty `initialize` method that is not the last expression of an assigned `begin`' do
    expect_offense(<<~RUBY)
      x = begin
        def initialize
        ^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
        end
        y
      end
    RUBY

    expect_correction(<<~RUBY)
      x = begin
        y
      end
    RUBY
  end

  it 'registers and corrects an offense for an `initialize` method that only calls `super` followed by a semicolon' do
    expect_offense(<<~RUBY)
      class Foo
        def initialize
        ^^^^^^^^^^^^^^ Remove unnecessary `initialize` method.
          super
        end;
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
      end
    RUBY
  end

  it 'registers and corrects an offense for an `initialize` method that only calls `super` followed by a statement on the same line' do
    expect_offense(<<~RUBY)
      def initialize
      ^^^^^^^^^^^^^^ Remove unnecessary `initialize` method.
        super
      end; foo
    RUBY

    expect_correction(<<~RUBY)
      foo
    RUBY
  end

  it 'registers and corrects an offense for an empty `initialize` method followed by a statement on the same line' do
    expect_offense(<<~RUBY)
      class Foo
        def initialize; end; attr_reader :bar
        ^^^^^^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_reader :bar
      end
    RUBY
  end

  it 'registers and corrects an offense for an empty `initialize` method preceded by a statement on the same line' do
    expect_offense(<<~RUBY)
      class Foo
        attr_reader :bar; def initialize; end
                          ^^^^^^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_reader :bar
      end
    RUBY
  end

  it 'registers and corrects an offense for an empty `initialize` method between statements on the same line' do
    expect_offense(<<~RUBY)
      class Foo
        attr_reader :bar; def initialize; end; attr_reader :baz
                          ^^^^^^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_reader :bar; attr_reader :baz
      end
    RUBY
  end

  it 'registers and corrects an offense for an empty `initialize` method after a statement opening a heredoc on the same line' do
    expect_offense(<<~RUBY)
      class Foo
        BAR = <<~TEXT; def initialize; end
                       ^^^^^^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
          text
        TEXT
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        BAR = <<~TEXT
          text
        TEXT
      end
    RUBY
  end

  it 'does not register an offense for an empty `initialize` method spanning the body of a heredoc opened before it on the same line' do
    expect_no_offenses(<<~RUBY)
      class Foo
        BAR = <<~TEXT; def initialize
          text
        TEXT
        end
      end
    RUBY
  end

  it 'does not register an offense for an `initialize` method with a default argument that calls `super`' do
    expect_no_offenses(<<~RUBY)
      def initialize(a, b = 5)
        super
      end
    RUBY
  end

  it 'does not register an offense for an `initialize` method with a default keyword argument that calls `super`' do
    expect_no_offenses(<<~RUBY)
      def initialize(a, b: 5)
        super
      end
    RUBY
  end

  it 'does not register an offense for an `initialize` method with a default argument that does nothing' do
    expect_no_offenses(<<~RUBY)
      def initialize(a, b = 5)
      end
    RUBY
  end

  it 'does not register an offense for an `initialize` method with a default keyword argument that does nothing' do
    expect_no_offenses(<<~RUBY)
      def initialize(a, b: 5)
      end
    RUBY
  end

  it 'does not register an offense for an empty `initialize` method with an argument`' do
    expect_no_offenses(<<~RUBY)
      def initialize(_)
      end
    RUBY
  end

  it 'does not register an offense for an empty `initialize` method with a splat`' do
    expect_no_offenses(<<~RUBY)
      def initialize(*)
      end
    RUBY
  end

  it 'does not register an offense for an empty `initialize` method with a splat` and super' do
    expect_no_offenses(<<~RUBY)
      def initialize(*args)
        super(args.first)
      end
    RUBY
  end

  it 'does not register an offense for an empty `initialize` method with a kwsplat`' do
    expect_no_offenses(<<~RUBY)
      def initialize(**)
      end
    RUBY
  end

  it 'does not register an offense for an empty `initialize` method with an argument forwarding`', :ruby27 do
    expect_no_offenses(<<~RUBY)
      def initialize(...)
      end
    RUBY
  end

  context 'when `AllowComments: false`' do
    let(:cop_config) { { 'AllowComments' => false } }

    it 'registers and corrects an offense for an `initialize` method with only a comment' do
      expect_offense(<<~RUBY)
        def initialize
        ^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
          # initializer
        end
      RUBY

      expect_correction('')
    end

    it 'registers and corrects an offense for an empty `initialize` method followed by a comment, keeping the comment' do
      expect_offense(<<~RUBY)
        class Foo
          def initialize; end # comment
          ^^^^^^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          # comment
        end
      RUBY
    end
  end
end
