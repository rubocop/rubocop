# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::ConstantName, :config do
  it 'registers an offense for camel case in const name' do
    expect_offense(<<~RUBY)
      TopCase = 5
      ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'registers an offense for camel case in const name when using frozen range assignment' do
    expect_offense(<<~RUBY)
      TopCase = (1..5).freeze
      ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'registers an offense for camel case in const name when using frozen object assignment' do
    expect_offense(<<~RUBY)
      TopCase = 5.freeze
      ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'registers an offense for non-POSIX upper case in const name' do
    expect_offense(<<~RUBY)
      Nö = 'no'
      ^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'registers offenses for camel case in multiple const assignment' do
    expect_offense(<<~RUBY)
      TopCase, Test2, TEST_3 = 5, 6, 7
      ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
               ^^^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'registers an offense for snake case in const name' do
    expect_offense(<<~RUBY)
      TOP_test = 5
      ^^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'registers 1 offense if rhs is offending const assignment' do
    expect_offense(<<~RUBY)
      Bar = Foo = 4
            ^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'allows screaming snake case in const name' do
    expect_no_offenses('TOP_TEST = 5')
  end

  it 'allows screaming snake case in multiple const assignment' do
    expect_no_offenses('TOP_TEST, TEST_2 = 5, 6')
  end

  it 'allows screaming snake case with POSIX upper case characters' do
    expect_no_offenses('TÖP_TEST = 5')
  end

  it 'does not check names if rhs is a method call' do
    expect_no_offenses('AnythingGoes = test')
  end

  it 'does not check names if rhs is a method call with conditional assign' do
    expect_no_offenses('AnythingGoes ||= test')
  end

  it 'does not check names if rhs is a `Class.new`' do
    expect_no_offenses('Invalid = Class.new(StandardError)')
  end

  it 'does not check names if rhs is a `Class.new` with conditional assign' do
    expect_no_offenses('Invalid ||= Class.new(StandardError)')
  end

  it 'does not check names if rhs is a `Struct.new`' do
    expect_no_offenses('Investigation = Struct.new(:offenses, :errors)')
  end

  it 'does not check names if rhs is a `Struct.new` with conditional assign' do
    expect_no_offenses('Investigation ||= Struct.new(:offenses, :errors)')
  end

  it 'does not check names if rhs is a method call with block' do
    expect_no_offenses(<<~RUBY)
      AnythingGoes = test do
        do_something
      end
    RUBY
  end

  it 'does not check if rhs is another constant' do
    expect_no_offenses('Parser::CurrentRuby = Parser::Ruby21')
  end

  it 'does not check if rhs is a non-offensive const assignment' do
    expect_no_offenses(<<~RUBY)
      Bar = Foo = Qux
    RUBY
  end

  it 'checks qualified const names' do
    expect_offense(<<~RUBY)
      ::AnythingGoes = 30
        ^^^^^^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
      a::Bar_foo = 10
         ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'does not register an offense when assigning a constant from an empty branch of `else`' do
    expect_no_offenses(<<~RUBY)
      CONST = if condition
        foo
      else
      end
    RUBY
  end

  context 'when a rhs is a conditional expression' do
    context 'when conditional branches contain only constants' do
      it 'does not check names' do
        expect_no_offenses('Investigation = if true then Foo else Bar end')
      end
    end

    context 'when conditional branches contain a value other than a constant' do
      it 'does not check names' do
        expect_no_offenses('Investigation = if true then "foo" else Bar end')
      end
    end

    context 'when conditional branches contain only string values' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          TopCase = if true then 'foo' else 'bar' end
          ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
        RUBY
      end
    end
  end
end
