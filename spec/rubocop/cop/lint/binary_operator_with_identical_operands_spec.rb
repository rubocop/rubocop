# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::BinaryOperatorWithIdenticalOperands do
  subject(:cop) { described_class.new }

  it 'registers an offense when binary operator has identical nodes' do
    offenses = inspect_source(<<~RUBY)
      x == x
      y = x && x
      y = a.x + a.x
      a.x(arg) > a.x(arg)
      a.(x) > a.(x)
    RUBY

    expect(offenses.size).to eq(5)
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
    RUBY
  end
end
