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

  it 'registers an offense for an `initialize` method with a default argument that does nothing' do
    expect_offense(<<~RUBY)
      def initialize(a, b = 5)
      ^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
      end
    RUBY
  end

  it 'registers an offense for an `initialize` method with a default keyword argument that does nothing' do
    expect_offense(<<~RUBY)
      def initialize(a, b: 5)
      ^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary empty `initialize` method.
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

  it 'does not register an offense for an empty `initialize` method with a argument forwarding`', :ruby27 do
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
  end
end
