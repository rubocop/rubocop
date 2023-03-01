# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NegatedIfElseCondition, :config do
  it 'registers an offense and corrects when negating condition with `!` for `if-else`' do
    expect_offense(<<~RUBY)
      if !x
      ^^^^^ Invert the negated condition and swap the if-else branches.
        do_something
      else
        do_something_else
      end
    RUBY

    expect_correction(<<~RUBY)
      if x
        do_something_else
      else
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when negating condition with `not` for `if-else`' do
    expect_offense(<<~RUBY)
      if not x
      ^^^^^^^^ Invert the negated condition and swap the if-else branches.
        do_something
      else
        do_something_else
      end
    RUBY

    expect_correction(<<~RUBY)
      if x
        do_something_else
      else
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when negating condition with `not` for ternary' do
    expect_offense(<<~RUBY)
      !x ? do_something : do_something_else
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Invert the negated condition and swap the ternary branches.
    RUBY

    expect_correction(<<~RUBY)
      x ? do_something_else : do_something
    RUBY
  end

  it 'registers an offense and corrects a multiline ternary' do
    expect_offense(<<~RUBY)
      !x ?
      ^^^^ Invert the negated condition and swap the ternary branches.
        do_something :
        do_something_else # comment
    RUBY

    expect_correction(<<~RUBY)
      x ?
        do_something_else :
        do_something # comment
    RUBY
  end

  shared_examples 'negation method' do |method, inverted_method|
    it "registers an offense and corrects when negating condition with `#{method}` for `if-else`" do
      expect_offense(<<~RUBY, method: method)
        if x %{method} y
        ^^^^^^{method}^^ Invert the negated condition and swap the if-else branches.
          do_something
        else
          do_something_else
        end
      RUBY

      expect_correction(<<~RUBY)
        if x #{inverted_method} y
          do_something_else
        else
          do_something
        end
      RUBY
    end

    it "registers an offense and corrects when negating condition with `#{method}` for ternary" do
      expect_offense(<<~RUBY, method: method)
        x %{method} y ? do_something : do_something_else
        ^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Invert the negated condition and swap the ternary branches.
      RUBY

      expect_correction(<<~RUBY)
        x #{inverted_method} y ? do_something_else : do_something
      RUBY
    end

    it "registers an offense and corrects when negating condition with `#{method}` in parentheses for `if-else`" do
      expect_offense(<<~RUBY, method: method)
        if (x %{method} y)
        ^^^^^^^{method}^^^ Invert the negated condition and swap the if-else branches.
          do_something
        else
          do_something_else
        end
      RUBY

      expect_correction(<<~RUBY)
        if (x #{inverted_method} y)
          do_something_else
        else
          do_something
        end
      RUBY
    end

    it "registers an offense and corrects when negating condition with `#{method}` in parentheses for ternary" do
      expect_offense(<<~RUBY, method: method)
        (x %{method} y) ? do_something : do_something_else
        ^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Invert the negated condition and swap the ternary branches.
      RUBY

      expect_correction(<<~RUBY)
        (x #{inverted_method} y) ? do_something_else : do_something
      RUBY
    end

    it "registers an offense and corrects when negating condition with `#{method}` in begin-end for `if-else`" do
      expect_offense(<<~RUBY, method: method)
        if begin
        ^^^^^^^^ Invert the negated condition and swap the if-else branches.
          x %{method} y
        end
          do_something
        else
          do_something_else
        end
      RUBY

      expect_correction(<<~RUBY)
        if begin
          x #{inverted_method} y
        end
          do_something_else
        else
          do_something
        end
      RUBY
    end

    it "registers an offense and corrects when negating condition with `#{method}` in begin-end for ternary" do
      expect_offense(<<~RUBY, method: method)
        begin
        ^^^^^ Invert the negated condition and swap the ternary branches.
          x %{method} y
        end ? do_something : do_something_else
      RUBY

      expect_correction(<<~RUBY)
        begin
          x #{inverted_method} y
        end ? do_something_else : do_something
      RUBY
    end
  end

  it_behaves_like('negation method', '!=', '==')
  it_behaves_like('negation method', '!~', '=~')

  it 'registers an offense and corrects nested `if-else` with negated condition' do
    expect_offense(<<~RUBY)
      if !x
      ^^^^^ Invert the negated condition and swap the if-else branches.
        do_something
      else
        if !y
        ^^^^^ Invert the negated condition and swap the if-else branches.
          do_something_else_1
        else
          do_something_else_2
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if x
        if y
          do_something_else_2
        else
          do_something_else_1
        end
      else
        do_something
      end
    RUBY
  end

  it 'registers an offense when using negated condition and `if` branch body is empty' do
    expect_offense(<<~RUBY)
      if !condition.nil?
      ^^^^^^^^^^^^^^^^^^ Invert the negated condition and swap the if-else branches.
      else
        foo = 42
      end
    RUBY

    expect_correction(<<~RUBY)
      if condition.nil?
        foo = 42
      end
    RUBY
  end

  it 'does not register an offense when the `else` branch is empty' do
    expect_no_offenses(<<~RUBY)
      if !condition.nil?
        foo = 42
      else
      end
    RUBY
  end

  it 'does not register an offense when both branches are empty' do
    expect_no_offenses(<<~RUBY)
      if !condition.nil?
      else
      end
    RUBY
  end

  it 'does not crash when using `()` as a condition' do
    expect_no_offenses(<<~RUBY)
      if ()
        foo
      else
        bar
      end
    RUBY
  end

  it 'moves comments to correct branches during autocorrect' do
    expect_offense(<<~RUBY)
      if !condition.nil?
      ^^^^^^^^^^^^^^^^^^ Invert the negated condition and swap the if-else branches.
        # part B
        # and foo is 39
        foo = 39
      else
        # part A
        # and foo is 42
        foo = 42
      end
    RUBY

    expect_correction(<<~RUBY)
      if condition.nil?
        # part A
        # and foo is 42
        foo = 42
      else
        # part B
        # and foo is 39
        foo = 39
      end
    RUBY
  end

  it 'works with comments and multiple statements' do
    expect_offense(<<~RUBY)
      if !condition.nil?
      ^^^^^^^^^^^^^^^^^^ Invert the negated condition and swap the if-else branches.
        # part A
        # and foo is 1 and bar is 2
        foo = 1
        bar = 2
      else
        # part B
        # and foo is 3 and bar is 4
        foo = 3
        bar = 4
      end
    RUBY

    expect_correction(<<~RUBY)
      if condition.nil?
        # part B
        # and foo is 3 and bar is 4
        foo = 3
        bar = 4
      else
        # part A
        # and foo is 1 and bar is 2
        foo = 1
        bar = 2
      end
    RUBY
  end

  it 'works with comments when one branch is a begin and the other is not' do
    expect_offense(<<~RUBY)
      if !condition
      ^^^^^^^^^^^^^ Invert the negated condition and swap the if-else branches.
        # comment
        do_a
        do_b
      else
        do_c
      end
    RUBY

    expect_correction(<<~RUBY)
      if condition
        do_c
      else
        # comment
        do_a
        do_b
      end
    RUBY
  end

  it 'works with comments when neither branch is a begin node' do
    expect_offense(<<~RUBY)
      if !condition
      ^^^^^^^^^^^^^ Invert the negated condition and swap the if-else branches.
        # comment
        do_b
      else
        do_c
      end
    RUBY

    expect_correction(<<~RUBY)
      if condition
        do_c
      else
        # comment
        do_b
      end
    RUBY
  end

  it 'works with duplicate nodes' do
    expect_offense(<<~RUBY)
      # outer comment
      do_a

      if !condition
      ^^^^^^^^^^^^^ Invert the negated condition and swap the if-else branches.
        # comment
        do_a
      else
        do_c
      end
    RUBY

    expect_correction(<<~RUBY)
      # outer comment
      do_a

      if condition
        do_c
      else
        # comment
        do_a
      end
    RUBY
  end

  it 'correctly moves comments at the end of branches' do
    expect_offense(<<~RUBY)
      if !condition
      ^^^^^^^^^^^^^ Invert the negated condition and swap the if-else branches.
        do_a
        # comment
      else
        do_c
      end
    RUBY

    expect_correction(<<~RUBY)
      if condition
        do_c
      else
        do_a
        # comment
      end
    RUBY
  end

  it 'does not register an offense when negating condition for `if-elsif`' do
    expect_no_offenses(<<~RUBY)
      if !x
        do_something
      elsif !y
        do_something_else
      else
        do_another_thing
      end
    RUBY
  end

  it 'does not register an offense when only part of the condition is negated' do
    expect_no_offenses(<<~RUBY)
      if !x && y
        do_something
      else
        do_another_thing
      end
    RUBY
  end

  it 'does not register an offense when `if` with `!!` condition' do
    expect_no_offenses(<<~RUBY)
      if !!x
        do_something
      else
        do_another_thing
      end
    RUBY
  end

  it 'does not register an offense when `if` with negated condition has no `else` branch' do
    expect_no_offenses(<<~RUBY)
      if !x
        do_something
      end
    RUBY
  end
end
