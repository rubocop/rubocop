# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::BinaryOperatorWithIdenticalOperands do
  subject(:cop) { described_class.new }

  it 'registers an offense when binary operator has identical nodes' do
    expect_offense(<<~RUBY)
      x == x
      ^^^^^^ Binary operator `==` has identical operands.
      y = x && x
          ^^^^^^ Binary operator `&&` has identical operands.
      y = a.x + a.x
          ^^^^^^^^^ Binary operator `+` has identical operands.
      a.x(arg) > a.x(arg)
      ^^^^^^^^^^^^^^^^^^^ Binary operator `>` has identical operands.
      a.(x) > a.(x)
      ^^^^^^^^^^^^^ Binary operator `>` has identical operands.
    RUBY
  end

  it 'does not register an offense when using binary operator with different operands' do
    expect_no_offenses(<<~RUBY)
      x == y
      y = x && z
      y = a.x + b.x
      a.x(arg) > b.x(arg)
      a.(x) > b.(x)
    RUBY
  end

  it 'does not register an offense when using arithmetic operator with numerics' do
    expect_no_offenses(<<~RUBY)
      x = 2 + 2
      x = 1 << 1
    RUBY
  end

  it 'does not crash on operator without any argument' do
    expect_no_offenses(<<~RUBY)
      foo.*
    RUBY
  end
end
