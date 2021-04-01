# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::BinaryOperatorWithIdenticalOperands, :config do
  %i[== != === <=> =~ && || - > >= < <= / % | ^].each do |operator|
    it "registers an offense for `#{operator}` with duplicate operands" do
      expect_offense(<<~RUBY, operator: operator)
        y = a.x(arg) %{operator} a.x(arg)
            ^^^^^^^^^^{operator}^^^^^^^^^ Binary operator `%{operator}` has identical operands.
      RUBY
    end
  end

  %i[+ * ** << >>].each do |operator|
    it "does not register an offense for `#{operator}` with duplicate operands" do
      expect_no_offenses(<<~RUBY)
        y = a.x(arg) #{operator} a.x(arg)
      RUBY
    end
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
