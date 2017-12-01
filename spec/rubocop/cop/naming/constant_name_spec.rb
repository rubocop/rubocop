# frozen_string_literal: true

describe RuboCop::Cop::Naming::ConstantName do
  subject(:cop) { described_class.new }

  it 'registers an offense for camel case in const name' do
    expect_offense(<<-RUBY.strip_indent)
      TopCase = 5
      ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'registers an offense for camel case in const name' \
     'when using frozen object assignment' do
    expect_offense(<<-RUBY.strip_indent)
      TopCase = 5.freeze
      ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'registers offenses for camel case in multiple const assignment' do
    expect_offense(<<-RUBY.strip_indent)
      TopCase, Test2, TEST_3 = 5, 6, 7
      ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
               ^^^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'registers an offense for snake case in const name' do
    expect_offense(<<-RUBY.strip_indent)
      TOP_test = 5
      ^^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end

  it 'registers 1 offense if rhs is offending const assignment' do
    expect_offense(<<-RUBY.strip_indent)
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

  it 'does not check names if rhs is a method call' do
    expect_no_offenses('AnythingGoes = test')
  end

  it 'does not check names if rhs is a `Class.new`' do
    expect_no_offenses('Invalid = Class.new(StandardError)')
  end

  it 'does not check names if rhs is a `Struct.new`' do
    expect_no_offenses('Investigation = Struct.new(:offenses, :errors)')
  end

  it 'does not check names if rhs is a method call with block' do
    expect_no_offenses(<<-RUBY.strip_indent)
      AnythingGoes = test do
        do_something
      end
    RUBY
  end

  it 'does not check if rhs is another constant' do
    expect_no_offenses('Parser::CurrentRuby = Parser::Ruby21')
  end

  it 'does not check if rhs is a non-offensive const assignment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      Bar = Foo = Qux
    RUBY
  end

  it 'checks qualified const names' do
    expect_offense(<<-RUBY.strip_indent)
      ::AnythingGoes = 30
        ^^^^^^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
      a::Bar_foo = 10
         ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
    RUBY
  end
end
