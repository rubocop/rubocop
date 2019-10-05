# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NonLocalControlFlowInTernary do
  subject(:cop) { described_class.new }

  it 'registers an offense when using `raise` in `if` branch' do
    expect_offense(<<~RUBY)
      foo? ? raise(BarError) : baz
             ^^^^^^^^^^^^^^^ Avoid non-local control flow in ternary expressions.
    RUBY
  end

  it 'registers an offense when using `raise` in `else` branch' do
    expect_offense(<<~RUBY)
      foo? ? baz : raise(BarError)
                   ^^^^^^^^^^^^^^^ Avoid non-local control flow in ternary expressions.
    RUBY
  end

  it 'registers an offense when using `fail` in `if` branch' do
    expect_offense(<<~RUBY)
      foo? ? fail(BarError) : baz
             ^^^^^^^^^^^^^^ Avoid non-local control flow in ternary expressions.
    RUBY
  end

  it 'registers an offense when using `fail` in `else` branch' do
    expect_offense(<<~RUBY)
      foo? ? baz : fail(BarError)
                   ^^^^^^^^^^^^^^ Avoid non-local control flow in ternary expressions.
    RUBY
  end

  it 'registers an offense when using `next` in `if` branch' do
    expect_offense(<<~RUBY)
      foo? ? next : baz
             ^^^^ Avoid non-local control flow in ternary expressions.
    RUBY
  end

  it 'registers an offense when using `next` in `else` branch' do
    expect_offense(<<~RUBY)
      foo? ? baz : next
                   ^^^^ Avoid non-local control flow in ternary expressions.
    RUBY
  end

  it 'registers an offense when using `return` in `if` branch' do
    expect_offense(<<~RUBY)
      foo? ? return : baz
             ^^^^^^ Avoid non-local control flow in ternary expressions.
    RUBY
  end

  it 'registers an offense when using `return` in `else` branch' do
    expect_offense(<<~RUBY)
      foo? ? baz : return
                   ^^^^^^ Avoid non-local control flow in ternary expressions.
    RUBY
  end

  it 'registers an offense when using `break` in `if` branch' do
    expect_offense(<<~RUBY)
      foo? ? break : baz
             ^^^^^ Avoid non-local control flow in ternary expressions.
    RUBY
  end

  it 'registers an offense when using `break` in `else` branch' do
    expect_offense(<<~RUBY)
      foo? ? baz : break
                   ^^^^^ Avoid non-local control flow in ternary expressions.
    RUBY
  end

  it 'registers an offense when using control flow in both branches' do
    expect_offense(<<~RUBY)
      foo? ? next : break
             ^^^^ Avoid non-local control flow in ternary expressions.
                    ^^^^^ Avoid non-local control flow in ternary expressions.
    RUBY
  end
end
