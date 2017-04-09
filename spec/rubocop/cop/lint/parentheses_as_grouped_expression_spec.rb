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
    inspect_source(cop, 'puts (2 + 3) * 4')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a method call without arguments' do
    inspect_source(cop, 'func')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a method call with arguments but no parentheses' do
    inspect_source(cop, 'puts x')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a chain of method calls' do
    inspect_source(cop, <<-END.strip_indent)
      a.b
      a.b 1
      a.b(1)
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts method with parens as arg to method without' do
    inspect_source(cop, 'a b(c)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts an operator call with argument in parentheses' do
    inspect_source(cop, <<-END.strip_indent)
      a % (b + c)
      a.b = (c == d)
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts a space inside opening paren followed by left paren' do
    inspect_source(cop, 'a( (b) )')
    expect(cop.offenses).to be_empty
  end

  it "doesn't register an offense for a call with multiple arguments" do
    # there is no ambiguity here
    inspect_source(cop, 'assert_equal (0..1.9), acceleration.domain')
    expect(cop.offenses).to be_empty
  end
end
