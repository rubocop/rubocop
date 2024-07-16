# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FloatComparison, :config do
  it 'registers an offense when comparing with float' do
    expect_offense(<<~RUBY)
      x == 0.1
      ^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
      0.1 == x
      ^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
      x != 0.1
      ^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
      0.1 != x
      ^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
      x.eql?(0.1)
      ^^^^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
      0.1.eql?(x)
      ^^^^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'registers an offense when comparing with float returning method' do
    expect_offense(<<~RUBY)
      x == Float(1)
      ^^^^^^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
      x == '0.1'.to_f
      ^^^^^^^^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
      x == 1.fdiv(2)
      ^^^^^^^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'registers an offense when comparing with arithmetic operator on floats' do
    expect_offense(<<~RUBY)
      x == 0.1 + y
      ^^^^^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
      x == y + Float('0.1')
      ^^^^^^^^^^^^^^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
      x == y + z * (foo(arg) + '0.1'.to_f)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'registers an offense when comparing with method on float receiver' do
    expect_offense(<<~RUBY)
      x == 0.1.abs
      ^^^^^^^^^^^^ Avoid (in)equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'does not register an offense when comparing with float method ' \
     'that can return numeric and returns integer' do
    expect_no_offenses(<<~RUBY)
      x == 1.1.ceil
    RUBY
  end

  it 'registers an offense when comparing with float method ' \
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

  it 'does not register an offense when comparing with rational literal' do
    expect_no_offenses(<<~RUBY)
      value == 0.2r
    RUBY
  end

  it 'does not register an offense when comparing against zero' do
    expect_no_offenses(<<~RUBY)
      x == 0.0
      x.to_f == 0
      x.to_f.abs == 0.0
      x != 0.0
      x.to_f != 0
      x.to_f.zero?
      x.to_f.nonzero?
    RUBY
  end
end
