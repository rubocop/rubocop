# frozen_string_literal: true

describe RuboCop::Cop::Lint::ParenthesesAsGroupedExpression do
  subject(:cop) { described_class.new }

  it 'registers an offense for method call with space before the ' \
     'parenthesis' do
    inspect_source(cop, 'a.func (x)')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for predicate method call with space ' \
     'before the parenthesis' do
    inspect_source(cop, 'is? (x)')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for math expression' do
    expect_offense(<<-RUBY.strip_indent)
      puts (2 + 3) * 4
          ^ `(...)` interpreted as grouped expression.
    RUBY
  end

  it 'accepts a method call without arguments' do
    expect_no_offenses('func')
  end

  it 'accepts a method call with arguments but no parentheses' do
    expect_no_offenses('puts x')
  end

  it 'accepts a chain of method calls' do
    expect_no_offenses(<<-END.strip_indent)
      a.b
      a.b 1
      a.b(1)
    END
  end

  it 'accepts method with parens as arg to method without' do
    expect_no_offenses('a b(c)')
  end

  it 'accepts an operator call with argument in parentheses' do
    expect_no_offenses(<<-END.strip_indent)
      a % (b + c)
      a.b = (c == d)
    END
  end

  it 'accepts a space inside opening paren followed by left paren' do
    expect_no_offenses('a( (b) )')
  end

  it "doesn't register an offense for a call with multiple arguments" do
    # there is no ambiguity here
    expect_no_offenses('assert_equal (0..1.9), acceleration.domain')
  end
end
