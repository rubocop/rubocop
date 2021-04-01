# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NegatedWhile, :config do
  it 'registers an offense for while with exclamation point condition' do
    expect_offense(<<~RUBY)
      while !a_condition
      ^^^^^^^^^^^^^^^^^^ Favor `until` over `while` for negative conditions.
        some_method
      end
      some_method while !a_condition
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `until` over `while` for negative conditions.
    RUBY

    expect_correction(<<~RUBY)
      until a_condition
        some_method
      end
      some_method until a_condition
    RUBY
  end

  it 'registers an offense for until with exclamation point condition' do
    expect_offense(<<~RUBY)
      until !a_condition
      ^^^^^^^^^^^^^^^^^^ Favor `while` over `until` for negative conditions.
        some_method
      end
      some_method until !a_condition
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `while` over `until` for negative conditions.
    RUBY

    expect_correction(<<~RUBY)
      while a_condition
        some_method
      end
      some_method while a_condition
    RUBY
  end

  it 'registers an offense for while with "not" condition' do
    expect_offense(<<~RUBY)
      while (not a_condition)
      ^^^^^^^^^^^^^^^^^^^^^^^ Favor `until` over `while` for negative conditions.
        some_method
      end
      some_method while not a_condition
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `until` over `while` for negative conditions.
    RUBY

    expect_correction(<<~RUBY)
      until (a_condition)
        some_method
      end
      some_method until a_condition
    RUBY
  end

  it 'accepts a while where only part of the condition is negated' do
    expect_no_offenses(<<~RUBY)
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
    expect_no_offenses(<<~RUBY)
      while !!a_condition
        some_method
      end
      some_method while !!a_condition
    RUBY
  end

  it 'autocorrects by replacing while not with until' do
    expect_offense(<<~RUBY)
      something while !x.even?
      ^^^^^^^^^^^^^^^^^^^^^^^^ Favor `until` over `while` for negative conditions.
      something while(!x.even?)
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `until` over `while` for negative conditions.
    RUBY

    expect_correction(<<~RUBY)
      something until x.even?
      something until(x.even?)
    RUBY
  end

  it 'autocorrects by replacing until not with while' do
    expect_offense(<<~RUBY)
      something until !x.even?
      ^^^^^^^^^^^^^^^^^^^^^^^^ Favor `while` over `until` for negative conditions.
    RUBY

    expect_correction(<<~RUBY)
      something while x.even?
    RUBY
  end

  it 'does not blow up for empty while condition' do
    expect_no_offenses(<<~RUBY)
      while ()
      end
    RUBY
  end

  it 'does not blow up for empty until condition' do
    expect_no_offenses(<<~RUBY)
      until ()
      end
    RUBY
  end
end
