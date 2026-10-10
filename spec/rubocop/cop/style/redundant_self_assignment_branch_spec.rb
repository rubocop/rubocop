# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantSelfAssignmentBranch, :config do
  it 'registers and corrects an offense when self-assigning redundant else ternary branch' do
    expect_offense(<<~RUBY)
      foo = condition ? bar : foo
                              ^^^ Remove the self-assignment branch.
    RUBY

    expect_correction(<<~RUBY)
      foo = bar if condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else ternary branch and ' \
     'using method call with an argument in the if ternary branch' do
    expect_offense(<<~RUBY)
      foo = condition ? bar(arg) : foo
                                   ^^^ Remove the self-assignment branch.
    RUBY

    expect_correction(<<~RUBY)
      foo = bar(arg) if condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else ternary branch and ' \
     'using a line broke method chain in the if ternary branch' do
    expect_offense(<<~RUBY)
      foo = condition ? bar.
        baz : foo
              ^^^ Remove the self-assignment branch.
    RUBY

    expect_correction(<<~RUBY)
      foo = bar.
        baz if condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else ternary branch and ' \
     'using an empty parentheses in the if ternary branch' do
    expect_offense(<<~RUBY)
      foo = condition ? (
        ) : foo
            ^^^ Remove the self-assignment branch.
    RUBY

    expect_correction(<<~RUBY)
      foo = (
        ) if condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant if ternary branch' do
    expect_offense(<<~RUBY)
      foo = condition ? foo : bar
                        ^^^ Remove the self-assignment branch.
    RUBY

    expect_correction(<<~RUBY)
      foo = bar unless condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else branch' do
    expect_offense(<<~RUBY)
      foo = if condition
              bar
            else
              foo
              ^^^ Remove the self-assignment branch.
            end
    RUBY

    expect_correction(<<~RUBY)
      foo = bar if condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant if branch' do
    expect_offense(<<~RUBY)
      foo = if condition
              foo
              ^^^ Remove the self-assignment branch.
            else
              bar
            end
    RUBY

    expect_correction(<<~RUBY)
      foo = bar unless condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant if branch with heredoc' do
    expect_offense(<<~RUBY)
      foo = if condition
              foo
              ^^^ Remove the self-assignment branch.
            else
              <<~TEXT
                bar
              TEXT
            end
    RUBY

    expect_correction(<<~RUBY)
      foo = <<~TEXT unless condition
                bar
              TEXT
    RUBY
  end

  it 'does not register an offense when self-assigning redundant else branch and multiline if branch' do
    expect_no_offenses(<<~RUBY)
      foo = if condition
              bar
              baz
            else
              foo
            end
    RUBY
  end

  it 'does not register an offense when self-assigning redundant else branch and multiline else branch' do
    expect_no_offenses(<<~RUBY)
      foo = if condition
              foo
            else
              bar
              baz
            end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else branch and empty if branch' do
    expect_offense(<<~RUBY)
      foo = if condition
            else
              foo
              ^^^ Remove the self-assignment branch.
            end
    RUBY

    expect_correction(<<~RUBY)
      foo = nil if condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else branch and empty else branch' do
    expect_offense(<<~RUBY)
      foo = if condition
              foo
              ^^^ Remove the self-assignment branch.
            else
            end
    RUBY

    expect_correction(<<~RUBY)
      foo = nil unless condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning in a method body' do
    expect_offense(<<~RUBY)
      def do_something
        foo = condition ? foo : bar
                          ^^^ Remove the self-assignment branch.
      end
    RUBY

    expect_correction(<<~RUBY)
      def do_something
        foo = bar unless condition
      end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning in an `if` branch' do
    expect_offense(<<~RUBY)
      if other_condition
        foo = condition ? foo : bar
                          ^^^ Remove the self-assignment branch.
      end
    RUBY

    expect_correction(<<~RUBY)
      if other_condition
        foo = bar unless condition
      end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning in a `case` else branch' do
    expect_offense(<<~RUBY)
      case other
      when 1
        do_something
      else
        foo = condition ? foo : bar
                          ^^^ Remove the self-assignment branch.
      end
    RUBY

    expect_correction(<<~RUBY)
      case other
      when 1
        do_something
      else
        foo = bar unless condition
      end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning in an `in` branch' do
    expect_offense(<<~RUBY)
      case other
      in Integer
        foo = condition ? foo : bar
                          ^^^ Remove the self-assignment branch.
      end
    RUBY

    expect_correction(<<~RUBY)
      case other
      in Integer
        foo = bar unless condition
      end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning in a `for` body' do
    expect_offense(<<~RUBY)
      for x in items
        foo = condition ? foo : bar
                          ^^^ Remove the self-assignment branch.
      end
    RUBY

    expect_correction(<<~RUBY)
      for x in items
        foo = bar unless condition
      end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning in a `begin` body with `rescue`' do
    expect_offense(<<~RUBY)
      begin
        foo = condition ? foo : bar
                          ^^^ Remove the self-assignment branch.
      rescue StandardError
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        foo = bar unless condition
      rescue StandardError
        do_something
      end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning in a method body with `rescue`' do
    expect_offense(<<~RUBY)
      def do_something
        foo = condition ? foo : bar
                          ^^^ Remove the self-assignment branch.
      rescue StandardError
        do_something_else
      end
    RUBY

    expect_correction(<<~RUBY)
      def do_something
        foo = bar unless condition
      rescue StandardError
        do_something_else
      end
    RUBY
  end

  it 'does not register an offense when the self-assignment is the value of a modifier `rescue`' do
    expect_no_offenses(<<~RUBY)
      do_something rescue foo = condition ? foo : bar
    RUBY
  end

  it 'does not register an offense when the self-assignment is used as an `if` condition' do
    expect_no_offenses(<<~RUBY)
      if foo = condition ? foo : bar
        do_something
      end
    RUBY
  end

  it 'does not register an offense when the self-assignment is used as a method argument' do
    expect_no_offenses(<<~RUBY)
      do_something(foo = condition ? foo : bar)
    RUBY
  end

  it 'does not register an offense when the self-assignment is the value of another assignment' do
    expect_no_offenses(<<~RUBY)
      baz = foo = condition ? foo : bar
    RUBY
  end

  it 'does not register an offense when the self-assignment is parenthesized' do
    expect_no_offenses(<<~RUBY)
      do_something if (foo = condition ? foo : bar)
    RUBY
  end

  it 'does not register an offense when self-assigning redundant else ternary branch for ivar' do
    expect_no_offenses(<<~RUBY)
      @foo = condition ? @bar : @foo
    RUBY
  end

  it 'does not register an offense when self-assigning redundant else ternary branch for cvar' do
    expect_no_offenses(<<~RUBY)
      @@foo = condition ? @@bar : @@foo
    RUBY
  end

  it 'does not register an offense when self-assigning redundant else ternary branch for gvar' do
    expect_no_offenses(<<~RUBY)
      $foo = condition ? $bar : $foo
    RUBY
  end

  it 'does not register an offense when not self-assigning redundant branches' do
    expect_no_offenses(<<~RUBY)
      foo = condition ? bar : baz
    RUBY
  end

  it 'does not register an offense when using only if branch' do
    expect_no_offenses(<<~RUBY)
      foo = if condition
              bar
            end
    RUBY
  end

  it 'does not register an offense when multi assignment' do
    expect_no_offenses(<<~RUBY)
      foo, bar = baz
    RUBY
  end

  # Ignore method calls as they can have side effects. In other words, it may be unsafe detection.
  it 'does not register an offense when lhs is not variable' do
    expect_no_offenses(<<~RUBY)
      foo.do_something = condition ? foo.do_something : bar.do_something
    RUBY
  end

  it 'does not register an offense when using `elsif` and self-assigning the value of `then` branch' do
    expect_no_offenses(<<~RUBY)
      foo = if condition
        foo
      elsif another_condition
        bar
      else
        baz
      end
    RUBY
  end

  it 'does not register an offense when using `elsif` and self-assigning the value of `elsif` branch' do
    expect_no_offenses(<<~RUBY)
      foo = if condition
              bar
            elsif another_condition
              foo
            else
              baz
            end
    RUBY
  end

  it 'does not register an offense when using `elsif` and self-assigning the value of `else` branch' do
    expect_no_offenses(<<~RUBY)
      foo = if condition
              bar
            elsif another_condition
              baz
            else
              foo
            end
    RUBY
  end
end
