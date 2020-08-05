# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FloatComparison do
  subject(:cop) { described_class.new }

  it 'registers an offense when comparing with float' do
    offenses = inspect_source(<<~RUBY)
      x == 0.1
      0.1 == x
      x != 0.1
      0.1 != x
      x.eql?(0.1)
      0.1.eql?(x)
    RUBY

    expect(offenses.size).to eq(6)
  end

  it 'registers an offense when comparing with float returning method' do
    offenses = inspect_source(<<~RUBY)
      x == Float(1)
      x == '0.1'.to_f
      x == 1.fdiv(2)
    RUBY

    expect(offenses.size).to eq(3)
  end

  it 'registers an offense when comparing with arightmetic operator on floats' do
    offenses = inspect_source(<<~RUBY)
      x == 0.1 + y
      x == y + Float('0.1')
      x == y + z * (foo(arg) + '0.1'.to_f)
    RUBY

    expect(offenses.size).to eq(3)
  end

  it 'registers an offense when comparing with method on float receiver' do
    expect_offense(<<~RUBY)
      x == 0.1.abs
      ^^^^^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'does not register an offense when comparing with float method '\
     'that can return numeric and returns integer' do
    expect_no_offenses(<<~RUBY)
      x == 1.1.ceil
    RUBY
  end

  it 'registers an offense when comparing with float method '\
     'that can return numeric and returns float' do
    expect_offense(<<~RUBY)
      x == 1.1.ceil(1)
      ^^^^^^^^^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'does not register an offense when comparing with float using epsilon' do
    expect_no_offenses(<<~RUBY)
      (x - 0.1) < epsilon
    RUBY
  end
end
