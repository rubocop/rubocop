# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MultilineTernaryOperator, :config do
  it 'registers offense and corrects when the if branch and the else branch are ' \
     'on a separate line from the condition' do
    expect_offense(<<~RUBY)
      a = cond ?
          ^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
        b : c
    RUBY

    expect_correction(<<~RUBY)
      a = if cond
        b
      else
        c
      end
    RUBY
  end

  it 'registers an offense and corrects when the false branch is on a separate line and assigning a return value' do
    expect_offense(<<~RUBY)
      a = cond ? b :
          ^^^^^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
          c
    RUBY

    expect_correction(<<~RUBY)
      a = if cond
        b
      else
        c
      end
    RUBY
  end

  it 'registers an offense and corrects when the false branch is on a separate line' do
    expect_offense(<<~RUBY)
      cond ? b :
      ^^^^^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
      c
    RUBY

    expect_correction(<<~RUBY)
      if cond
        b
      else
        c
      end
    RUBY
  end

  it 'registers an offense and corrects when everything is on a separate line' do
    expect_offense(<<~RUBY)
      a = cond ?
          ^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
          b :
          c
    RUBY

    expect_correction(<<~RUBY)
      a = if cond
        b
      else
        c
      end
    RUBY
  end

  it 'registers an offense and corrects when condition is multiline' do
    expect_offense(<<~RUBY)
      a =
        b ==
        ^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
          c ? d : e
    RUBY

    expect_correction(<<~RUBY)
      a =
        if b ==
          c
        d
      else
        e
      end
    RUBY
  end

  it 'registers an offense and corrects when condition is multiline and using hash key assignment' do
    expect_offense(<<~RUBY)
      a[:a] =
        b ==
        ^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
          c ? d : e
    RUBY

    expect_correction(<<~RUBY)
      a[:a] =
        if b ==
          c
        d
      else
        e
      end
    RUBY
  end

  it 'registers an offense and corrects when condition is multiline and using assignment method' do
    expect_offense(<<~RUBY)
      a.foo =
        b ==
        ^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
          c ? d : e
    RUBY

    expect_correction(<<~RUBY)
      a.foo =
        if b ==
          c
        d
      else
        e
      end
    RUBY
  end

  it 'register an offense and corrects when returning a multiline ternary operator expression with `return`' do
    expect_offense(<<~RUBY)
      return cond ?
             ^^^^^^ Avoid multi-line ternary operators, use single-line instead.
             foo :
             bar
    RUBY

    expect_correction(<<~RUBY)
      return cond ? foo : bar
    RUBY
  end

  it 'register an offense and corrects when returning a multiline ternary operator expression with `break`' do
    expect_offense(<<~RUBY)
      break cond ?
            ^^^^^^ Avoid multi-line ternary operators, use single-line instead.
            foo :
            bar
    RUBY

    expect_correction(<<~RUBY)
      break cond ? foo : bar
    RUBY
  end

  it 'register an offense and corrects when returning a multiline ternary operator expression with `next`' do
    expect_offense(<<~RUBY)
      next cond ?
           ^^^^^^ Avoid multi-line ternary operators, use single-line instead.
           foo :
           bar
    RUBY

    expect_correction(<<~RUBY)
      next cond ? foo : bar
    RUBY
  end

  it 'register an offense and corrects when returning a multiline ternary operator expression with method call' do
    expect_offense(<<~RUBY)
      do_something cond ?
                   ^^^^^^ Avoid multi-line ternary operators, use single-line instead.
                   foo :
                   bar
    RUBY

    expect_correction(<<~RUBY)
      do_something cond ? foo : bar
    RUBY
  end

  it 'accepts a single line ternary operator expression' do
    expect_no_offenses('a = cond ? b : c')
  end

  it 'registers an offense and corrects when the if branch and the else branch are ' \
     'on a separate line from the condition and not contains a comment' do
    expect_offense(<<~RUBY)
      # comment a
      a = cond ?
          ^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
        b : c # comment b
      # comment c
    RUBY

    expect_correction(<<~RUBY)
      # comment a
      a = if cond
        b
      else
        c
      end # comment b
      # comment c
    RUBY
  end

  it 'registers an offense and corrects when if branch and the else branch are ' \
     'on a separate line from the condition and contains a comment' do
    expect_offense(<<~RUBY)
      a = cond ? # comment a
          ^^^^^^^^^^^^^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
        # comment b
        b : c

      a = cond ?
          ^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
        b : # comment
        c

      a = cond ? b : # comment
          ^^^^^^^^^^^^^^^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
        c
    RUBY

    expect_correction(<<~RUBY)
      # comment a
      # comment b
      a = if cond
        b
      else
        c
      end

      # comment
      a = if cond
        b
      else
        c
      end

      # comment
      a = if cond
        b
      else
        c
      end
    RUBY
  end
end
