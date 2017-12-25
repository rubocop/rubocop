# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NegatedWhile do
  subject(:cop) { described_class.new }

  it 'registers an offense for while with exclamation point condition' do
    inspect_source(<<-RUBY.strip_indent)
      while !a_condition
        some_method
      end
      some_method while !a_condition
    RUBY
    expect(cop.messages).to eq(
      ['Favor `until` over `while` for negative conditions.'] * 2
    )
  end

  it 'registers an offense for until with exclamation point condition' do
    inspect_source(<<-RUBY.strip_indent)
      until !a_condition
        some_method
      end
      some_method until !a_condition
    RUBY
    expect(cop.messages)
      .to eq(['Favor `while` over `until` for negative conditions.'] * 2)
  end

  it 'registers an offense for while with "not" condition' do
    inspect_source(<<-RUBY.strip_indent)
      while (not a_condition)
        some_method
      end
      some_method while not a_condition
    RUBY
    expect(cop.messages).to eq(
      ['Favor `until` over `while` for negative conditions.'] * 2
    )
    expect(cop.offenses.map(&:line)).to eq([1, 4])
  end

  it 'accepts a while where only part of the condition is negated' do
    expect_no_offenses(<<-RUBY.strip_indent)
      while !a_condition && another_condition
        some_method
      end
      while not a_condition or another_condition
        some_method
      end
      some_method while not a_condition or other_cond
    RUBY
  end

  it 'accepts a while where the condition is doubly negated' do
    expect_no_offenses(<<-RUBY.strip_indent)
      while !!a_condition
        some_method
      end
      some_method while !!a_condition
    RUBY
  end

  it 'autocorrects by replacing while not with until' do
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      something while !x.even?
      something while(!x.even?)
    RUBY
    expect(corrected).to eq <<-RUBY.strip_indent
      something until x.even?
      something until(x.even?)
    RUBY
  end

  it 'autocorrects by replacing until not with while' do
    corrected = autocorrect_source('something until !x.even?')
    expect(corrected).to eq 'something while x.even?'
  end

  it 'does not blow up for empty while condition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      while ()
      end
    RUBY
  end

  it 'does not blow up for empty until condition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      until ()
      end
    RUBY
  end
end
