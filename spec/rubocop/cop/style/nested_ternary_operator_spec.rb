# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NestedTernaryOperator, :config do
  it 'registers an offense and corrects for a nested ternary operator expression' do
    expect_offense(<<~RUBY)
      a ? (b ? b1 : b2) : a2
           ^^^^^^^^^^^ Ternary operators must not be nested. Prefer `if` or `else` constructs instead.
    RUBY

    expect_correction(<<~RUBY)
      if a
      b ? b1 : b2
      else
      a2
      end
    RUBY
  end

  it 'registers an offense and corrects for a nested ternary operator expression with block' do
    expect_offense(<<~RUBY)
      cond ? foo : bar(foo.a ? foo.b : foo) { |e, k| e.nil? ? nil : e[k] }
                                                     ^^^^^^^^^^^^^^^^^^^ Ternary operators must not be nested. Prefer `if` or `else` constructs instead.
                       ^^^^^^^^^^^^^^^^^^^ Ternary operators must not be nested. Prefer `if` or `else` constructs instead.
    RUBY

    expect_correction(<<~RUBY)
      if cond
      foo
      else
      bar(foo.a ? foo.b : foo) { |e, k| e.nil? ? nil : e[k] }
      end
    RUBY
  end

  it 'registers an offense and corrects for a nested ternary operator expression with no parentheses on the outside' do
    expect_offense(<<~RUBY)
      x ? y + (z ? 1 : 0) : nil
               ^^^^^^^^^ Ternary operators must not be nested. Prefer `if` or `else` constructs instead.
    RUBY

    expect_correction(<<~RUBY)
      if x
      y + (z ? 1 : 0)
      else
      nil
      end
    RUBY
  end

  it 'accepts a non-nested ternary operator within an if' do
    expect_no_offenses(<<~RUBY)
      a = if x
        cond ? b : c
      else
        d
      end
    RUBY
  end

  it 'can handle multiple nested ternaries' do
    expect_offense(<<~RUBY)
      a ? b : c ? d : e ? f : g
                      ^^^^^^^^^ Ternary operators must not be nested. Prefer `if` or `else` constructs instead.
              ^^^^^^^^^^^^^^^^^ Ternary operators must not be nested. Prefer `if` or `else` constructs instead.
    RUBY

    expect_correction(<<~RUBY)
      if a
      b
      else
      if c
      d
      else
      e ? f : g
      end
      end
    RUBY
  end
end
